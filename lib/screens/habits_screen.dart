import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/database/database.dart';
import '../core/database/dao/habits_dao.dart';
import '../core/utils/icon_map.dart';
import '../widgets/app_scaffold.dart';
import '../core/theme/app_colors.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  static const days = ['س', 'ح', 'ن', 'ث', 'ر', 'خ', 'ج'];

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    return AppScaffold(
      title: 'العادات',
      showNav: false,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddHabitSheet(context, db),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<HabitWithWeek>>(
        stream: db.habitsDao.watchAllWithWeek(),
        builder: (context, snapshot) {
          final habits = snapshot.data ?? [];
          if (habits.isEmpty) {
            return Center(child: Text('لا توجد عادات بعد، أضف أول عادة لك', style: Theme.of(context).textTheme.bodyMedium));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: habits.map((hw) {
              final h = hw.habit;
              final color = Color(h.color);
              final icon = iconFromName(h.iconName);
              final today = DateTime.now();
              return Dismissible(
                key: ValueKey('habit-${h.id}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(color: AppColors.priorityHigh.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.delete_outline, color: AppColors.priorityHigh),
                ),
                confirmDismiss: (_) => _confirmDelete(context, 'حذف العادة "${h.title}"؟'),
                onDismissed: (_) => db.habitsDao.softDelete(h.id),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
                              child: Icon(icon, color: color, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: Text(h.title, style: Theme.of(context).textTheme.titleSmall)),
                            Text('${hw.doneCount}/7', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(7, (i) {
                            final dayDate = today.subtract(Duration(days: 6 - i));
                            final done = hw.last7Days[i];
                            return GestureDetector(
                              onTap: () => db.habitsDao.toggleDay(h.id, dayDate, !done),
                              child: Column(
                                children: [
                                  Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(color: done ? color : Theme.of(context).dividerColor, shape: BoxShape.circle),
                                    child: done ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(days[i], style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                            );
                          }),
                        ),
                      ],
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

  Future<bool?> _confirmDelete(BuildContext context, String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('حذف', style: TextStyle(color: AppColors.priorityHigh))),
        ],
      ),
    );
  }

  void _showAddHabitSheet(BuildContext context, AppDatabase db) {
    final controller = TextEditingController();
    String iconName = availableIconChoices.first.$1;
    int color = availableColorChoices.first;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) => Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('عادة جديدة', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                TextField(controller: controller, decoration: const InputDecoration(labelText: 'اسم العادة'), autofocus: true),
                const SizedBox(height: 16),
                Text('الأيقونة', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  children: availableIconChoices.map((opt) {
                    final selected = opt.$1 == iconName;
                    return GestureDetector(
                      onTap: () => setSheetState(() => iconName = opt.$1),
                      child: CircleAvatar(
                        backgroundColor: selected ? AppColors.primary : Theme.of(context).dividerColor,
                        child: Icon(opt.$2, color: selected ? Colors.white : null, size: 18),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text('اللون', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  children: availableColorChoices.map((c) {
                    final selected = c == color;
                    return GestureDetector(
                      onTap: () => setSheetState(() => color = c),
                      child: CircleAvatar(
                        backgroundColor: Color(c),
                        child: selected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size.fromHeight(50)),
                  onPressed: () async {
                    if (controller.text.trim().isEmpty) return;
                    await db.habitsDao.insertHabit(HabitsCompanion.insert(
                      title: controller.text.trim(),
                      color: color,
                      iconName: iconName,
                    ));
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: const Text('إضافة'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
