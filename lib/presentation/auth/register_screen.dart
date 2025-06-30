import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../infrastructure/auth_service.dart';
import '../core/app_theme.dart';
import 'package:go_router/go_router.dart';
import '../core/components/app_button.dart';
import '../core/components/app_text_input.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _register() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    if (_passwordController.text != _confirmController.text) {
      setState(() {
        _error = 'Passwords do not match';
        _loading = false;
      });
      return;
    }
    try {
      await ref.read(authServiceProvider).register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: 'student',
      );
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe8f5e9), Color(0xFFc8e6c9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.school, size: 48, color: AppTheme.primaryColor),
                        const SizedBox(width: 12),
                        Text(
                          'CampusMarket',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    AppTextInput(
                      label: 'Full Name',
                      controller: _nameController,
                    ),
                    const SizedBox(height: 16),
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
                    AppTextInput(
                      label: 'Confirm Password',
                      controller: _confirmController,
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
                      text: 'Create Account',
                      onPressed: _loading ? null : _register,
                      loading: _loading,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Already have an account? Login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 