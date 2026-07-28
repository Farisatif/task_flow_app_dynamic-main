import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intl;
import '../core/database/database.dart';
import '../widgets/app_scaffold.dart';
import '../core/theme/app_colors.dart';

IconData _kindIcon(AttachmentKind k) {
  switch (k) {
    case AttachmentKind.image:
      return Icons.image_outlined;
    case AttachmentKind.pdf:
      return Icons.picture_as_pdf_outlined;
    case AttachmentKind.text:
      return Icons.description_outlined;
    case AttachmentKind.doc:
      return Icons.article_outlined;
    case AttachmentKind.chart:
      return Icons.bar_chart_outlined;
    case AttachmentKind.presentation:
      return Icons.slideshow_outlined;
  }
}

Color _kindColor(AttachmentKind k) {
  switch (k) {
    case AttachmentKind.image:
      return const Color(0xFF5B9DF9);
    case AttachmentKind.pdf:
      return const Color(0xFFFF6B81);
    case AttachmentKind.text:
      return const Color(0xFF4CD787);
    case AttachmentKind.doc:
      return const Color(0xFF7B6FF0);
    case AttachmentKind.chart:
      return const Color(0xFFFFB258);
    case AttachmentKind.presentation:
      return const Color(0xFFFF7EB3);
  }
}

String _kindLabel(AttachmentKind k) {
  switch (k) {
    case AttachmentKind.image:
      return 'صورة';
    case AttachmentKind.pdf:
      return 'PDF';
    case AttachmentKind.text:
      return 'نص';
    case AttachmentKind.doc:
      return 'مستند';
    case AttachmentKind.chart:
      return 'رسم بياني';
    case AttachmentKind.presentation:
      return 'عرض تقديمي';
  }
}

String _sizeLabel(int bytes) {
  if (bytes <= 0) return '-';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

class AttachmentsScreen extends StatelessWidget {
  const AttachmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    return AppScaffold(
      title: 'المرفقات',
      showNav: false,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddDialog(context, db),
        child: const Icon(Icons.upload_file, color: Colors.white),
      ),
      body: StreamBuilder<List<Attachment>>(
        stream: db.attachmentsDao.watchAll(),
        builder: (context, snapshot) {
          final attachments = snapshot.data ?? [];
          if (attachments.isEmpty) {
            return Center(child: Text('لا توجد مرفقات بعد', style: Theme.of(context).textTheme.bodyMedium));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: attachments
                .map((a) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: _kindColor(a.kind).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                          child: Icon(_kindIcon(a.kind), color: _kindColor(a.kind)),
                        ),
                        title: Text(a.name, style: Theme.of(context).textTheme.titleSmall),
                        subtitle: Text('${_sizeLabel(a.sizeBytes)} · ${intl.DateFormat('d MMM', 'ar').format(a.createdAt)}', style: Theme.of(context).textTheme.bodySmall),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.priorityHigh),
                          onPressed: () => db.attachmentsDao.deleteAttachment(a.id),
                        ),
                      ),
                    ))
                .toList(),
          );
        },
      ),
    );
  }

  void _showAddDialog(BuildContext context, AppDatabase db) {
    final nameController = TextEditingController();
    AttachmentKind kind = AttachmentKind.doc;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('إضافة مرفق'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(controller: nameController, autofocus: true, decoration: const InputDecoration(labelText: 'اسم الملف')),
              const SizedBox(height: 12),
              DropdownButtonFormField<AttachmentKind>(
                initialValue: kind,
                decoration: const InputDecoration(labelText: 'نوع الملف'),
                items: AttachmentKind.values.map((k) => DropdownMenuItem(value: k, child: Text(_kindLabel(k)))).toList(),
                onChanged: (v) => setDialogState(() => kind = v ?? kind),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('إلغاء')),
            FilledButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;
                await db.attachmentsDao.insertAttachment(AttachmentsCompanion.insert(name: nameController.text.trim(), kind: kind));
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }
}
