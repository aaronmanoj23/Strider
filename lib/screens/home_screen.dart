import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../models/habit.dart';
import '../models/user_profile.dart';
import '../services/firestore_service.dart';
import '../widgets/dock_nav.dart';
import '../widgets/habit_card.dart';
import '../widgets/earnings_hero.dart';
import '../widgets/glow_orb.dart';
import 'stats_screen.dart';
import 'wealth_screen.dart';
import 'insights_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;
  late final String _uid;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser!.uid;
    _screens = [
      HomeTab(uid: _uid, onProfileTap: () => setState(() => _index = 4)),
      StatsScreen(uid: _uid),
      WealthScreen(uid: _uid),
      InsightsScreen(uid: _uid),
      ProfileScreen(uid: _uid),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      extendBody: true,
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: DockNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  final String uid;
  final VoidCallback onProfileTap;

  const HomeTab({super.key, required this.uid, required this.onProfileTap});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _fs = FirestoreService();
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final p = await _fs.getUserProfile(widget.uid);
    if (mounted) setState(() => _profile = p);
  }

  Future<void> _toggle(Habit habit, List<Habit> habits) async {
    final wasCompleted = habit.isCompletedToday;
    await _fs.toggleHabit(widget.uid, habit, !wasCompleted);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wasCompleted
                ? '${habit.name} unchecked'
                : '+\$${habit.value} earned! ${habit.name} complete ',
          ),
          backgroundColor: AppColors.bg3,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.only(
              bottom: 100, left: 16, right: 16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, MMMM d').format(DateTime.now());
    final initials = (_profile?.name.isNotEmpty == true)
        ? _profile!.name[0].toUpperCase()
        : '?';

    return StreamBuilder<List<Habit>>(
      stream: _fs.habitsStream(widget.uid),
      builder: (context, snap) {
        final habits = snap.data ?? [];
        return Scaffold(
          backgroundColor: AppColors.bg0,
          body: Stack(
            children: [
              Positioned(
                top: -60,
                right: -60,
                child: GlowOrb(
                    size: 260,
                    color: AppColors.p700,
                    opacity: 0.09),
              ),
              SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 8, bottom: 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Strider',
                                style: TextStyle(
                                  color: AppColors.txt,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                today,
                                style: const TextStyle(
                                    color: AppColors.txt2,
                                    fontSize: 13),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: widget.onProfileTap,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: AppColors.p900,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  color: AppColors.p300,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      EarningsHero(habits: habits),
                      const SizedBox(height: 24),
                      const Text(
                        'Today\'s Habits',
                        style: TextStyle(
                          color: AppColors.txt,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (snap.connectionState ==
                              ConnectionState.waiting &&
                          habits.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(
                                color: AppColors.p500),
                          ),
                        )
                      else
                        ...habits.map(
                          (h) => HabitCard(
                            habit: h,
                            onTap: () => _toggle(h, habits),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
