import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../infrastructure/auth_service.dart';
import '../core/app_theme.dart';

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
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            if (_message != null)
              Text(_message!, style: const TextStyle(color: Colors.green)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _sendReset,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: _loading ? const CircularProgressIndicator() : const Text('Send Reset Email'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
} 