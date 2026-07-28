import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intl;
import '../core/database/database.dart';
import '../widgets/app_scaffold.dart';
import '../core/theme/app_colors.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    final dateStr = intl.DateFormat('EEEE، d MMMM', 'ar').format(DateTime.now());
    final hours = List.generate(15, (i) => i + 7); // 07:00 - 21:00

    return AppScaffold(
      title: 'اليوم',
      navIndex: 1,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/task-form'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dateStr, style: Theme.of(context).textTheme.titleMedium),
                TextButton.icon(
                  onPressed: () => context.push('/calendar'),
                  icon: const Icon(Icons.calendar_month_outlined, size: 18),
                  label: const Text('التقويم'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: db.tasksDao.watchTasksForDate(DateTime.now()),
              builder: (context, snapshot) {
                final tasks = snapshot.data ?? [];
                final Map<int, List<Task>> byHour = {};
                for (final t in tasks) {
                  byHour.putIfAbsent(t.startMinutes ~/ 60, () => []).add(t);
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: hours.length,
                  itemBuilder: (context, i) {
                    final hour = hours[i];
                    final tasksAtHour = byHour[hour] ?? [];
                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 50,
                            child: Text('${hour.toString().padLeft(2, '0')}:00', style: Theme.of(context).textTheme.bodySmall),
                          ),
                          Column(
                            children: [
                              Container(width: 2, height: 8, color: Theme.of(context).dividerColor),
                              Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                              Expanded(child: Container(width: 2, color: Theme.of(context).dividerColor)),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 18),
                              child: tasksAtHour.isEmpty
                                  ? const SizedBox(height: 20)
                                  : Column(
                                      children: tasksAtHour
                                          .map((t) => InkWell(
                                                onTap: () => context.push('/task-details/${t.id}'),
                                                child: Container(
                                                  width: double.infinity,
                                                  margin: const EdgeInsets.only(bottom: 8),
                                                  padding: const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: _priorityColor(t.priority).withValues(alpha: 0.12),
                                                    borderRadius: BorderRadius.circular(14),
                                                    border: Border(right: BorderSide(color: _priorityColor(t.priority), width: 3)),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(t.title, style: Theme.of(context).textTheme.titleSmall),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        '${(t.startMinutes ~/ 60).toString().padLeft(2, '0')}:${(t.startMinutes % 60).toString().padLeft(2, '0')} - '
                                                        '${(t.endMinutes ~/ 60).toString().padLeft(2, '0')}:${(t.endMinutes % 60).toString().padLeft(2, '0')}',
                                                        style: Theme.of(context).textTheme.bodySmall,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ))
                                          .toList(),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _priorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.high:
        return const Color(0xFFFF6B81);
      case TaskPriority.medium:
        return const Color(0xFFFFB258);
      case TaskPriority.low:
        return const Color(0xFF4CD787);
    }
  }
}
