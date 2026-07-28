import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;
import '../core/database/database.dart';
import '../core/database/dao/projects_dao.dart';
import '../core/utils/icon_map.dart';
import '../widgets/app_scaffold.dart';
import '../core/theme/app_colors.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    return AppScaffold(
      title: 'المشاريع',
      showNav: false,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddProjectSheet(context, db),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<ProjectWithStats>>(
        stream: db.projectsDao.watchAllWithStats(),
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return Center(child: Text('لا توجد مشاريع بعد، أضف مشروعك الأول', style: Theme.of(context).textTheme.bodyMedium));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: items.map((pw) {
              final p = pw.project;
              final color = Color(p.color);
              final icon = iconFromName(p.iconName ?? '');
              return Dismissible(
                key: ValueKey('project-${p.id}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(color: AppColors.priorityHigh.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.delete_outline, color: AppColors.priorityHigh),
                ),
                confirmDismiss: (_) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('حذف المشروع'),
                      content: Text('هل تريد حذف "${p.name}"؟'),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('إلغاء')),
                        TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('حذف', style: TextStyle(color: AppColors.priorityHigh))),
                      ],
                    ),
                  );
                },
                onDismissed: (_) => db.projectsDao.softDelete(p.id),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
                          child: Icon(icon, color: color),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name, style: Theme.of(context).textTheme.titleSmall),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(value: pw.progress, minHeight: 8, backgroundColor: Theme.of(context).dividerColor, color: color),
                              ),
                              const SizedBox(height: 6),
                              Text('${pw.completedTasks}/${pw.totalTasks} مهمة - ${pw.progressPercent}%', style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
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

  void _showAddProjectSheet(BuildContext context, AppDatabase db) {
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
                Text('مشروع جديد', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                TextField(controller: controller, decoration: const InputDecoration(labelText: 'اسم المشروع'), autofocus: true),
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
                    await db.projectsDao.insertProject(ProjectsCompanion.insert(
                      name: controller.text.trim(),
                      color: color,
                      iconName: drift.Value(iconName),
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
