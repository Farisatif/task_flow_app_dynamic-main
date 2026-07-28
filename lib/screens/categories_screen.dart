import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';
import '../core/theme/app_colors.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      ('العمل', Icons.work_outline, AppColors.primary, 12),
      ('الدراسة', Icons.school_outlined, AppColors.accentBlue, 8),
      ('الصحة', Icons.favorite_border, AppColors.accentGreen, 6),
      ('القراءة', Icons.menu_book_outlined, AppColors.accentOrange, 5),
      ('المنزل', Icons.home_outlined, AppColors.accentPink, 4),
    ];
    return AppScaffold(
      title: 'التصنيفات',
      showNav: false,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: categories
            .map((c) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: c.$3.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                      child: Icon(c.$2, color: c.$3),
                    ),
                    title: Text(c.$1, style: Theme.of(context).textTheme.titleSmall),
                    trailing: Text('${c.$4} مهام', style: Theme.of(context).textTheme.bodySmall),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
