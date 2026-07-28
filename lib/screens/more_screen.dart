import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/app_scaffold.dart';
import '../core/theme/app_colors.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = <String, List<(String, IconData, Color, String)>>{
      'التخطيط الاستراتيجي': [
        ('الأهداف', Icons.flag_outlined, AppColors.primary, '/goals'),
        ('العادات', Icons.repeat, AppColors.accentGreen, '/habits'),
        ('المشاريع', Icons.folder_outlined, AppColors.accentBlue, '/projects'),
        ('التصنيفات', Icons.category_outlined, AppColors.accentPink, '/categories'),
        ('المخطط الأسبوعي', Icons.view_week_outlined, AppColors.secondary, '/weekly-planner'),
      ],
      'التحفيز والتحليل': [
        ('لوحة التركيز', Icons.dashboard_customize_outlined, AppColors.accentOrange, '/focus-dashboard'),
        ('تحليل الإنتاجية', Icons.trending_up, AppColors.primary, '/productivity-analysis'),
        ('تقارير الأداء', Icons.assessment_outlined, AppColors.accentBlue, '/performance-reports'),
        ('الإنجازات', Icons.emoji_events_outlined, AppColors.accentYellow, '/achievements'),
      ],
      'الأدوات المساعدة': [
        ('الملاحظات', Icons.sticky_note_2_outlined, AppColors.accentPink, '/notes'),
        ('المرفقات', Icons.attach_file, AppColors.accentGreen, '/attachments'),
        ('التذكيرات', Icons.notifications_active_outlined, AppColors.priorityHigh, '/reminders'),
      ],
      'إدارة التطبيق': [
        ('الملف الشخصي', Icons.person_outline, AppColors.primary, '/profile'),
        ('الإعدادات', Icons.settings_outlined, AppColors.accentBlue, '/settings'),
        ('النسخ الاحتياطي والمزامنة', Icons.cloud_sync_outlined, AppColors.accentGreen, '/backup-sync'),
        ('البحث والفلترة', Icons.manage_search, AppColors.accentOrange, '/search'),
      ],
    };

    return AppScaffold(
      title: 'المزيد',
      navIndex: 4,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: sections.entries.expand((e) => [
              Padding(padding: const EdgeInsets.only(top: 8, bottom: 10), child: Text(e.key, style: Theme.of(context).textTheme.titleMedium)),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.0),
                itemCount: e.value.length,
                itemBuilder: (context, i) {
                  final it = e.value[i];
                  return InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => context.push(it.$4),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: it.$3.withValues(alpha: 0.15), shape: BoxShape.circle),
                            child: Icon(it.$2, color: it.$3),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(it.$1, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center, maxLines: 2),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
            ]).toList(),
      ),
    );
  }
}
