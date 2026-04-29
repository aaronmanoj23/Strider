import 'package:cloud_firestore/cloud_firestore.dart';

class Habit {
  final String id;
  final String name;
  final int value;
  int streak;
  DateTime? lastCompleted;
  List<String> completedDates;

  Habit({
    required this.id,
    required this.name,
    required this.value,
    this.streak = 0,
    this.lastCompleted,
    List<String>? completedDates,
  }) : completedDates = completedDates ?? [];

  static String dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  bool get isCompletedToday => completedDates.contains(dateStr(DateTime.now()));

  factory Habit.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Habit(
      id: doc.id,
      name: data['name'] as String? ?? '',
      value: (data['value'] as num?)?.toInt() ?? 0,
      streak: (data['streak'] as num?)?.toInt() ?? 0,
      lastCompleted: (data['lastCompleted'] as Timestamp?)?.toDate(),
      completedDates: List<String>.from(data['completedDates'] as List? ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'value': value,
        'streak': streak,
        'lastCompleted':
            lastCompleted != null ? Timestamp.fromDate(lastCompleted!) : null,
        'completedDates': completedDates,
      };

  static List<Map<String, dynamic>> defaultHabits() => [
        {'id': 'deep_work', 'name': 'Deep Work (4hrs)', 'value': 95},
        {'id': 'sleep', 'name': '8hrs Sleep', 'value': 56},
        {'id': 'no_alcohol', 'name': 'No Alcohol', 'value': 41},
        {'id': 'reading', 'name': 'Reading', 'value': 27},
        {'id': 'gym', 'name': 'Gym', 'value': 24},
        {'id': 'meditation', 'name': 'Meditation', 'value': 19},
      ];
}
