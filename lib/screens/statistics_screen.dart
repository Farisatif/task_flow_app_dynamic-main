import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/stat_card.dart';
import '../core/theme/app_colors.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'الإحصائيات العامة',
      navIndex: 3,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(child: StatCard(value: '56', label: 'إجمالي', color: AppColors.primary)),
              const SizedBox(width: 8),
              Expanded(child: StatCard(value: '42', label: 'منجزة', color: AppColors.accentGreen)),
              const SizedBox(width: 8),
              Expanded(child: StatCard(value: '7', label: 'متأخرة', color: AppColors.accentOrange)),
              const SizedBox(width: 8),
              Expanded(child: StatCard(value: '3', label: 'منسية', color: AppColors.priorityHigh)),
            ],
          ),
          const SizedBox(height: 20),
          Text('نسبة الإنجاز - هذا الأسبوع', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
              child: SizedBox(
                height: 180,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, meta) {
                            const days = ['سبت', 'أحد', 'اثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة'];
                            if (v.toInt() < 0 || v.toInt() >= days.length) return const SizedBox();
                            return Padding(padding: const EdgeInsets.only(top: 6), child: Text(days[v.toInt()], style: Theme.of(context).textTheme.bodySmall));
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [FlSpot(0, 40), FlSpot(1, 65), FlSpot(2, 50), FlSpot(3, 80), FlSpot(4, 60), FlSpot(5, 90), FlSpot(6, 75)],
                        isCurved: true,
                        color: AppColors.primary,
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: true, color: AppColors.primary.withValues(alpha: 0.12)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('توزيع الوقت', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  SizedBox(
                    height: 140,
                    width: 140,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 36,
                        sections: [
                          PieChartSectionData(value: 45, color: AppColors.primary, title: '', radius: 24),
                          PieChartSectionData(value: 25, color: AppColors.accentBlue, title: '', radius: 24),
                          PieChartSectionData(value: 15, color: AppColors.accentGreen, title: '', radius: 24),
                          PieChartSectionData(value: 10, color: AppColors.accentOrange, title: '', radius: 24),
                          PieChartSectionData(value: 5, color: AppColors.accentPink, title: '', radius: 24),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _legend(context, 'العمل', 45, AppColors.primary),
                        _legend(context, 'الدراسة', 25, AppColors.accentBlue),
                        _legend(context, 'الصحة', 15, AppColors.accentGreen),
                        _legend(context, 'القراءة', 10, AppColors.accentOrange),
                        _legend(context, 'أخرى', 5, AppColors.accentPink),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legend(BuildContext context, String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
          Text('$value%', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
