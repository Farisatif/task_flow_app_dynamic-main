import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/app_scaffold.dart';
import '../core/theme/app_colors.dart';

class FocusDashboardScreen extends StatelessWidget {
  const FocusDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'لوحة التركيز',
      showNav: false,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(24)),
            child: Column(
              children: [
                const Icon(Icons.wb_twilight, color: Colors.white, size: 40),
                const SizedBox(height: 12),
                Text('مرحبًا أحمد', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                const SizedBox(height: 4),
                const Text('التركيز هو جسر بين الهدف والإنجاز', style: TextStyle(color: Colors.white70), textAlign: TextAlign.center),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _stat(context, '3h 45m', 'ساعات مكتملة')),
              const SizedBox(width: 10),
              Expanded(child: _stat(context, '4', 'جلسات تركيز')),
              const SizedBox(width: 10),
              Expanded(child: _stat(context, '50m', 'طول الجلسة')),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => context.push('/focus-timer'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size.fromHeight(52)),
            icon: const Icon(Icons.play_arrow),
            label: const Text('ابدأ جلسة تركيز'),
          ),
        ],
      ),
    );
  }

  Widget _stat(BuildContext context, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary)),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
