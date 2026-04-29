import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/habit.dart';
import '../models/user_profile.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({super.key, required this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _fs = FirestoreService();
  final _auth = AuthService();
  UserProfile? _profile;
  List<Habit> _habits = [];
  bool _loading = true;

  // Salary milestones shared with wealth screen
  static const _salaryMilestones = [
    ('\$100k salary', 2),
    ('\$150k salary', 4),
    ('\$200k salary', 6),
    ('\$300k salary', 9),
    ('\$500k salary', 13),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await _fs.getUserProfile(widget.uid);
    final habits = await _fs.getHabits(widget.uid);
    if (mounted) {
      setState(() {
        _profile = profile;
        _habits = habits;
        _loading = false;
      });
    }
  }

  // Years to $1M net worth: save 30% of growing salary, compound at 10%/yr
  int _yearsToMillionNetWorth() {
    double portfolio = 0;
    double salary = 85000;
    for (int y = 1; y <= 100; y++) {
      portfolio += salary * 0.30;
      portfolio *= 1.10;
      salary *= 1.12;
      if (portfolio >= 1000000) return y;
    }
    return 100;
  }

  bool get _has30DayStreak => _habits.any((h) => h.streak >= 30);

  bool get _isGymRat {
    final gym = _habits.where((h) => h.id == 'gym').firstOrNull;
    return (gym?.completedDates.length ?? 0) >= 30;
  }

  bool get _is5kClub => (_profile?.allTimeEarned ?? 0) >= 5000;
  bool get _is10kClub => (_profile?.allTimeEarned ?? 0) >= 10000;

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.bg0,
        body: Center(
            child: CircularProgressIndicator(color: AppColors.p500)),
      );
    }
    final profile = _profile;
    if (profile == null) {
      return const Scaffold(
        backgroundColor: AppColors.bg0,
        body: Center(
            child: Text('No profile found',
                style: TextStyle(color: AppColors.txt2))),
      );
    }

    final initial =
        profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?';
    final yearsToMillion = _yearsToMillionNetWorth();

    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
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
                const Text('Profile',
                    style: TextStyle(
                        color: AppColors.txt,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5)),
                const SizedBox(height: 24),
                // Avatar + name
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.p900,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.p600, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: AppColors.p100,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(profile.name,
                              style: const TextStyle(
                                  color: AppColors.txt,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.p900,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: AppColors.p800, width: 1),
                            ),
                            child: Text(
                              'Level ${profile.level} — ${profile.levelName}',
                              style: const TextStyle(
                                  color: AppColors.p300,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // XP bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bg2,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.bg4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${profile.xp} XP',
                            style: const TextStyle(
                                color: AppColors.p300,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${profile.xpForNextLevel} XP to next level',
                            style: const TextStyle(
                                color: AppColors.txt2, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Stack(
                          children: [
                            Container(height: 6, color: AppColors.bg3),
                            FractionallySizedBox(
                              widthFactor:
                                  profile.xpProgress.clamp(0.0, 1.0),
                              child: Container(
                                height: 6,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(colors: [
                                    AppColors.p700,
                                    AppColors.p400,
                                  ]),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Millionaire countdown
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.p900,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.p800, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Millionaire Countdown',
                          style: TextStyle(
                              color: AppColors.txt2, fontSize: 12)),
                      const SizedBox(height: 6),
                      Text(
                        '$yearsToMillion years',
                        style: const TextStyle(
                          color: AppColors.p100,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                        ),
                      ),
                      const Text(
                          'to \$1M net worth · saving 30% of earnings',
                          style: TextStyle(
                              color: AppColors.txt2, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Badges',
                    style: TextStyle(
                        color: AppColors.txt,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.85,
                  children: [
                    _badge('🔥', '30-Day\nStreak', _has30DayStreak),
                    _badge('🏋️', 'Gym\nRat', _isGymRat),
                    _badge('💵', '\$5k\nClub', _is5kClub),
                    _badge('💎', '\$10k\nClub', _is10kClub),
                  ],
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
                        bottom:
                            i < _salaryMilestones.length - 1 ? 8 : 0),
                    child: _milestoneRow(label, year),
                  );
                }),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () async {
                      await _auth.signOut();
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: AppColors.txt3, width: 1),
                      foregroundColor: AppColors.txt2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Sign out',
                        style: TextStyle(fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge(String emoji, String label, bool unlocked) {
    return Opacity(
      opacity: unlocked ? 1.0 : 0.3,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.bg2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: unlocked ? AppColors.p800 : AppColors.bg4,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: unlocked ? AppColors.p300 : AppColors.txt2,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _milestoneRow(String label, int year) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bg4),
      ),
      child: Row(
        children: [
          const Icon(Icons.trending_up_rounded,
              color: AppColors.p500, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.txt,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
          ),
          Text('Year $year',
              style: const TextStyle(
                  color: AppColors.txt2, fontSize: 13)),
        ],
      ),
    );
  }
}
