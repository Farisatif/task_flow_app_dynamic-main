import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intl;
import '../core/database/database.dart';
import '../core/utils/icon_map.dart';
import '../widgets/app_scaffold.dart';
import '../core/theme/app_colors.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppScaffold(
      title: 'الملاحظات',
      showNav: false,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showNoteEditor(context, db),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'بحث في الملاحظات...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).cardTheme.color,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<Note>>(
                stream: db.notesDao.watchAll(),
                builder: (context, snapshot) {
                  var notes = snapshot.data ?? [];
                  if (_query.isNotEmpty) {
                    notes = notes.where((n) => n.title.contains(_query) || n.content.contains(_query)).toList();
                  }
                  if (notes.isEmpty) {
                    return Center(child: Text('لا توجد ملاحظات', style: Theme.of(context).textTheme.bodyMedium));
                  }
                  return MasonryLikeGrid(
                    items: notes.map((n) {
                      final bg = isDark ? Color(n.color).withValues(alpha: 0.18) : Color(n.color);
                      return GestureDetector(
                        onTap: () => _showNoteEditor(context, db, note: n),
                        onLongPress: () => _confirmDelete(context, db, n),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(n.title, style: Theme.of(context).textTheme.titleSmall),
                              const SizedBox(height: 8),
                              Text(n.content, style: Theme.of(context).textTheme.bodySmall, maxLines: 4, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 10),
                              Text(intl.DateFormat('yyyy-MM-dd').format(n.createdAt), style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppDatabase db, Note n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الملاحظة'),
        content: Text('هل تريد حذف "${n.title}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              db.notesDao.softDelete(n.id);
              Navigator.of(context).pop();
            },
            child: const Text('حذف', style: TextStyle(color: AppColors.priorityHigh)),
          ),
        ],
      ),
    );
  }

  void _showNoteEditor(BuildContext context, AppDatabase db, {Note? note}) {
    final titleController = TextEditingController(text: note?.title ?? '');
    final contentController = TextEditingController(text: note?.content ?? '');
    int color = note?.color ?? availableColorChoices.first;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(note == null ? 'ملاحظة جديدة' : 'تعديل الملاحظة', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'العنوان'), autofocus: true),
              const SizedBox(height: 12),
              TextField(controller: contentController, decoration: const InputDecoration(labelText: 'المحتوى'), maxLines: 4),
              const SizedBox(height: 16),
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
              const SizedBox(height: 20),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size.fromHeight(50)),
                onPressed: () async {
                  if (titleController.text.trim().isEmpty) return;
                  if (note == null) {
                    await db.notesDao.insertNote(NotesCompanion.insert(
                      title: titleController.text.trim(),
                      content: contentController.text.trim(),
                      color: color,
                    ));
                  } else {
                    await db.notesDao.updateNote(note.copyWith(
                      title: titleController.text.trim(),
                      content: contentController.text.trim(),
                      color: color,
                    ));
                  }
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: Text(note == null ? 'إضافة' : 'حفظ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// شبكة بسيطة بعمودين (بديل خفيف عن مكتبة Masonry خارجية)
class MasonryLikeGrid extends StatelessWidget {
  final List<Widget> items;
  const MasonryLikeGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final left = <Widget>[];
    final right = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      (i.isEven ? left : right).add(Padding(padding: const EdgeInsets.only(bottom: 12), child: items[i]));
    }
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Column(children: left)),
          const SizedBox(width: 12),
          Expanded(child: Column(children: right)),
        ],
      ),
    );
  }
}
