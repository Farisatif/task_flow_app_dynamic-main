import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import 'package:intl/intl.dart' as intl;
import '../core/database/database.dart';
import '../core/services/notification_service.dart';
import '../core/services/notification_prefs.dart';
import '../core/services/app_preferences.dart';
import '../widgets/app_scaffold.dart';
import '../core/theme/app_colors.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  static const int _standaloneIdOffset = 100000;

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    return AppScaffold(
      title: 'التذكيرات',
      showNav: false,
      actions: [
        IconButton(
          tooltip: 'إعدادات الإشعارات والأصوات',
          icon: const Icon(Icons.tune_outlined),
          onPressed: () => context.push('/notification-settings'),
        ),
      ],
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddDialog(context, db),
        child: const Icon(Icons.add_alert_outlined, color: Colors.white),
      ),
      body: StreamBuilder<List<Reminder>>(
        stream: db.remindersDao.watchAll(),
        builder: (context, snapshot) {
          final reminders = snapshot.data ?? [];
          if (reminders.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 42, color: Theme.of(context).textTheme.bodySmall?.color),
                  const SizedBox(height: 10),
                  Text('لا توجد تذكيرات بعد', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text('تذكيرات المهام تُضاف تلقائيًا من نموذج المهمة، أو أضف تذكيرًا مستقلًا هنا',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            );
          }
          final now = DateTime.now();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: reminders.map((r) {
              final isPast = r.scheduledAt != null && r.scheduledAt!.isBefore(now);
              return Dismissible(
                key: ValueKey('reminder-${r.id}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(color: AppColors.priorityHigh.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.delete_outline, color: AppColors.priorityHigh),
                ),
                onDismissed: (_) async {
                  await db.remindersDao.deleteReminder(r.id);
                  if (r.taskId == null) {
                    await NotificationService.instance.cancelTaskReminder(_standaloneIdOffset + r.id);
                  } else {
                    await NotificationService.instance.cancelTaskReminder(r.taskId!);
                  }
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: SwitchListTile(
                    value: r.isActive,
                    activeColor: AppColors.primary,
                    onChanged: (v) async {
                      await db.remindersDao.setActive(r.id, v);
                      if (v && r.scheduledAt != null) {
                        await NotificationService.instance.scheduleTaskReminder(
                          taskId: r.taskId ?? (_standaloneIdOffset + r.id),
                          title: r.title,
                          body: 'حان وقت: ${r.title}',
                          scheduledAt: r.scheduledAt!,
                          sound: AppNotificationSound.values[r.sound.index],
                        );
                      } else {
                        await NotificationService.instance
                            .cancelTaskReminder(r.taskId ?? (_standaloneIdOffset + r.id));
                      }
                    },
                    title: Text(r.title, style: Theme.of(context).textTheme.titleSmall),
                    subtitle: Text(
                      isPast ? '${r.timeLabel} · مضى وقتها' : r.timeLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isPast ? AppColors.priorityHigh : null),
                    ),
                    secondary: Icon(
                      r.taskId != null ? Icons.link : Icons.notifications_active_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void _showAddDialog(BuildContext context, AppDatabase db) {
    final titleController = TextEditingController();
    DateTime date = DateTime.now();
    TimeOfDay time = TimeOfDay.fromDateTime(DateTime.now().add(const Duration(minutes: 30)));
    final prefs = context.read<AppPreferences>().notifications;
    AppNotificationSound sound = prefs.defaultSound;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('تذكير جديد'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(controller: titleController, autofocus: true, decoration: const InputDecoration(labelText: 'العنوان')),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today_outlined, size: 18),
                    label: Text(intl.DateFormat('EEEE d MMMM', 'ar').format(date)),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: date,
                        firstDate: DateTime.now().subtract(const Duration(days: 1)),
                        lastDate: DateTime.now().add(const Duration(days: 730)),
                      );
                      if (picked != null) setState(() => date = picked);
                    },
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.access_time, size: 18),
                    label: Text(time.format(context)),
                    onPressed: () async {
                      final picked = await showTimePicker(context: context, initialTime: time);
                      if (picked != null) setState(() => time = picked);
                    },
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<AppNotificationSound>(
                    initialValue: sound,
                    decoration: const InputDecoration(labelText: 'الصوت'),
                    items: AppNotificationSound.values
                        .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                        .toList(),
                    onChanged: (v) => setState(() => sound = v ?? sound),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('إلغاء')),
              FilledButton(
                onPressed: () async {
                  if (titleController.text.trim().isEmpty) return;
                  final scheduledAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                  final id = await db.remindersDao.insertReminder(RemindersCompanion.insert(
                    title: titleController.text.trim(),
                    timeLabel: '${intl.DateFormat('d MMM', 'ar').format(scheduledAt)} - ${time.format(context)}',
                    scheduledAt: drift.Value(scheduledAt),
                    sound: drift.Value(ReminderSound.values[sound.index]),
                  ));
                  await NotificationService.instance.requestPermissions();
                  await NotificationService.instance.scheduleTaskReminder(
                    taskId: _standaloneIdOffset + id,
                    title: titleController.text.trim(),
                    body: 'حان وقت: ${titleController.text.trim()}',
                    scheduledAt: scheduledAt,
                    sound: sound,
                  );
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: const Text('إضافة'),
              ),
            ],
          );
        },
      ),
    );
  }
}
