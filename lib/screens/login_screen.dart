import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _auth = AuthService();
  bool _showPass = false;
  bool _loading = false;
  String? _error;

  Future<void> _signIn() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    if (!email.contains('@')) {
      setState(() => _error = 'Enter a valid email address');
      return;
    }
    if (pass.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final err = await _auth.signIn(email, pass);
    if (mounted) {
      setState(() {
        _loading = false;
        _error = err;
      });
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.p900,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.p800, width: 1),
                  ),
                  child: const Icon(
                    Icons.show_chart_rounded,
                    color: AppColors.p300,
                    size: 38,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Center(
                child: Text(
                  'Strider',
                  style: TextStyle(
                    color: AppColors.txt,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text(
                  'Build habits. Stack wealth.',
                  style: TextStyle(
                      color: AppColors.txt2, fontSize: 15),
                ),
              ),
              const SizedBox(height: 52),
              _field('Email', _emailCtrl,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _field(
                'Password',
                _passCtrl,
                obscure: !_showPass,
                suffix: IconButton(
                  icon: Icon(
                    _showPass
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: AppColors.txt2,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _showPass = !_showPass),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!,
                    style: const TextStyle(
                        color: Colors.redAccent, fontSize: 13)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.p600,
                    foregroundColor: AppColors.p100,
                    disabledBackgroundColor:
                        AppColors.p800,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: AppColors.p100,
                              strokeWidth: 2))
                      : const Text('Sign in',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 22),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SignupScreen())),
                  child: const Text.rich(
                    TextSpan(
                      text: "No account? ",
                      style: TextStyle(color: AppColors.txt2),
                      children: [
                        TextSpan(
                          text: 'Sign up',
                          style: TextStyle(
                              color: AppColors.p300,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    String hint,
    TextEditingController ctrl, {
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.txt),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: AppColors.txt3, fontSize: 15),
        filled: true,
        fillColor: AppColors.bg2,
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.bg4),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.bg4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.p600),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 15),
      ),
    );
  }
}
