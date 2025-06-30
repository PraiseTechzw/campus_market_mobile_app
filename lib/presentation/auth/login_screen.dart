import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../infrastructure/auth_service.dart';
import '../core/app_theme.dart';
import 'package:go_router/go_router.dart';
import '../core/components/app_button.dart';
import '../core/components/app_text_input.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authServiceProvider).login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedContainer(
            duration: const Duration(seconds: 1),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF32CD32), Color(0xFF43e97b), Color(0xFF38f9d7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Abstract shapes
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.12),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            right: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Centered glassmorphic card
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: size.width < 500 ? size.width * 0.92 : 400,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 32,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.25),
                    width: 1.5,
                  ),
                  // Glassmorphism blur
                  backgroundBlendMode: BlendMode.overlay,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Hero section
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Icon(Icons.school, size: 56, color: AppTheme.primaryColor),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'CampusMarket',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Buy, Sell, Connect on Campus',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.black.withOpacity(0.6),
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Form
                    AppTextInput(
                      label: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    AppTextInput(
                      label: 'Password',
                      controller: _passwordController,
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _error != null
                          ? Container(
                              key: ValueKey(_error),
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.red[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error, color: Colors.red),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red))),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    AppButton(
                      text: 'Login',
                      onPressed: _loading ? null : _login,
                      loading: _loading,
                    ),
                    const SizedBox(height: 8),
                    AppButton(
                      text: 'Sign in with Google',
                      icon: Icons.login,
                      onPressed: _loading ? null : _googleSignIn,
                      loading: false,
                      expanded: true,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => context.go('/forgot-password'),
                      child: const Text('Forgot Password?'),
                    ),
                    TextButton(
                      onPressed: () => context.go('/register'),
                      child: const Text('Don\'t have an account? Register'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 