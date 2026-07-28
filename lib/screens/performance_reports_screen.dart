import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/stat_card.dart';
import '../core/theme/app_colors.dart';

class PerformanceReportsScreen extends StatelessWidget {
  const PerformanceReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'تقارير الأداء',
      showNav: false,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(children: [
              Expanded(child: Text('هذا الشهر', style: Theme.of(context).textTheme.titleMedium)),
              const Icon(Icons.expand_more),
            ]),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(value: 0.85, strokeWidth: 9, backgroundColor: Theme.of(context).dividerColor, color: AppColors.accentGreen),
                        Column(mainAxisSize: MainAxisSize.min, children: [
                          Text('85%', style: Theme.of(context).textTheme.titleMedium),
                          Text('أداء رائع', style: Theme.of(context).textTheme.bodySmall),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Wrap(
                      runSpacing: 10,
                      children: [
                        _metric(context, '124', 'المهام المكتملة'),
                        _metric(context, '98', 'ساعات التركيز'),
                        _metric(context, '16', 'المشاريع'),
                        _metric(context, '10', 'الأولويات'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: StatCard(value: '10', label: 'نسبة الإنجاز', color: AppColors.primary)),
              const SizedBox(width: 8),
              Expanded(child: StatCard(value: '-15%', label: 'مقارنة الشهر الماضي', color: AppColors.priorityHigh)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric(BuildContext context, String value, String label) {
    return SizedBox(
      width: 130,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: Theme.of(context).textTheme.titleMedium),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
