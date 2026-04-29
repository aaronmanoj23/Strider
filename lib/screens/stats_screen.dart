import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/habit.dart';
import '../models/user_profile.dart';
import '../services/firestore_service.dart';

class StatsScreen extends StatefulWidget {
  final String uid;
  const StatsScreen({super.key, required this.uid});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final _fs = FirestoreService();
  List<Habit> _habits = [];
  UserProfile? _profile;
  bool _loading = true;

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

  int get _bestStreak =>
      _habits.isEmpty ? 0 : _habits.map((h) => h.streak).reduce((a, b) => a > b ? a : b);

  int get _thisWeekTotal {
    final now = DateTime.now();
    int total = 0;
    for (final h in _habits) {
      for (final d in h.completedDates) {
        final date = DateTime.parse(d);
        if (now.difference(date).inDays < 7) total += h.value;
      }
    }
    return total;
  }

  double get _completionPct {
    if (_profile == null) return 0;
    final days = DateTime.now().difference(_profile!.createdAt).inDays + 1;
    final possible = days * _habits.length;
    if (possible == 0) return 0;
    final actual = _habits.fold(0, (s, h) => s + h.completedDates.length);
    return (actual / possible * 100).clamp(0, 100);
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
                      const Text('Stats',
                          style: TextStyle(
                              color: AppColors.txt,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5)),
                      const SizedBox(height: 4),
                      const Text('Your progress at a glance',
                          style: TextStyle(
                              color: AppColors.txt2, fontSize: 13)),
                      const SizedBox(height: 20),
                      _summaryGrid(),
                      const SizedBox(height: 24),
                      const Text('Monthly Calendar',
                          style: TextStyle(
                              color: AppColors.txt,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      _calendar(),
                      const SizedBox(height: 24),
                      const Text('Top Streaks',
                          style: TextStyle(
                              color: AppColors.txt,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      _topStreaks(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _summaryGrid() {
    final cards = [
      ('All-Time Earned', '\$${_profile?.allTimeEarned ?? 0}',
          Icons.attach_money_rounded),
      ('Best Streak', '${_bestStreak}d', Icons.local_fire_department_rounded),
      ('This Week', '\$$_thisWeekTotal', Icons.calendar_today_rounded),
      ('Completion', '${_completionPct.toStringAsFixed(0)}%',
          Icons.pie_chart_rounded),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: cards
          .map((c) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bg2,
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: AppColors.bg4, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(c.$3, color: AppColors.p500, size: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.$2,
                            style: const TextStyle(
                              color: AppColors.p100,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            )),
                        Text(c.$1,
                            style: const TextStyle(
                                color: AppColors.txt2,
                                fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _calendar() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final daysInMonth =
        DateTime(now.year, now.month + 1, 0).day;
    final offset = firstDay.weekday % 7; // 0=Sun offset

    // Build completion map
    final Map<String, int> dayMap = {};
    for (final h in _habits) {
      for (final d in h.completedDates) {
        final date = DateTime.parse(d);
        if (date.year == now.year && date.month == now.month) {
          final key = Habit.dateStr(date);
          dayMap[key] = (dayMap[key] ?? 0) + 1;
        }
      }
    }

    final total = daysInMonth + offset;
    final rows = (total / 7).ceil();

    return Column(
      children: [
        Row(
          children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
              .map((d) => Expanded(
                    child: Center(
                      child: Text(d,
                          style: const TextStyle(
                              color: AppColors.txt2,
                              fontSize: 11)),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 6),
        ...List.generate(rows, (row) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: List.generate(7, (col) {
                final idx = row * 7 + col;
                final day = idx - offset + 1;
                if (day < 1 || day > daysInMonth) {
                  return const Expanded(child: SizedBox());
                }
                final date = DateTime(now.year, now.month, day);
                final key = Habit.dateStr(date);
                final count = dayMap[key] ?? 0;
                final isToday = day == now.day;

                Color bg;
                if (count == 0) {
                  bg = AppColors.bg3;
                } else if (count >= _habits.length &&
                    _habits.isNotEmpty) {
                  bg = AppColors.p600;
                } else {
                  bg = AppColors.p800;
                }

                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: 32,
                    decoration: BoxDecoration(
                      color: isToday ? Colors.transparent : bg,
                      borderRadius: BorderRadius.circular(6),
                      border: isToday
                          ? Border.all(color: AppColors.p500, width: 1.5)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: count > 0 || isToday
                            ? AppColors.p100
                            : AppColors.txt3,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legend(AppColors.p600, 'All complete'),
            const SizedBox(width: 16),
            _legend(AppColors.p800, 'Partial'),
            const SizedBox(width: 16),
            _legend(AppColors.bg3, 'None'),
          ],
        ),
      ],
    );
  }

  Widget _legend(Color color, String label) {
    return Row(
      children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 5),
        Text(label,
            style:
                const TextStyle(color: AppColors.txt2, fontSize: 11)),
      ],
    );
  }

  Widget _topStreaks() {
    if (_habits.isEmpty) {
      return const Center(
          child: Text('No habit data yet',
              style: TextStyle(color: AppColors.txt2)));
    }
    final sorted = List<Habit>.from(_habits)
      ..sort((a, b) => b.streak.compareTo(a.streak));
    final maxStreak =
        sorted.first.streak > 0 ? sorted.first.streak : 1;

    return Column(
      children: sorted.map((h) {
        final pct = h.streak / maxStreak;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(h.name,
                      style: const TextStyle(
                          color: AppColors.txt, fontSize: 14)),
                  Text('${h.streak}d',
                      style: const TextStyle(
                          color: AppColors.p300,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Stack(
                  children: [
                    Container(height: 5, color: AppColors.bg3),
                    FractionallySizedBox(
                      widthFactor: pct.clamp(0.0, 1.0),
                      child: Container(
                          height: 5, color: AppColors.p600),
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
}
