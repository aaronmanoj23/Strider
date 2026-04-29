import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/habit.dart';
import '../models/user_profile.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  CollectionReference _habitsRef(String uid) =>
      _db.collection('users').doc(uid).collection('habits');

  DocumentReference _profileRef(String uid) =>
      _db.collection('users').doc(uid).collection('profile').doc('data');

  Future<void> createUserProfile(
      String uid, String name, String email) async {
    try {
      await _profileRef(uid).set({
        'name': name,
        'email': email,
        'createdAt': Timestamp.now(),
        'xp': 0,
        'level': 1,
        'allTimeEarned': 0,
      });
    } catch (e) {
      // ignore
    }
  }

  Future<void> createDefaultHabits(String uid) async {
    try {
      final batch = _db.batch();
      for (final h in Habit.defaultHabits()) {
        final ref = _habitsRef(uid).doc(h['id'] as String);
        batch.set(ref, {
          'name': h['name'],
          'value': h['value'],
          'streak': 0,
          'lastCompleted': null,
          'completedDates': [],
        });
      }
      await batch.commit();
    } catch (e) {
      // ignore
    }
  }

  Future<bool> hasHabits(String uid) async {
    try {
      final snap = await _habitsRef(uid).limit(1).get();
      return snap.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final doc = await _profileRef(uid).get();
      if (!doc.exists) return null;
      return UserProfile.fromFirestore(
          doc.data() as Map<String, dynamic>, uid);
    } catch (e) {
      return null;
    }
  }

  Stream<UserProfile?> profileStream(String uid) {
    return _profileRef(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromFirestore(
          doc.data() as Map<String, dynamic>, uid);
    });
  }

  Future<List<Habit>> getHabits(String uid) async {
    try {
      final snap = await _habitsRef(uid).get();
      final habits =
          snap.docs.map((d) => Habit.fromFirestore(d)).toList();
      habits.sort((a, b) => b.value.compareTo(a.value));
      return habits;
    } catch (e) {
      return [];
    }
  }

  Stream<List<Habit>> habitsStream(String uid) {
    return _habitsRef(uid).snapshots().map((snap) {
      final habits =
          snap.docs.map((d) => Habit.fromFirestore(d)).toList();
      habits.sort((a, b) => b.value.compareTo(a.value));
      return habits;
    });
  }

  Future<void> toggleHabit(
      String uid, Habit habit, bool markComplete) async {
    try {
      final today = DateTime.now();
      final todayStr = Habit.dateStr(today);
      final dates = List<String>.from(habit.completedDates);
      int streak = habit.streak;
      DateTime? lastCompleted = habit.lastCompleted;

      if (markComplete) {
        if (!dates.contains(todayStr)) dates.add(todayStr);
        if (lastCompleted != null) {
          final last = DateTime(lastCompleted.year, lastCompleted.month,
              lastCompleted.day);
          final todayDate =
              DateTime(today.year, today.month, today.day);
          final yesterday =
              todayDate.subtract(const Duration(days: 1));
          if (last == yesterday) {
            streak += 1;
          } else if (last == todayDate) {
            // already done today, no streak change
          } else {
            streak = 1;
          }
        } else {
          streak = 1;
        }
        lastCompleted = today;
      } else {
        dates.remove(todayStr);
        if (lastCompleted != null) {
          final last = DateTime(lastCompleted.year, lastCompleted.month,
              lastCompleted.day);
          final todayDate =
              DateTime(today.year, today.month, today.day);
          if (last == todayDate) {
            streak = streak > 0 ? streak - 1 : 0;
            lastCompleted = streak > 0
                ? today.subtract(const Duration(days: 1))
                : null;
          }
        }
      }

      await _habitsRef(uid).doc(habit.id).update({
        'streak': streak,
        'lastCompleted': lastCompleted != null
            ? Timestamp.fromDate(lastCompleted)
            : null,
        'completedDates': dates,
      });

      if (markComplete) {
        await _profileRef(uid).update({
          'allTimeEarned': FieldValue.increment(habit.value),
          'xp': FieldValue.increment(10),
        });
        await _checkLevelUp(uid);
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> _checkLevelUp(String uid) async {
    try {
      final doc = await _profileRef(uid).get();
      if (!doc.exists) return;
      final data = doc.data() as Map<String, dynamic>;
      final xp = (data['xp'] as num?)?.toInt() ?? 0;
      final level = (data['level'] as num?)?.toInt() ?? 1;
      if (xp >= level * 100) {
        await _profileRef(uid).update({'level': level + 1});
      }
    } catch (e) {
      // ignore
    }
  }
}
