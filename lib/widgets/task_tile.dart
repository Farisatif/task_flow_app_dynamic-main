import 'package:flutter/material.dart';
import '../core/database/database.dart';
import '../core/utils/task_extensions.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final ValueChanged<bool?>? onCheck;

  const TaskTile({super.key, required this.task, this.onTap, this.onCheck});

  @override
  Widget build(BuildContext context) {
    final done = task.status == TaskStatus.completed;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          children: [
            Container(width: 4, height: 38, decoration: BoxDecoration(color: task.priorityColor(), borderRadius: BorderRadius.circular(4))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          decoration: done ? TextDecoration.lineThrough : null,
                          color: done ? Theme.of(context).textTheme.bodySmall?.color : null,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(task.timeRange, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: task.priorityColor().withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
              child: Text(task.priorityLabel(), style: TextStyle(color: task.priorityColor(), fontSize: 11, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 8),
            Checkbox(
              value: done,
              onChanged: onCheck,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
          ],
        ),
      ),
    );
  }
}
