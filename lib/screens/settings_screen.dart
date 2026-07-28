import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/theme/theme_provider.dart';
import '../core/services/app_preferences.dart';
import '../core/services/notification_prefs.dart';
import '../widgets/app_scaffold.dart';
import '../core/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final appPrefs = context.watch<AppPreferences>();
    final n = appPrefs.notifications;

    return AppScaffold(
      title: 'الإعدادات',
      showNav: false,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _group(context, 'عام', [
            ListTile(leading: const Icon(Icons.person_outline), title: const Text('الملف الشخصي'), trailing: const Icon(Icons.chevron_left), onTap: () => context.push('/profile')),
            ListTile(leading: const Icon(Icons.language_outlined), title: const Text('اللغة'), trailing: const Text('العربية')),
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode_outlined),
              title: const Text('الوضع الليلي'),
              value: themeProvider.isDark,
              activeColor: AppColors.primary,
              onChanged: (v) => themeProvider.setDark(v),
            ),
          ]),
          _group(context, 'الإشعارات، الأصوات، والمهام', [
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('التذكيرات'),
              trailing: const Icon(Icons.chevron_left),
              onTap: () => context.push('/reminders'),
            ),
            ListTile(
              leading: const Icon(Icons.tune_outlined),
              title: const Text('إعدادات الإشعارات والأصوات'),
              subtitle: Text(n.remindersEnabled ? 'مفعّلة — الصوت: ${n.defaultSound.label}' : 'التذكيرات موقوفة'),
              trailing: const Icon(Icons.chevron_left),
              onTap: () => context.push('/notification-settings'),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_view_week_outlined),
              title: const Text('المخطط الأسبوعي وساعات العمل'),
              trailing: const Icon(Icons.chevron_left),
              onTap: () => context.push('/weekly-planner'),
            ),
          ]),
          _group(context, 'البيانات والخصوصية', [
            ListTile(leading: const Icon(Icons.privacy_tip_outlined), title: const Text('الخصوصية والأمان'), trailing: const Icon(Icons.chevron_left)),
            ListTile(leading: const Icon(Icons.backup_outlined), title: const Text('النسخ الاحتياطي'), trailing: const Icon(Icons.chevron_left), onTap: () => context.push('/backup-sync')),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('سلة المحذوفات'),
              subtitle: const Text('استعادة المهام المحذوفة أو حذفها نهائيًا'),
              trailing: const Icon(Icons.chevron_left),
              onTap: () => context.push('/trash'),
            ),
          ]),
          _group(context, 'الدعم', [
            ListTile(leading: const Icon(Icons.help_outline), title: const Text('مساعدة ودعم'), trailing: const Icon(Icons.chevron_left)),
            ListTile(leading: const Icon(Icons.info_outline), title: const Text('عن التطبيق'), trailing: const Icon(Icons.chevron_left)),
            ListTile(leading: const Icon(Icons.logout, color: AppColors.priorityHigh), title: const Text('تسجيل الخروج', style: TextStyle(color: AppColors.priorityHigh))),
          ]),
        ],
      ),
    );
  }

  Widget _group(BuildContext context, String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Card(child: Column(children: children)),
        ],
      ),
    );
  }
}
