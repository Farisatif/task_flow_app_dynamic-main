import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/app_scaffold.dart';
import '../core/theme/app_colors.dart';

class ProductivityAnalysisScreen extends StatelessWidget {
  const ProductivityAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = [6.0, 8.0, 4.0, 9.0, 7.0, 3.0, 5.0];
    const days = ['س', 'ح', 'ن', 'ث', 'ر', 'خ', 'ج'];
    return AppScaffold(
      title: 'تحليل الإنتاجية',
      showNav: false,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(value: 0.85, strokeWidth: 8, backgroundColor: Theme.of(context).dividerColor, color: AppColors.accentGreen),
                        Text('85%', style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('متوسط التركيز اليومي', style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 4),
                        Text('2h 30m', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
              child: SizedBox(
                height: 180,
                child: BarChart(
                  BarChartData(
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, meta) => Text(days[v.toInt() % 7], style: Theme.of(context).textTheme.bodySmall),
                        ),
                      ),
                    ),
                    barGroups: List.generate(
                      data.length,
                      (i) => BarChartGroupData(x: i, barRods: [
                        BarChartRodData(toY: data[i], color: AppColors.primary, width: 18, borderRadius: BorderRadius.circular(6)),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.access_time_filled, color: AppColors.accentGreen),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('أفضل الأوقات', style: Theme.of(context).textTheme.bodyMedium),
                        Text('09:00 - 12:00', style: Theme.of(context).textTheme.titleSmall),
                      ],
                    ),
                  ),
                  Text('أكثر وقت إنتاجية', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
