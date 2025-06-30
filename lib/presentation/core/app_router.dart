import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../onboarding/onboarding_screen.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import '../auth/forgot_password_screen.dart';
import '../../application/onboarding_provider.dart';
import '../../infrastructure/auth_service.dart';
import '../../domain/user_entity.dart';
import 'dart:async';

// Custom ChangeNotifier to bridge a Stream to Listenable for go_router
class StreamChangeNotifier extends ChangeNotifier {
  late final StreamSubscription _sub;
  StreamChangeNotifier(Stream stream) {
    _sub = stream.listen((_) => notifyListeners());
  }
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final userEntityProvider = StreamProvider<UserEntity?>((ref) => ref.read(authServiceProvider).userEntityStream());
final _authChangeNotifierProvider = Provider<StreamChangeNotifier>((ref) {
  final stream = ref.watch(firebaseUserProvider.stream);
  return StreamChangeNotifier(stream);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: ref.watch(_authChangeNotifierProvider),
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
    ],
    redirect: (context, state) {
      final onboardingAsync = ref.read(onboardingCompleteProvider);
      final userAsync = ref.read(firebaseUserProvider);
      final userEntityAsync = ref.read(userEntityProvider);
      final onboardingComplete = onboardingAsync.asData?.value ?? false;
      final isLoggedIn = userAsync.asData?.value != null;
      final isSplash = state.uri.toString() == '/splash';
      final isOnboarding = state.uri.toString() == '/onboarding';
      final isAuth = ['/login', '/register', '/forgot-password'].contains(state.uri.toString());

      if (!onboardingComplete && !isOnboarding) {
        return '/onboarding';
      }
      if (onboardingComplete && !isLoggedIn && !isAuth) {
        return '/login';
      }
      if (isLoggedIn && (isAuth || isOnboarding || isSplash)) {
        final user = userEntityAsync.asData?.value;
        if (user != null && user.role == 'admin') {
          return '/admin';
        }
        return '/home';
      }
      return null;
    },
  );
});

// Stub screens
class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Splash Screen')));
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Onboarding')));
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Login')));
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Home')));
}

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Admin Dashboard')));
} 