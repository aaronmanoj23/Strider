import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _fs = FirestoreService();

  User? get currentUser => _auth.currentUser;

  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password);
      final user = _auth.currentUser;
      if (user != null) {
        final hasHabits = await _fs.hasHabits(user.uid);
        if (!hasHabits) await _fs.createDefaultHabits(user.uid);
        final profile = await _fs.getUserProfile(user.uid);
        if (profile == null) {
          final name =
              user.displayName ?? user.email?.split('@').first ?? 'User';
          await _fs.createUserProfile(user.uid, name, user.email ?? '');
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Sign in failed';
    }
  }

  Future<String?> signUp(
      String name, String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password);
      await _fs.createUserProfile(
          cred.user!.uid, name, email.trim());
      await _fs.createDefaultHabits(cred.user!.uid);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Sign up failed';
    }
  }

  Future<void> signOut() => _auth.signOut();
}
