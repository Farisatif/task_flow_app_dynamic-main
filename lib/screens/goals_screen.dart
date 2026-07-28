import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/database/database.dart';
import '../widgets/app_scaffold.dart';
import '../core/theme/app_colors.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    return AppScaffold(
      title: 'الأهداف',
      showNav: false,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddGoalDialog(context, db),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<Goal>>(
        stream: db.goalsDao.watchAll(),
        builder: (context, snapshot) {
          final goals = snapshot.data ?? [];
          if (goals.isEmpty) {
            return Center(child: Text('لا توجد أهداف بعد، أضف هدفك الأول', style: Theme.of(context).textTheme.bodyMedium));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: goals.map((goal) => _GoalCard(goal: goal, db: db)).toList(),
          );
        },
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context, AppDatabase db) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('هدف جديد'),
        content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(labelText: 'عنوان الهدف')),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              await db.goalsDao.insertGoal(GoalsCompanion.insert(title: controller.text.trim()));
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final Goal goal;
  final AppDatabase db;
  const _GoalCard({required this.goal, required this.db});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(goal.title, style: Theme.of(context).textTheme.titleLarge)),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.priorityHigh),
                  onPressed: () => db.goalsDao.softDelete(goal.id),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(value: goal.progress, minHeight: 12, backgroundColor: Theme.of(context).dividerColor, color: AppColors.primary),
            ),
            const SizedBox(height: 6),
            Text('${(goal.progress * 100).round()}%', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.primary)),
            const SizedBox(height: 16),
            Text('أهداف فرعية', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            StreamBuilder<List<SubGoal>>(
              stream: db.goalsDao.watchSubGoals(goal.id),
              builder: (context, snapshot) {
                final subGoals = snapshot.data ?? [];
                return Column(
                  children: [
                    ...subGoals.map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 32,
                                height: 32,
                                child: CircularProgressIndicator(
                                  value: s.progress,
                                  strokeWidth: 3,
                                  backgroundColor: Theme.of(context).dividerColor,
                                  color: s.progress >= 1 ? AppColors.accentGreen : AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(s.title, style: Theme.of(context).textTheme.bodyMedium)),
                              Text('${(s.progress * 100).round()}%', style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        )),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => _showAddSubGoalDialog(context, db, goal.id),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('هدف فرعي'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSubGoalDialog(BuildContext context, AppDatabase db, int goalId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('هدف فرعي جديد'),
        content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(labelText: 'العنوان')),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              await db.goalsDao.insertSubGoal(SubGoalsCompanion.insert(goalId: goalId, title: controller.text.trim()));
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}
