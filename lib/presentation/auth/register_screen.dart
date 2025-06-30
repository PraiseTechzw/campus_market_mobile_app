import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../infrastructure/auth_service.dart';
import '../core/app_theme.dart';
import 'package:go_router/go_router.dart';

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
  String _role = 'student';
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
        role: _role,
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
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmController,
                decoration: const InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _role,
                items: const [
                  DropdownMenuItem(value: 'student', child: Text('Student')),
                  DropdownMenuItem(value: 'seller', child: Text('Seller')),
                  DropdownMenuItem(value: 'landlord', child: Text('Landlord')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (v) => setState(() => _role = v ?? 'student'),
                decoration: const InputDecoration(labelText: 'Role'),
              ),
              const SizedBox(height: 16),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: _loading ? const CircularProgressIndicator() : const Text('Register'),
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
    );
  }
} 