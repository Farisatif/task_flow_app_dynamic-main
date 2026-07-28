import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intl;
import '../core/database/database.dart';
import '../core/utils/task_extensions.dart';
import '../core/theme/app_colors.dart';
import '../widgets/app_scaffold.dart';

/// سلة المحذوفات: كل الجداول تستخدم حذفًا منطقيًا (is_deleted) لكن لم تكن
/// هناك أي واجهة لاستعادة العناصر — هذه الشاشة تسد تلك الفجوة لمهام النظام.
class TrashScreen extends StatelessWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    return AppScaffold(
      title: 'سلة المحذوفات',
      showNav: false,
      body: StreamBuilder<List<Task>>(
        stream: db.tasksDao.watchDeleted(),
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete_outline, size: 42, color: Theme.of(context).textTheme.bodySmall?.color),
                  const SizedBox(height: 10),
                  Text('السلة فارغة', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            );
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('${items.length} عنصر محذوف — يُحذف نهائيًا بعد ٣٠ يومًا',
                          style: Theme.of(context).textTheme.bodySmall),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.delete_forever_outlined, size: 18, color: AppColors.priorityHigh),
                      label: const Text('إفراغ السلة', style: TextStyle(color: AppColors.priorityHigh)),
                      onPressed: () => _confirmEmptyTrash(context, db),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  children: items.map((task) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: Container(
                          width: 6,
                          height: 40,
                          decoration: BoxDecoration(color: task.priorityColor(), borderRadius: BorderRadius.circular(4)),
                        ),
                        title: Text(task.title, style: Theme.of(context).textTheme.titleSmall),
                        subtitle: Text(
                          '${intl.DateFormat('d MMMM yyyy', 'ar').format(task.date)} · ${task.timeRange}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'استعادة',
                              icon: const Icon(Icons.restore_outlined, color: AppColors.accentGreen),
                              onPressed: () => db.tasksDao.restore(task.id),
                            ),
                            IconButton(
                              tooltip: 'حذف نهائي',
                              icon: const Icon(Icons.delete_forever_outlined, color: AppColors.priorityHigh),
                              onPressed: () => _confirmPermanentDelete(context, db, task),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmPermanentDelete(BuildContext context, AppDatabase db, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف نهائي'),
        content: Text('سيتم حذف "${task.title}" نهائيًا ولا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              db.tasksDao.permanentDelete(task.id);
              Navigator.of(context).pop();
            },
            child: const Text('حذف نهائي', style: TextStyle(color: AppColors.priorityHigh)),
          ),
        ],
      ),
    );
  }

  void _confirmEmptyTrash(BuildContext context, AppDatabase db) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إفراغ السلة'),
        content: const Text('سيتم حذف كل العناصر الموجودة في السلة نهائيًا. هل تريد المتابعة؟'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              db.tasksDao.emptyTrash();
              Navigator.of(context).pop();
            },
            child: const Text('إفراغ', style: TextStyle(color: AppColors.priorityHigh)),
          ),
        ],
      ),
    );
  }
}
