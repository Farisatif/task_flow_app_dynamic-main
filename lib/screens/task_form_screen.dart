import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import '../core/database/database.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/time_utils.dart';
import '../core/services/app_preferences.dart';
import '../core/services/notification_prefs.dart';
import '../core/services/notification_service.dart';
import '../widgets/app_scaffold.dart';

/// شاشة إضافة/تعديل مهمة. مرّر taskId من أجل التعديل، أو اتركه null لمهمة جديدة.
class TaskFormScreen extends StatefulWidget {
  final int? taskId;
  const TaskFormScreen({super.key, this.taskId});

  bool get isEditing => taskId != null;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _date = DateTime.now();
  TimeOfDay _start = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 10, minute: 0);
  TaskPriority _priority = TaskPriority.medium;
  int? _categoryId;
  int? _projectId;
  bool _loading = true;

  bool _reminderEnabled = false;
  int _reminderLeadMinutes = 10;
  AppNotificationSound _reminderSound = AppNotificationSound.defaultSound;

  @override
  void initState() {
    super.initState();
    _loadIfEditing();
  }

  Future<void> _loadIfEditing() async {
    final appPrefs = context.read<AppPreferences>();
    // نطبّق الإعدادات الافتراضية للمهام الجديدة (مدة، أولوية، تذكير تلقائي)
    if (!widget.isEditing) {
      final end = TimeUtils.toMinutes(_start) + appPrefs.taskDefaults.defaultDurationMinutes;
      _end = TimeUtils.fromMinutes(end.clamp(0, 23 * 60 + 59));
      _priority = appPrefs.taskDefaults.defaultPriority;
      _reminderEnabled = appPrefs.taskDefaults.autoReminderForNewTasks;
      _reminderLeadMinutes = appPrefs.notifications.defaultLeadMinutes;
      _reminderSound = appPrefs.notifications.defaultSound;
    }
    if (widget.isEditing) {
      final db = context.read<AppDatabase>();
      final task = await db.tasksDao.watchById(widget.taskId!).first;
      if (task != null) {
        _titleController.text = task.title;
        _notesController.text = task.notes ?? '';
        _date = task.date;
        _start = TimeUtils.fromMinutes(task.startMinutes);
        _end = TimeUtils.fromMinutes(task.endMinutes);
        _priority = task.priority;
        _categoryId = task.categoryId;
        _projectId = task.projectId;
      }
      final reminder = await db.remindersDao.getForTask(widget.taskId!);
      if (reminder != null) {
        _reminderEnabled = reminder.isActive;
        _reminderLeadMinutes = reminder.leadMinutes;
        _reminderSound = AppNotificationSound.values[reminder.sound.index];
      }
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(context: context, initialTime: isStart ? _start : _end);
    if (picked != null) {
      setState(() {
        if (isStart) {
          _start = picked;
        } else {
          _end = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final db = context.read<AppDatabase>();
    final dayOnly = DateTime(_date.year, _date.month, _date.day);
    final startMin = TimeUtils.toMinutes(_start);
    var endMin = TimeUtils.toMinutes(_end);
    if (endMin <= startMin) endMin = startMin + 30; // حماية بسيطة من نهاية قبل البداية

    int taskId;
    if (widget.isEditing) {
      taskId = widget.taskId!;
      final existing = await db.tasksDao.watchById(taskId).first;
      if (existing != null) {
        await db.tasksDao.updateTask(existing.copyWith(
          title: _titleController.text.trim(),
          notes: drift.Value(_notesController.text.trim().isEmpty ? null : _notesController.text.trim()),
          date: dayOnly,
          startMinutes: startMin,
          endMinutes: endMin,
          priority: _priority,
          categoryId: drift.Value(_categoryId),
          projectId: drift.Value(_projectId),
          updatedAt: DateTime.now(),
        ));
      }
    } else {
      taskId = await db.tasksDao.insertTask(TasksCompanion.insert(
        title: _titleController.text.trim(),
        notes: drift.Value(_notesController.text.trim().isEmpty ? null : _notesController.text.trim()),
        date: dayOnly,
        startMinutes: startMin,
        endMinutes: endMin,
        priority: _priority,
        categoryId: drift.Value(_categoryId),
        projectId: drift.Value(_projectId),
      ));
    }

    await _syncReminder(db, taskId, dayOnly, startMin);
    if (mounted) context.pop();
  }

  /// ينشئ/يحدّث/يلغي تذكير المهمة الفعلي (سجل قاعدة البيانات + الإشعار المحلي المجدول)
  Future<void> _syncReminder(AppDatabase db, int taskId, DateTime dayOnly, int startMin) async {
    if (!_reminderEnabled) {
      await db.remindersDao.deleteForTask(taskId);
      await NotificationService.instance.cancelTaskReminder(taskId);
      return;
    }
    final taskStart = dayOnly.add(Duration(minutes: startMin));
    final scheduledAt = taskStart.subtract(Duration(minutes: _reminderLeadMinutes));
    await db.remindersDao.upsertForTask(
      taskId: taskId,
      title: _titleController.text.trim(),
      timeLabel: '${intl.DateFormat('d MMM', 'ar').format(scheduledAt)} - ${TimeUtils.formatMinutes(TimeUtils.toMinutes(TimeOfDay.fromDateTime(scheduledAt)))} (قبل $_reminderLeadMinutes د)',
      scheduledAt: scheduledAt,
      leadMinutes: _reminderLeadMinutes,
      sound: ReminderSound.values[_reminderSound.index],
    );
    await NotificationService.instance.requestPermissions();
    if (scheduledAt.isAfter(DateTime.now())) {
      await NotificationService.instance.scheduleTaskReminder(
        taskId: taskId,
        title: 'تذكير: ${_titleController.text.trim()}',
        body: 'تبدأ خلال $_reminderLeadMinutes دقيقة',
        scheduledAt: scheduledAt,
        sound: _reminderSound,
      );
    } else {
      await NotificationService.instance.cancelTaskReminder(taskId);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المهمة'),
        content: const Text('هل أنت متأكد من حذف هذه المهمة؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('حذف', style: TextStyle(color: AppColors.priorityHigh))),
        ],
      ),
    );
    if (confirmed == true && widget.taskId != null) {
      await context.read<AppDatabase>().tasksDao.softDelete(widget.taskId!);
      await context.read<AppDatabase>().remindersDao.deleteForTask(widget.taskId!);
      await NotificationService.instance.cancelTaskReminder(widget.taskId!);
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();

    return AppScaffold(
      title: widget.isEditing ? 'تعديل المهمة' : 'مهمة جديدة',
      showNav: false,
      actions: widget.isEditing
          ? [IconButton(onPressed: _delete, icon: const Icon(Icons.delete_outline, color: AppColors.priorityHigh))]
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'عنوان المهمة'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'الرجاء إدخال عنوان' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.calendar_today_outlined, size: 18),
                          label: Text('${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickTime(true),
                          icon: const Icon(Icons.access_time, size: 18),
                          label: Text('من ${_start.hour.toString().padLeft(2, '0')}:${_start.minute.toString().padLeft(2, '0')}'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickTime(false),
                          icon: const Icon(Icons.access_time_filled, size: 18),
                          label: Text('إلى ${_end.hour.toString().padLeft(2, '0')}:${_end.minute.toString().padLeft(2, '0')}'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('الأولوية', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  SegmentedButton<TaskPriority>(
                    segments: const [
                      ButtonSegment(value: TaskPriority.high, label: Text('عالية')),
                      ButtonSegment(value: TaskPriority.medium, label: Text('متوسطة')),
                      ButtonSegment(value: TaskPriority.low, label: Text('منخفضة')),
                    ],
                    selected: {_priority},
                    onSelectionChanged: (s) => setState(() => _priority = s.first),
                  ),
                  const SizedBox(height: 20),
                  Text('التصنيف', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  StreamBuilder<List<Category>>(
                    stream: db.categoriesDao.watchAll(),
                    builder: (context, snapshot) {
                      final cats = snapshot.data ?? [];
                      return DropdownButtonFormField<int?>(
                        initialValue: _categoryId,
                        decoration: const InputDecoration(hintText: 'بدون تصنيف'),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('بدون تصنيف')),
                          ...cats.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                        ],
                        onChanged: (v) => setState(() => _categoryId = v),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('المشروع', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  StreamBuilder<List<Project>>(
                    stream: db.projectsDao.watchAll(),
                    builder: (context, snapshot) {
                      final projects = snapshot.data ?? [];
                      return DropdownButtonFormField<int?>(
                        initialValue: _projectId,
                        decoration: const InputDecoration(hintText: 'بدون مشروع'),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('بدون مشروع')),
                          ...projects.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))),
                        ],
                        onChanged: (v) => setState(() => _projectId = v),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(labelText: 'ملاحظات (اختياري)'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  Text('التذكير', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(
                      children: [
                        SwitchListTile(
                          value: _reminderEnabled,
                          activeColor: AppColors.primary,
                          title: const Text('تفعيل تذكير لهذه المهمة'),
                          subtitle: const Text('إشعار فعلي على جهازك قبل بداية المهمة'),
                          secondary: const Icon(Icons.notifications_active_outlined, color: AppColors.primary),
                          onChanged: (v) => setState(() => _reminderEnabled = v),
                        ),
                        if (_reminderEnabled) ...[
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.timer_outlined),
                            title: const Text('قبل الموعد بـ'),
                            trailing: DropdownButton<int>(
                              value: _reminderLeadMinutes,
                              underline: const SizedBox(),
                              items: const [5, 10, 15, 30, 60]
                                  .map((m) => DropdownMenuItem(value: m, child: Text('$m دقيقة')))
                                  .toList(),
                              onChanged: (v) => setState(() => _reminderLeadMinutes = v ?? _reminderLeadMinutes),
                            ),
                          ),
                          ListTile(
                            leading: const Icon(Icons.music_note_outlined),
                            title: const Text('الصوت'),
                            trailing: DropdownButton<AppNotificationSound>(
                              value: _reminderSound,
                              underline: const SizedBox(),
                              items: AppNotificationSound.values
                                  .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                                  .toList(),
                              onChanged: (v) => setState(() => _reminderSound = v ?? _reminderSound),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size.fromHeight(52)),
                    child: Text(widget.isEditing ? 'حفظ التعديلات' : 'إضافة المهمة'),
                  ),
                ],
              ),
            ),
    );
  }
}
