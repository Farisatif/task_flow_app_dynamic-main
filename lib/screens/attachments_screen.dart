import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

import '../core/database/database.dart';
import '../core/theme/app_colors.dart';
import '../widgets/app_scaffold.dart';

IconData _kindIcon(AttachmentKind kind) {
  switch (kind) {
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

Color _kindColor(AttachmentKind kind) {
  switch (kind) {
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

String _kindLabel(AttachmentKind kind) {
  switch (kind) {
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
  if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(0)} KB';
  }
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

enum _AttachmentFilter { all, image, pdf, text, doc, chart, presentation }

extension on _AttachmentFilter {
  String get label {
    switch (this) {
      case _AttachmentFilter.all:
        return 'الكل';
      case _AttachmentFilter.image:
        return 'صور';
      case _AttachmentFilter.pdf:
        return 'PDF';
      case _AttachmentFilter.text:
        return 'نصوص';
      case _AttachmentFilter.doc:
        return 'مستندات';
      case _AttachmentFilter.chart:
        return 'رسوم';
      case _AttachmentFilter.presentation:
        return 'عروض';
    }
  }

  AttachmentKind? get kind {
    switch (this) {
      case _AttachmentFilter.all:
        return null;
      case _AttachmentFilter.image:
        return AttachmentKind.image;
      case _AttachmentFilter.pdf:
        return AttachmentKind.pdf;
      case _AttachmentFilter.text:
        return AttachmentKind.text;
      case _AttachmentFilter.doc:
        return AttachmentKind.doc;
      case _AttachmentFilter.chart:
        return AttachmentKind.chart;
      case _AttachmentFilter.presentation:
        return AttachmentKind.presentation;
    }
  }
}

class AttachmentsScreen extends StatefulWidget {
  const AttachmentsScreen({super.key});

  @override
  State<AttachmentsScreen> createState() => _AttachmentsScreenState();
}

class _AttachmentsScreenState extends State<AttachmentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  _AttachmentFilter _filter = _AttachmentFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Attachment> _applyFilters(List<Attachment> attachments) {
    final query = _searchController.text.trim().toLowerCase();
    final selectedKind = _filter.kind;

    return attachments.where((attachment) {
      final matchesQuery = query.isEmpty ||
          attachment.name.toLowerCase().contains(query);

      final matchesKind =
          selectedKind == null ? true : attachment.kind == selectedKind;

      return matchesQuery && matchesKind;
    }).toList();
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AppDatabase db,
    Attachment attachment,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف المرفق'),
        content: Text('هل تريد حذف "${attachment.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'حذف',
              style: TextStyle(color: AppColors.priorityHigh),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await db.attachmentsDao.deleteAttachment(attachment.id);
    }
  }

  Future<void> _showAddSheet(BuildContext context, AppDatabase db) async {
    final nameController = TextEditingController();
    AttachmentKind selectedKind = AttachmentKind.doc;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final theme = Theme.of(context);
            final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

            return Container(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomPadding),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.dividerColor.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.upload_file_rounded,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'إضافة مرفق',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'أضف ملفًا جديدًا وحدد نوعه بسرعة',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: nameController,
                      autofocus: true,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: 'اسم الملف',
                        hintText: 'مثال: خطة المشروع النهائية',
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest
                            .withOpacity(0.35),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'نوع الملف',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<AttachmentKind>(
                      value: selectedKind,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest
                            .withOpacity(0.35),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: AttachmentKind.values
                          .map(
                            (kind) => DropdownMenuItem(
                              value: kind,
                              child: Row(
                                children: [
                                  Icon(
                                    _kindIcon(kind),
                                    size: 18,
                                    color: _kindColor(kind),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(_kindLabel(kind)),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setSheetState(() => selectedKind = value);
                      },
                    ),
                    const SizedBox(height: 18),
                    _PreviewCard(
                      name: nameController.text.trim().isEmpty
                          ? 'معاينة الملف'
                          : nameController.text.trim(),
                      kind: selectedKind,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            style: OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text('إلغاء'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () async {
                              final name = nameController.text.trim();
                              if (name.isEmpty) return;

                              await db.attachmentsDao.insertAttachment(
                                AttachmentsCompanion.insert(
                                  name: name,
                                  kind: selectedKind,
                                  // إذا كان جدولك يحتوي على sizeBytes في الـ Companion
                                  // فمرّره بهذا الشكل:
                                  // sizeBytes: Value(size),
                                ),
                              );

                              if (!mounted) return;
                              Navigator.of(sheetContext).pop();
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text('إضافة'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'المرفقات',
      showNav: false,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddSheet(context, db),
        icon: const Icon(Icons.upload_file_rounded, color: Colors.white),
        label: const Text(
          'مرفق جديد',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<List<Attachment>>(
        stream: db.attachmentsDao.watchAll(),
        builder: (context, snapshot) {
          final attachments = snapshot.data ?? [];
          final filtered = _applyFilters(attachments);

          final total = attachments.length;
          final imageCount =
              attachments.where((a) => a.kind == AttachmentKind.image).length;

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                _HeaderCard(
                  totalAttachments: total,
                  imageCount: imageCount,
                  visibleCount: filtered.length,
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'بحث في المرفقات...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                        color: theme.dividerColor.withOpacity(0.08),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _AttachmentFilter.values.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final item = _AttachmentFilter.values[index];
                      final selected = item == _filter;

                      return ChoiceChip(
                        label: Text(item.label),
                        selected: selected,
                        onSelected: (_) => setState(() => _filter = item),
                        selectedColor: AppColors.primary.withOpacity(0.16),
                        labelStyle: TextStyle(
                          color: selected
                              ? AppColors.primary
                              : theme.textTheme.bodyMedium?.color,
                          fontWeight: FontWeight.w700,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                          side: BorderSide(
                            color: selected
                                ? AppColors.primary
                                : theme.dividerColor.withOpacity(0.10),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                if (attachments.isEmpty)
                  _EmptyState(
                    title: 'لا توجد مرفقات بعد',
                    subtitle: 'ارفع أول ملف وابدأ تنظيم الموارد داخل التطبيق',
                    icon: Icons.folder_zip_outlined,
                    onAdd: () => _showAddSheet(context, db),
                  )
                else if (filtered.isEmpty)
                  _EmptyState(
                    title: 'لا توجد نتائج',
                    subtitle: 'جرّب بحثًا آخر أو غيّر نوع الملف',
                    icon: Icons.search_off_rounded,
                    onAdd: () => _showAddSheet(context, db),
                  )
                else
                  ...filtered.map(
                    (attachment) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _AttachmentTile(
                        attachment: attachment,
                        onDelete: () => _confirmDelete(
                          context,
                          db,
                          attachment,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final int totalAttachments;
  final int imageCount;
  final int visibleCount;

  const _HeaderCard({
    required this.totalAttachments,
    required this.imageCount,
    required this.visibleCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hidden = totalAttachments - visibleCount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white24,
            child: Icon(Icons.attachment_rounded, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المرفقات',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'رتّب ملفاتك وارجع إليها بسرعة',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: Colors.white.withOpacity(0.14),
              ),
            ),
            child: Column(
              children: [
                Text(
                  '$visibleCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  hidden > 0 ? 'ظاهر' : 'الكل',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onAdd;

  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 38),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onAdd,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('إضافة مرفق'),
          ),
        ],
      ),
    );
  }
}

class _AttachmentTile extends StatelessWidget {
  final Attachment attachment;
  final VoidCallback onDelete;

  const _AttachmentTile({
    required this.attachment,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kindColor = _kindColor(attachment.kind);
    final kindIcon = _kindIcon(attachment.kind);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: kindColor.withOpacity(0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: kindColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(kindIcon, color: kindColor),
        ),
        title: Text(
          attachment.name,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${_kindLabel(attachment.kind)} · ${_sizeLabel(attachment.sizeBytes)} · ${intl.DateFormat('d MMM', 'ar').format(attachment.createdAt)}',
            style: theme.textTheme.bodySmall,
          ),
        ),
        trailing: IconButton(
          tooltip: 'حذف',
          icon: const Icon(Icons.delete_outline_rounded),
          color: AppColors.priorityHigh,
          onPressed: onDelete,
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final String name;
  final AttachmentKind kind;

  const _PreviewCard({
    required this.name,
    required this.kind,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = _kindColor(kind);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.withOpacity(theme.brightness == Brightness.dark ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _kindIcon(kind),
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _kindLabel(kind),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
