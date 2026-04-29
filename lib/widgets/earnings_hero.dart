import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/habit.dart';

class EarningsHero extends StatelessWidget {
  final List<Habit> habits;

  const EarningsHero({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    final completed =
        habits.where((h) => h.isCompletedToday).toList();
    final earned = completed.fold(0, (s, h) => s + h.value);
    final total = habits.fold(0, (s, h) => s + h.value);
    final left = total - earned;
    final progress = total > 0 ? earned / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.p900,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.p800, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Earned today',
              style: TextStyle(color: AppColors.txt2, fontSize: 13)),
          const SizedBox(height: 6),
          Text(
            '\$$earned',
            style: const TextStyle(
              color: AppColors.p100,
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${completed.length} of ${habits.length} complete',
                style: const TextStyle(
                    color: AppColors.txt2, fontSize: 13),
              ),
              Text(
                '\$$left left',
                style: const TextStyle(
                    color: AppColors.txt2, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Container(height: 6, color: AppColors.p800),
                AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOut,
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.p400,
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
  }
}
