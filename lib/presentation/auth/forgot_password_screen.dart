import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../infrastructure/auth_service.dart';
import '../core/app_theme.dart';
import '../core/components/app_button.dart';
import '../core/components/app_text_input.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _loading = false;
  String? _message;
  String? _error;

  Future<void> _sendReset() async {
    setState(() {
      _loading = true;
      _error = null;
      _message = null;
    });
    try {
      await ref.read(authServiceProvider).sendPasswordResetEmail(_emailController.text.trim());
      setState(() => _message = 'Password reset email sent!');
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
                      label: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
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
                          : _message != null
                              ? Container(
                                  key: ValueKey(_message),
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle, color: Colors.green),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(_message!, style: const TextStyle(color: Colors.green))),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(),
                    ),
                    AppButton(
                      text: 'Send Reset Email',
                      onPressed: _loading ? null : _sendReset,
                      loading: _loading,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Back to Login'),
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