import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  const AppBottomNav({super.key, required this.currentIndex});

  static const _items = [
    ('/', Icons.home_outlined, Icons.home, 'الرئيسية'),
    ('/today', Icons.today_outlined, Icons.today, 'اليوم'),
    ('/tasks', Icons.checklist_outlined, Icons.checklist, 'المهام'),
    ('/statistics', Icons.pie_chart_outline, Icons.pie_chart, 'الإحصائيات'),
    ('/more', Icons.grid_view_outlined, Icons.grid_view, 'المزيد'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 62,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final selected = i == currentIndex;
              final color = selected
                  ? (isDark ? AppColors.primaryLight : AppColors.primary)
                  : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary);
              return Expanded(
                child: InkWell(
                  onTap: () => context.go(item.$1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(selected ? item.$3 : item.$2, color: color, size: 24),
                      const SizedBox(height: 3),
                      Text(item.$4, style: TextStyle(fontSize: 10.5, color: color, fontWeight: selected ? FontWeight.w700 : FontWeight.w400)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
