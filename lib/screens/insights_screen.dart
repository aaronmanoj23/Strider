import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/habit.dart';
import '../models/user_profile.dart';
import '../services/firestore_service.dart';

class InsightsScreen extends StatefulWidget {
  final String uid;
  const InsightsScreen({super.key, required this.uid});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  final _fs = FirestoreService();
  List<Habit> _habits = [];
  UserProfile? _profile;
  bool _loading = true;

  static const _weekdays = [
    '', 'Monday', 'Tuesday', 'Wednesday',
    'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final habits = await _fs.getHabits(widget.uid);
    final profile = await _fs.getUserProfile(widget.uid);
    if (mounted) {
      setState(() {
        _habits = habits;
        _profile = profile;
        _loading = false;
      });
    }
  }

  String get _weakestDay {
    if (_habits.isEmpty) return 'N/A';
    final counts = <int, int>{};
    for (final h in _habits) {
      for (final d in h.completedDates) {
        final wd = DateTime.parse(d).weekday;
        counts[wd] = (counts[wd] ?? 0) + 1;
      }
    }
    if (counts.isEmpty) return 'N/A';
    // find lowest completion day
    int? weakest;
    int minCount = 999999;
    for (int wd = 1; wd <= 7; wd++) {
      final c = counts[wd] ?? 0;
      if (c < minCount) {
        minCount = c;
        weakest = wd;
      }
    }
    return weakest != null ? _weekdays[weakest] : 'N/A';
  }

  double _habitCompletionPct(Habit h) {
    if (_profile == null) return 0;
    final days =
        DateTime.now().difference(_profile!.createdAt).inDays + 1;
    if (days == 0) return 0;
    return (h.completedDates.length / days * 100).clamp(0, 100);
  }

  Map<String, dynamic> get _moneyLeftOnTable {
    final now = DateTime.now();
    Habit? mostSkipped;
    int maxSkipped = 0;
    int totalLeft = 0;

    for (final h in _habits) {
      final completionsThisMonth = h.completedDates.where((d) {
        final date = DateTime.parse(d);
        return date.year == now.year && date.month == now.month;
      }).length;
      final skipped = now.day - completionsThisMonth;
      totalLeft += skipped * h.value;
      if (skipped > maxSkipped) {
        maxSkipped = skipped;
        mostSkipped = h;
      }
    }
    return {
      'habit': mostSkipped,
      'skippedDays': maxSkipped,
      'total': totalLeft,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: SafeArea(
        bottom: false,
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.p500))
            : RefreshIndicator(
                color: AppColors.p500,
                backgroundColor: AppColors.bg2,
                onRefresh: _load,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 8, bottom: 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Insights',
                          style: TextStyle(
                              color: AppColors.txt,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5)),
                      const SizedBox(height: 4),
                      const Text('What your data is telling you',
                          style: TextStyle(
                              color: AppColors.txt2, fontSize: 13)),
                      const SizedBox(height: 20),
                      _weakestDayCard(),
                      const SizedBox(height: 20),
                      const Text('Completion by Habit',
                          style: TextStyle(
                              color: AppColors.txt,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      _completionBars(),
                      const SizedBox(height: 20),
                      const Text('Money Left on Table',
                          style: TextStyle(
                              color: AppColors.txt,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      _moneyLeftCard(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _weakestDayCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.p900,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.p800, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Weakest Day',
              style: TextStyle(color: AppColors.txt2, fontSize: 13)),
          const SizedBox(height: 8),
          Text(
            _weakestDay,
            style: const TextStyle(
              color: AppColors.p100,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          const Text('Fewest habits completed on this day',
              style: TextStyle(color: AppColors.txt2, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _completionBars() {
    if (_habits.isEmpty) {
      return const Text('No data yet',
          style: TextStyle(color: AppColors.txt2));
    }
    return Column(
      children: _habits.map((h) {
        final pct = _habitCompletionPct(h);
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(h.name,
                        style: const TextStyle(
                            color: AppColors.txt, fontSize: 14)),
                  ),
                  Text('${pct.toStringAsFixed(0)}%',
                      style: const TextStyle(
                          color: AppColors.p300,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Stack(
                  children: [
                    Container(
                        height: 8,
                        color: AppColors.bg3),
                    FractionallySizedBox(
                      widthFactor: (pct / 100).clamp(0.0, 1.0),
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.p700, AppColors.p500],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _moneyLeftCard() {
    final data = _moneyLeftOnTable;
    final habit = data['habit'] as Habit?;
    final total = data['total'] as int;
    final skipped = data['skippedDays'] as int;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bg4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (habit != null) ...[
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: AppColors.p400, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Most skipped: ${habit.name}',
                    style: const TextStyle(
                        color: AppColors.txt,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 26),
              child: Text(
                '$skipped days skipped · \$${skipped * habit.value} lost',
                style: const TextStyle(
                    color: AppColors.txt2, fontSize: 13),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.bg4, height: 1),
            const SizedBox(height: 12),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total unclaimed this month',
                  style:
                      TextStyle(color: AppColors.txt2, fontSize: 13)),
              Text('\$$total',
                  style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}
