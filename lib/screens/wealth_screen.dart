import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/compound_chart.dart';

class WealthScreen extends StatefulWidget {
  final String uid;
  const WealthScreen({super.key, required this.uid});

  @override
  State<WealthScreen> createState() => _WealthScreenState();
}

class _WealthScreenState extends State<WealthScreen> {
  int _selectedYears = 10;
  static const _yearOptions = [5, 10, 20, 30];

  // Salary milestones (year disciplined person at $85k/12% hits target salary)
  static const _salaryMilestones = [
    ('\$100k salary', 2),
    ('\$150k salary', 4),
    ('\$200k salary', 6),
    ('\$300k salary', 9),
    ('\$500k salary', 13),
  ];

  double _cumulative(double startSalary, double rate, int years) {
    double total = 0;
    double salary = startSalary;
    for (int y = 0; y < years; y++) {
      total += salary;
      salary *= (1 + rate);
    }
    return total;
  }

  String _fmtGap(double v) {
    if (v >= 1000000) return '\$${(v / 1000000).toStringAsFixed(1)}M ahead';
    if (v >= 1000) return '\$${(v / 1000).toStringAsFixed(0)}k ahead';
    return '\$${v.toInt()} ahead';
  }

  @override
  Widget build(BuildContext context) {
    final discAt = _cumulative(85000, 0.12, _selectedYears);
    final undiAt = _cumulative(45000, 0.02, _selectedYears);
    final gap = discAt - undiAt;

    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
              left: 20, right: 20, top: 8, bottom: 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Wealth',
                  style: TextStyle(
                      color: AppColors.txt,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5)),
              const SizedBox(height: 4),
              const Text('Your discipline compounding into earnings',
                  style: TextStyle(color: AppColors.txt2, fontSize: 13)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _summaryCard(
                      'Daily Value',
                      '\$262',
                      Icons.bolt_rounded,
                      subtitle: '6 habits · career premium',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _summaryCard(
                      'Earnings Lead',
                      _fmtGap(gap),
                      Icons.leaderboard_rounded,
                      subtitle: 'at $_selectedYears yrs disciplined',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Career Earnings Trajectory',
                  style: TextStyle(
                      color: AppColors.txt,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _segmentedControl(),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bg2,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.bg4),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _chartLegend(AppColors.p500, 'Disciplined',
                            'starts \$85k · 12%/yr', false),
                        _chartLegend(AppColors.txt3, 'Undisciplined',
                            'starts \$45k · 2%/yr', true),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CompoundChart(years: _selectedYears),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Salary Milestones',
                  style: TextStyle(
                      color: AppColors.txt,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              ...List.generate(_salaryMilestones.length, (i) {
                final (label, year) = _salaryMilestones[i];
                return Padding(
                  padding: EdgeInsets.only(
                      bottom: i < _salaryMilestones.length - 1 ? 10 : 0),
                  child: _milestone(label, year),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(String label, String value, IconData icon,
      {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.p900,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.p800, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.p400, size: 20),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(
                  color: AppColors.p100,
                  fontSize: 20,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  color: AppColors.p300, fontSize: 13)),
          if (subtitle != null)
            Text(subtitle,
                style: const TextStyle(
                    color: AppColors.txt2, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _segmentedControl() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bg4),
      ),
      child: Row(
        children: _yearOptions.map((y) {
          final active = y == _selectedYears;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedYears = y),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: active ? AppColors.p900 : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  border: active
                      ? Border.all(color: AppColors.p800, width: 1)
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${y}yr',
                  style: TextStyle(
                    color: active ? AppColors.p300 : AppColors.txt2,
                    fontSize: 13,
                    fontWeight:
                        active ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _chartLegend(
      Color color, String label, String sub, bool dashed) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 12,
          child: CustomPaint(
            painter: _LinePainter(color: color, dashed: dashed),
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
            Text(sub,
                style: const TextStyle(
                    color: AppColors.txt2, fontSize: 10)),
          ],
        ),
      ],
    );
  }

  Widget _milestone(String label, int year) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.bg4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up_rounded,
                  color: AppColors.p500, size: 18),
              const SizedBox(width: 10),
              Text(label,
                  style: const TextStyle(
                      color: AppColors.txt,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.p900,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Year $year',
              style: const TextStyle(
                  color: AppColors.p300,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  final Color color;
  final bool dashed;
  const _LinePainter({required this.color, required this.dashed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final y = size.height / 2;
    if (!dashed) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    } else {
      double x = 0;
      while (x < size.width) {
        canvas.drawLine(Offset(x, y), Offset(x + 4, y), paint);
        x += 7;
      }
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) => false;
}
