import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/theme_provider.dart';
import 'app_bottom_nav.dart';

/// إطار موحّد لكل الشاشات: شريط علوي + محتوى + شريط تنقل سفلي اختياري
class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final int navIndex;
  final bool showNav;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? leading;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.navIndex = -1,
    this.showNav = true,
    this.actions,
    this.floatingActionButton,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          leading: leading,
          title: Text(title, style: Theme.of(context).textTheme.titleLarge),
          actions: [
            ...?actions,
            IconButton(
              tooltip: 'تبديل الوضع الليلي',
              icon: Icon(themeProvider.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
              onPressed: () => themeProvider.toggle(),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: SafeArea(top: false, child: body),
        bottomNavigationBar: showNav && navIndex >= 0 ? AppBottomNav(currentIndex: navIndex) : null,
        floatingActionButton: floatingActionButton,
      ),
    );
  }
}
