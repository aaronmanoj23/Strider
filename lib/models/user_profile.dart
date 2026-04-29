import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String userId;
  String name;
  final String email;
  final DateTime createdAt;
  int xp;
  int level;
  int allTimeEarned;

  UserProfile({
    required this.userId,
    required this.name,
    required this.email,
    required this.createdAt,
    this.xp = 0,
    this.level = 1,
    this.allTimeEarned = 0,
  });

  String get levelName {
    if (level <= 2) return 'Beginner';
    if (level <= 4) return 'Grinder';
    if (level <= 6) return 'Stack Builder';
    if (level <= 9) return 'Wealth Seeker';
    return 'Elite';
  }

  int get xpForNextLevel => level * 100;

  double get xpProgress {
    final base = (level - 1) * 100;
    final cap = level * 100;
    final current = xp.clamp(base, cap);
    return (current - base) / (cap - base);
  }

  factory UserProfile.fromFirestore(Map<String, dynamic> data, String userId) {
    return UserProfile(
      userId: userId,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      xp: (data['xp'] as num?)?.toInt() ?? 0,
      level: (data['level'] as num?)?.toInt() ?? 1,
      allTimeEarned: (data['allTimeEarned'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'createdAt': Timestamp.fromDate(createdAt),
        'xp': xp,
        'level': level,
        'allTimeEarned': allTimeEarned,
      };
}
