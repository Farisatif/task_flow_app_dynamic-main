import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';
import '../core/theme/app_colors.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final badges = [
      ('منجز', Icons.workspace_premium, AppColors.accentYellow, true),
      ('متسق', Icons.local_fire_department, AppColors.priorityHigh, true),
      ('مركّز', Icons.center_focus_strong, AppColors.primary, true),
      ('منظّم', Icons.event_available, AppColors.accentGreen, false),
      ('سريع', Icons.bolt, AppColors.accentBlue, false),
      ('محترف', Icons.military_tech, AppColors.accentPink, false),
    ];
    return AppScaffold(
      title: 'الإنجازات',
      showNav: false,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(22)),
            child: Column(
              children: [
                const CircleAvatar(radius: 34, backgroundColor: Colors.white24, child: Icon(Icons.emoji_events, color: Colors.white, size: 32)),
                const SizedBox(height: 10),
                const Text('مستوى 10', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 4),
                const Text('3,460 / 5,000 XP', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(value: 0.69, minHeight: 8, backgroundColor: Colors.white24, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('الشارات', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.9),
            itemCount: badges.length,
            itemBuilder: (context, i) {
              final b = badges[i];
              final unlocked = b.$4;
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(b.$2, color: unlocked ? b.$3 : Theme.of(context).dividerColor, size: 30),
                    const SizedBox(height: 8),
                    Text(b.$1, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: unlocked ? null : Theme.of(context).dividerColor)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
