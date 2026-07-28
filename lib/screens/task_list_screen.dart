import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/database/database.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/task_tile.dart';
import '../core/theme/app_colors.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  String _filter = 'الكل';

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    final filters = ['الكل', 'اليوم', 'الأسبوع'];

    return AppScaffold(
      title: 'قائمة المهام',
      navIndex: 2,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/task-form'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<Task>>(
        stream: db.tasksDao.watchAll(),
        builder: (context, snapshot) {
          var tasks = snapshot.data ?? [];
          final now = DateTime.now();
          if (_filter == 'اليوم') {
            tasks = tasks.where((t) => t.date.year == now.year && t.date.month == now.month && t.date.day == now.day).toList();
          } else if (_filter == 'الأسبوع') {
            final weekEnd = now.add(const Duration(days: 7));
            tasks = tasks.where((t) => t.date.isAfter(now.subtract(const Duration(days: 1))) && t.date.isBefore(weekEnd)).toList();
          }

          final high = tasks.where((t) => t.priority == TaskPriority.high).toList();
          final medium = tasks.where((t) => t.priority == TaskPriority.medium).toList();
          final low = tasks.where((t) => t.priority == TaskPriority.low).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: filters
                    .map((f) => Padding(
                          padding: const EdgeInsetsDirectional.only(end: 8),
                          child: ChoiceChip(
                            label: Text(f),
                            selected: _filter == f,
                            onSelected: (_) => setState(() => _filter = f),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              if (tasks.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: Text('لا توجد مهام مطابقة', style: Theme.of(context).textTheme.bodyMedium)),
                ),
              if (high.isNotEmpty) ...[
                _priorityHeader(context, 'الأولوية العالية', AppColors.priorityHigh),
                ...high.map((t) => TaskTile(
                      task: t,
                      onTap: () => context.push('/task-details/${t.id}'),
                      onCheck: (v) => db.tasksDao.setStatus(t.id, v == true ? TaskStatus.completed : TaskStatus.pending),
                    )),
              ],
              if (medium.isNotEmpty) ...[
                _priorityHeader(context, 'الأولوية المتوسطة', AppColors.priorityMedium),
                ...medium.map((t) => TaskTile(
                      task: t,
                      onTap: () => context.push('/task-details/${t.id}'),
                      onCheck: (v) => db.tasksDao.setStatus(t.id, v == true ? TaskStatus.completed : TaskStatus.pending),
                    )),
              ],
              if (low.isNotEmpty) ...[
                _priorityHeader(context, 'الأولوية المنخفضة', AppColors.priorityLow),
                ...low.map((t) => TaskTile(
                      task: t,
                      onTap: () => context.push('/task-details/${t.id}'),
                      onCheck: (v) => db.tasksDao.setStatus(t.id, v == true ? TaskStatus.completed : TaskStatus.pending),
                    )),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _priorityHeader(BuildContext context, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.circle, size: 10, color: color),
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: color)),
        ],
      ),
    );
  }
}
