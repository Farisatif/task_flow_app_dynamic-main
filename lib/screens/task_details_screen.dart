import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/database/database.dart';
import '../core/utils/task_extensions.dart';
import '../widgets/app_scaffold.dart';
import '../core/theme/app_colors.dart';

class TaskDetailsScreen extends StatelessWidget {
  final int taskId;
  const TaskDetailsScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();

    return StreamBuilder<Task?>(
      stream: db.tasksDao.watchById(taskId),
      builder: (context, snapshot) {
        final task = snapshot.data;
        if (snapshot.connectionState == ConnectionState.waiting && task == null) {
          return const AppScaffold(title: 'تفاصيل المهمة', showNav: false, body: Center(child: CircularProgressIndicator()));
        }
        if (task == null) {
          return AppScaffold(
            title: 'تفاصيل المهمة',
            showNav: false,
            body: Center(child: Text('تم حذف هذه المهمة', style: Theme.of(context).textTheme.bodyMedium)),
          );
        }

        final progress = task.status == TaskStatus.completed
            ? 1.0
            : task.status == TaskStatus.inProgress
                ? 0.6
                : 0.0;

        return AppScaffold(
          title: 'تفاصيل المهمة',
          showNav: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.priorityHigh),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('حذف المهمة'),
                    content: const Text('هل أنت متأكد من حذف هذه المهمة؟'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('إلغاء')),
                      TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('حذف', style: TextStyle(color: AppColors.priorityHigh))),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await db.tasksDao.softDelete(task.id);
                  if (context.mounted) context.pop();
                }
              },
            ),
          ],
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(child: Text(task.title, style: Theme.of(context).textTheme.headlineSmall)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: task.priorityColor().withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                    child: Text(task.priorityLabel(), style: TextStyle(color: task.priorityColor(), fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _infoRow(context, Icons.calendar_today_outlined, 'التاريخ', '${task.date.year}-${task.date.month.toString().padLeft(2, '0')}-${task.date.day.toString().padLeft(2, '0')}'),
                      const Divider(height: 24),
                      _infoRow(context, Icons.access_time, 'الوقت', task.timeRange),
                      const Divider(height: 24),
                      _infoRow(context, Icons.flag_outlined, 'الحالة', _statusLabel(task.status)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('التقدم', style: Theme.of(context).textTheme.titleSmall),
                  Text('${(progress * 100).round()}%', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(value: progress, minHeight: 10, backgroundColor: Theme.of(context).dividerColor, color: AppColors.primary),
              ),
              const SizedBox(height: 20),
              if (task.notes != null && task.notes!.isNotEmpty) ...[
                Text('ملاحظات', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Theme.of(context).cardTheme.color, borderRadius: BorderRadius.circular(14), border: Border.all(color: Theme.of(context).dividerColor)),
                  child: Text(task.notes!, style: Theme.of(context).textTheme.bodyMedium),
                ),
                const SizedBox(height: 20),
              ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/task-form/${task.id}'),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('تعديل'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: task.status == TaskStatus.completed ? AppColors.accentOrange : AppColors.accentGreen),
                      onPressed: () => db.tasksDao.setStatus(
                        task.id,
                        task.status == TaskStatus.completed ? TaskStatus.pending : TaskStatus.completed,
                      ),
                      icon: Icon(task.status == TaskStatus.completed ? Icons.replay : Icons.check),
                      label: Text(task.status == TaskStatus.completed ? 'إعادة فتح' : 'إتمام المهمة'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _statusLabel(TaskStatus s) {
    switch (s) {
      case TaskStatus.completed:
        return 'مكتملة';
      case TaskStatus.inProgress:
        return 'قيد التنفيذ';
      case TaskStatus.pending:
        return 'قيد الانتظار';
    }
  }

  Widget _infoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Text(value, style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }
}
