import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart' as intl;
import '../core/database/database.dart';
import '../core/services/app_preferences.dart';
import '../core/utils/time_utils.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/task_tile.dart';
import '../core/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    final dateStr = intl.DateFormat('d MMMM yyyy', 'ar').format(DateTime.now());

    return AppScaffold(
      title: '',
      navIndex: 0,
      showNav: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/quick-add'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<Task>>(
        stream: db.tasksDao.watchTasksForDate(DateTime.now()),
        builder: (context, snapshot) {
          final tasks = snapshot.data ?? [];
          final total = tasks.length;
          final completed = tasks.where((t) => t.status == TaskStatus.completed).length;
          final inProgress = tasks.where((t) => t.status == TaskStatus.inProgress).length;
          final pending = tasks.where((t) => t.status == TaskStatus.pending).length;
          final progress = total == 0 ? 0.0 : completed / total;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    child: const Icon(Icons.person, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('مرحبًا أحمد 👋', style: Theme.of(context).textTheme.titleLarge),
                        Text('جاهز ليوم منتج؟', style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  IconButton(onPressed: () => context.push('/search'), icon: const Icon(Icons.search)),
                  IconButton(onPressed: () => context.push('/reminders'), icon: const Icon(Icons.notifications_outlined)),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(24)),
                child: Row(
                  children: [
                    CircularPercentIndicator(
                      radius: 40,
                      lineWidth: 8,
                      percent: progress.clamp(0, 1),
                      animation: true,
                      circularStrokeCap: CircularStrokeCap.round,
                      backgroundColor: Colors.white.withValues(alpha: 0.25),
                      progressColor: Colors.white,
                      center: Text('${(progress * 100).round()}%',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('إنجاز اليوم', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(dateStr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _freeTimeCard(context, tasks),
              const SizedBox(height: 16),
              Row(
                children: [
                  _miniStat(context, '$total', 'المهام', AppColors.primary),
                  _miniStat(context, '$completed', 'منجزة', AppColors.accentGreen),
                  _miniStat(context, '$inProgress', 'مستمرة', AppColors.accentOrange),
                  _miniStat(context, '$pending', 'منتظرة', AppColors.accentPink),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('مهام اليوم', style: Theme.of(context).textTheme.titleMedium),
                  TextButton(onPressed: () => context.push('/today'), child: const Text('عرض الكل')),
                ],
              ),
              if (tasks.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('لا توجد مهام اليوم بعد', style: Theme.of(context).textTheme.bodyMedium)),
                )
              else
                ...tasks.take(4).map((t) => TaskTile(
                      task: t,
                      onTap: () => context.push('/task-details/${t.id}'),
                      onCheck: (v) => db.tasksDao.setStatus(t.id, v == true ? TaskStatus.completed : TaskStatus.pending),
                    )),
              const SizedBox(height: 8),
              _quickAccessGrid(context),
            ],
          );
        },
      ),
    );
  }

  /// بطاقة داشبورد مميزة: تحسب الوقت المشغول والفارغ الفعلي لليوم ضمن ساعات
  /// العمل المُعدّة، وتعرض أقرب تذكير قادم — كلاهما من بيانات حقيقية
  Widget _freeTimeCard(BuildContext context, List<Task> todayTasks) {
    final appPrefs = context.watch<AppPreferences>();
    final workStart = appPrefs.taskDefaults.workDayStartHour * 60;
    final workEnd = appPrefs.taskDefaults.workDayEndHour * 60;
    final totalWorkMinutes = (workEnd - workStart).clamp(0, 24 * 60);

    var busyMinutes = 0;
    for (final t in todayTasks) {
      final start = t.startMinutes.clamp(workStart, workEnd);
      final end = t.endMinutes.clamp(workStart, workEnd);
      if (end > start) busyMinutes += end - start;
    }
    final freeMinutes = (totalWorkMinutes - busyMinutes).clamp(0, totalWorkMinutes);
    final busyRatio = totalWorkMinutes == 0 ? 0.0 : (busyMinutes / totalWorkMinutes).clamp(0.0, 1.0);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => context.push('/weekly-planner'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event_available_outlined, size: 18, color: AppColors.accentGreen),
                const SizedBox(width: 6),
                Text('وقتك اليوم', style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                Text('${TimeUtils.formatMinutes(workStart)} - ${TimeUtils.formatMinutes(workEnd)}',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: busyRatio,
                minHeight: 8,
                backgroundColor: AppColors.accentGreen.withValues(alpha: 0.18),
                valueColor: const AlwaysStoppedAnimation(AppColors.priorityMedium),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.circle, size: 8, color: AppColors.priorityMedium),
                const SizedBox(width: 4),
                Text('${(busyMinutes / 60).toStringAsFixed(1)} ساعة مشغولة', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(width: 14),
                Icon(Icons.circle, size: 8, color: AppColors.accentGreen),
                const SizedBox(width: 4),
                Text('${(freeMinutes / 60).toStringAsFixed(1)} ساعة فاضية', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            StreamBuilder<List<Reminder>>(
              stream: context.read<AppDatabase>().remindersDao.watchUpcoming(),
              builder: (context, snapshot) {
                final upcoming = snapshot.data ?? [];
                if (upcoming.isEmpty) return const SizedBox.shrink();
                final next = upcoming.first;
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications_active_outlined, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text('أقرب تذكير: ${next.title} — ${next.timeLabel}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(BuildContext context, String value, String label, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          children: [
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color)),
            const SizedBox(height: 2),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _quickAccessGrid(BuildContext context) {
    final items = [
      ('الأهداف', Icons.flag_outlined, AppColors.primary, '/goals'),
      ('العادات', Icons.repeat, AppColors.accentGreen, '/habits'),
      ('المشاريع', Icons.folder_outlined, AppColors.accentBlue, '/projects'),
      ('مؤقت التركيز', Icons.timer_outlined, AppColors.accentOrange, '/focus-timer'),
      ('الملاحظات', Icons.sticky_note_2_outlined, AppColors.accentPink, '/notes'),
      ('المخطط الأسبوعي', Icons.calendar_view_week_outlined, AppColors.secondary, '/weekly-planner'),
      ('الإحصائيات', Icons.insights_outlined, AppColors.secondary, '/statistics'),
      ('سلة المحذوفات', Icons.delete_outline, AppColors.priorityHigh, '/trash'),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.05),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final it = items[i];
        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => context.push(it.$4),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: it.$3.withValues(alpha: 0.15), shape: BoxShape.circle),
                  child: Icon(it.$2, color: it.$3),
                ),
                const SizedBox(height: 8),
                Text(it.$1, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
              ],
            ),
          ),
        );
      },
    );
  }
}
