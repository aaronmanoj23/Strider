import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'theme.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.bg0,
  ));
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);
  runApp(const StriderApp());
}

class StriderApp extends StatelessWidget {
  const StriderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Strider',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: AppColors.bg0,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.p500,
          surface: AppColors.bg1,
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: AppColors.bg3,
          contentTextStyle: TextStyle(color: AppColors.txt),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light,
          ),
        ),
      ),
      home: const _AuthWrapper(),
    );
  }
}

class _AuthWrapper extends StatelessWidget {
  const _AuthWrapper();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.bg0,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.p500),
            ),
          );
        }
        return snapshot.hasData
            ? const MainScreen()
            : const LoginScreen();
      },
    );
  }
}