import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';
import '../core/theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ملفي الشخصي',
      showNav: false,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(radius: 44, backgroundColor: AppColors.primary.withValues(alpha: 0.15), child: const Icon(Icons.person, size: 44, color: AppColors.primary)),
                const SizedBox(height: 12),
                Text('أحمد المطوعي', style: Theme.of(context).textTheme.titleLarge),
                Text('ahmed@example.com', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                  child: const Text('مستوى 10 خبير الإنتاجية', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _stat(context, '534', 'شارات')),
              Expanded(child: _stat(context, '248', 'أيام نشطة')),
              Expanded(child: _stat(context, '12', 'مشاريع')),
              Expanded(child: _stat(context, '8', 'إنجازات')),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            child: Column(
              children: [
                ListTile(leading: const Icon(Icons.edit_outlined), title: const Text('تعديل الملف الشخصي'), trailing: const Icon(Icons.chevron_left)),
                const Divider(height: 1),
                ListTile(leading: const Icon(Icons.lock_outline), title: const Text('تغيير كلمة المرور'), trailing: const Icon(Icons.chevron_left)),
                const Divider(height: 1),
                ListTile(leading: const Icon(Icons.tune_outlined), title: const Text('تفضيلات الشخصية'), trailing: const Icon(Icons.chevron_left)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary)),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
