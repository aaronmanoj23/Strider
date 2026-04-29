import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme.dart';

class CompoundChart extends StatelessWidget {
  final int years;

  const CompoundChart({super.key, required this.years});

  // Cumulative lifetime earnings: each year adds that year's salary,
  // which grows at the given rate from the starting salary.
  List<FlSpot> _careerSpots(double startSalary, double growthRate) {
    final spots = <FlSpot>[];
    double cumulative = 0;
    double salary = startSalary;
    for (int y = 0; y <= years; y++) {
      spots.add(FlSpot(y.toDouble(), cumulative));
      cumulative += salary;
      salary *= (1 + growthRate);
    }
    return spots;
  }

  String _fmt(double v) {
    if (v >= 1000000) return '\$${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '\$${(v / 1000).toStringAsFixed(0)}k';
    return '\$${v.toInt()}';
  }

  @override
  Widget build(BuildContext context) {
    final disciplined = _careerSpots(85000, 0.12);
    final undisciplined = _careerSpots(45000, 0.02);
    final maxY = disciplined.last.y * 1.12;
    final interval = (years / 4).ceilToDouble();

    return Column(
      children: [
        SizedBox(
          height: 210,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: years.toDouble(),
              minY: 0,
              maxY: maxY,
              clipData: const FlClipData.all(),
              lineBarsData: [
                LineChartBarData(
                  spots: disciplined,
                  isCurved: true,
                  color: AppColors.p500,
                  barWidth: 2.5,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.p500.withValues(alpha: 0.08),
                  ),
                ),
                LineChartBarData(
                  spots: undisciplined,
                  isCurved: true,
                  color: AppColors.txt3,
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                  dashArray: [5, 5],
                ),
              ],
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: interval,
                    getTitlesWidget: (v, _) => Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '${v.toInt()}yr',
                        style: const TextStyle(
                            color: AppColors.txt2, fontSize: 10),
                      ),
                    ),
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 56,
                    getTitlesWidget: (v, _) => Text(
                      _fmt(v),
                      style: const TextStyle(
                          color: AppColors.txt2, fontSize: 9),
                    ),
                  ),
                ),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => const FlLine(
                  color: AppColors.bg3,
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => AppColors.bg3,
                  getTooltipItems: (spots) => spots
                      .map((s) => LineTooltipItem(
                            _fmt(s.y),
                            const TextStyle(
                                color: AppColors.p300,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _EndValue(
                label: 'Disciplined',
                value: _fmt(disciplined.last.y),
                color: AppColors.p400),
            _EndValue(
                label: 'Undisciplined',
                value: _fmt(undisciplined.last.y),
                color: AppColors.txt3),
          ],
        ),
      ],
    );
  }
}

class _EndValue extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _EndValue(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.txt2, fontSize: 12)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                color: color,
                fontSize: 17,
                fontWeight: FontWeight.w700)),
      ],
    );
  }
}
