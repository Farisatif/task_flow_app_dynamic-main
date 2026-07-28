import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';
import '../core/theme/app_colors.dart';

class BackupSyncScreen extends StatelessWidget {
  const BackupSyncScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'النسخ الاحتياطي والمزامنة',
      showNav: false,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(22)),
            child: Column(
              children: [
                const Icon(Icons.cloud_done_outlined, color: Colors.white, size: 44),
                const SizedBox(height: 10),
                const Text('نسخ احتياطي آمن لبياناتك في السحابة', style: TextStyle(color: Colors.white), textAlign: TextAlign.center),
                const SizedBox(height: 4),
                const Text('آخر نسخة: 19 مايو 2024، 10:30', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary),
                  child: const Text('نسخ احتياطي الآن'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Column(
              children: [
                SwitchListTile(value: true, onChanged: (_) {}, activeColor: AppColors.primary, title: const Text('مزامنة تلقائية')),
                const Divider(height: 1),
                ListTile(leading: const Icon(Icons.history), title: const Text('استعادة نسخة سابقة'), trailing: const Icon(Icons.chevron_left)),
                const Divider(height: 1),
                ListTile(leading: const Icon(Icons.storage_outlined), title: const Text('حجم البيانات'), trailing: const Text('45.2 MB')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
