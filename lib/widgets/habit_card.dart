import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/habit.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onTap;

  const HabitCard({super.key, required this.habit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final completed = habit.isCompletedToday;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: completed ? AppColors.p900 : AppColors.bg2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: completed ? AppColors.p800 : AppColors.bg4,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: completed ? AppColors.p600 : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: completed
                    ? null
                    : Border.all(color: AppColors.txt3, width: 1.5),
              ),
              child: completed
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 15)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    style: TextStyle(
                      color: completed ? AppColors.p100 : AppColors.txt,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        color: habit.streak > 0
                            ? AppColors.p400
                            : AppColors.txt3,
                        size: 12,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${habit.streak} day streak',
                        style: const TextStyle(
                            color: AppColors.txt2, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${habit.value}',
                  style: const TextStyle(
                    color: AppColors.p300,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  completed ? 'Done' : 'Pending',
                  style: TextStyle(
                    color: completed ? AppColors.p400 : AppColors.txt3,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
