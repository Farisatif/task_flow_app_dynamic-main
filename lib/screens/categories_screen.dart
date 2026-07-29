import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../widgets/app_scaffold.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  static const List<_CategoryItem> _categories = [
    _CategoryItem(
      name: 'العمل',
      icon: Icons.work_outline_rounded,
      color: AppColors.primary,
      taskCount: 12,
      subtitle: 'مهام مرتبطة بالإنتاجية والعمل',
    ),
    _CategoryItem(
      name: 'الدراسة',
      icon: Icons.school_outlined,
      color: AppColors.accentBlue,
      taskCount: 8,
      subtitle: 'المهام الدراسية والمراجعات',
    ),
    _CategoryItem(
      name: 'الصحة',
      icon: Icons.favorite_border_rounded,
      color: AppColors.accentGreen,
      taskCount: 6,
      subtitle: 'روتينك الصحي والعادات اليومية',
    ),
    _CategoryItem(
      name: 'القراءة',
      icon: Icons.menu_book_outlined,
      color: AppColors.accentOrange,
      taskCount: 5,
      subtitle: 'الكتب والمقالات وخطط القراءة',
    ),
    _CategoryItem(
      name: 'المنزل',
      icon: Icons.home_outlined,
      color: AppColors.accentPink,
      taskCount: 4,
      subtitle: 'مهام المنزل والترتيب والتنظيم',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_CategoryItem> get _filteredCategories {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _categories;

    return _categories.where((item) {
      return item.name.toLowerCase().contains(q) ||
          item.subtitle.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filteredCategories;
    final totalTasks =
        _categories.fold<int>(0, (sum, item) => sum + item.taskCount);

    return AppScaffold(
      title: 'التصنيفات',
      showNav: false,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _showComingSoon(context),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'تصنيف جديد',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _HeaderCard(
              categoriesCount: _categories.length,
              totalTasks: totalTasks,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'ابحث عن تصنيف...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
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
            const SizedBox(height: 16),
            if (filtered.isEmpty)
              _EmptyState(
                title: 'لا توجد نتائج',
                subtitle: 'جرّب اسمًا مختلفًا أو كلمة من وصف التصنيف',
                icon: Icons.category_outlined,
              )
            else
              ...filtered.map(
                (category) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CategoryCard(
                    item: category,
                    onTap: () => _showCategoryDetails(context, category),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('إضافة التصنيفات من القاعدة ستُربط لاحقًا'),
      ),
    );
  }

  void _showCategoryDetails(BuildContext context, _CategoryItem item) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(item.icon, color: item.color),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: Theme.of(sheetContext)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.subtitle,
                            style: Theme.of(sheetContext).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _DetailRow(
                  title: 'عدد المهام',
                  value: '${item.taskCount} مهمة',
                ),
                const SizedBox(height: 8),
                _DetailRow(
                  title: 'اللون',
                  valueWidget: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: item.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _DetailRow(
                  title: 'الحالة',
                  value: 'نشط',
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('إغلاق'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final int categoriesCount;
  final int totalTasks;

  const _HeaderCard({
    required this.categoriesCount,
    required this.totalTasks,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            child: Icon(Icons.category_rounded, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'التصنيفات',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'نظّم مهامك حسب المجالات والاهتمامات',
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
              border: Border.all(color: Colors.white.withOpacity(0.14)),
            ),
            child: Column(
              children: [
                Text(
                  '$categoriesCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'تصنيف',
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

class _CategoryCard extends StatelessWidget {
  final _CategoryItem item;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: item.color.withOpacity(0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(item.icon, color: item.color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${item.taskCount}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: item.color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'مهام',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 42),
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
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String title;
  final String? value;
  final Widget? valueWidget;

  const _DetailRow({
    required this.title,
    this.value,
    this.valueWidget,
  }) : assert(value != null || valueWidget != null);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          if (valueWidget != null) valueWidget! else Text(value!),
        ],
      ),
    );
  }
}

class _CategoryItem {
  final String name;
  final IconData icon;
  final Color color;
  final int taskCount;
  final String subtitle;

  const _CategoryItem({
    required this.name,
    required this.icon,
    required this.color,
    required this.taskCount,
    required this.subtitle,
  });
}
