import 'package:campus_market/presentation/auth/verification_success_screen.dart';
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
import '../home/home_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../auth/profile_completion_screen.dart';
import 'splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../marketplace/product_detail_screen.dart';
import '../../domain/product_entity.dart';
import '../marketplace/search_results_screen.dart';

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
      GoRoute(
        path: '/verification-success',
        builder: (context, state) => _VerificationSuccessWrapper(),
      ),
      GoRoute(
        path: '/profile-completion',
        builder: (context, state) {
          final userEntity = ref.read(userEntityProvider).asData?.value;
          return ProfileCompletionScreen(
            email: userEntity?.email ?? '',
            name: userEntity?.name ?? '',
          );
        },
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final product = state.extra as ProductEntity?;
          if (product == null) {
            return const Scaffold(body: Center(child: Text('Product not found')));
          }
          return ProductDetailScreen(product: product);
        },
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) {
          final query = state.extra as String? ?? '';
          return SearchResultsScreen(initialQuery: query);
        },
      ),
    ],
    redirect: (context, state) {
      final onboardingComplete = ref.read(onboardingCompleteProvider);
      final userAsync = ref.read(firebaseUserProvider);
      final userEntityAsync = ref.read(userEntityProvider);

      final isLoggedIn = userAsync.asData?.value != null;

      // Only wait for userEntityProvider if logged in
      if (isLoggedIn && userEntityAsync.isLoading) {
        return null;
      }

      final isSplash = state.uri.toString() == '/splash';
      final isOnboarding = state.uri.toString() == '/onboarding';
      final isAuth = ['/login', '/register', '/forgot-password'].contains(state.uri.toString());
      final isProfileCompletion = state.uri.toString() == '/profile-completion';
      final isVerificationSuccess = state.uri.toString() == '/verification-success';
      final user = userEntityAsync.asData?.value;
      final authService = ref.read(authServiceProvider);

      bool profileIncomplete = false;
      if (user != null) {
        profileIncomplete =
          user.phone == null || user.phone!.isEmpty ||
          user.school == null || user.school!.isEmpty ||
          user.campus == null || user.campus!.isEmpty ||
          user.studentId == null || user.studentId!.isEmpty ||
          user.studentIdPhotoUrl == null || user.studentIdPhotoUrl!.isEmpty ||
          user.location == null || user.location!.isEmpty;
      }

      // 1. If onboarding is not complete, always redirect to onboarding (except if already there)
      if (!onboardingComplete && !isOnboarding) {
        return '/onboarding';
      }

      // 2. If not logged in, redirect to login (except if already on an auth page)
      if (onboardingComplete && !isLoggedIn && !isAuth) {
        return '/login';
      }

      // 3. If logged in but email is not verified, redirect to verification success screen (except if already there)
      if (isLoggedIn && !(authService.isEmailVerified()) && !isVerificationSuccess) {
        return '/verification-success';
      }

      // 4. If profile is incomplete, redirect to profile completion (except if already there)
      if (isLoggedIn && authService.isEmailVerified() && profileIncomplete && !isProfileCompletion) {
        return '/profile-completion';
      }

      // 5. If logged in, profile complete, and on onboarding/auth/profile-completion/splash, go to home
      if (isLoggedIn && authService.isEmailVerified() && !profileIncomplete && (isAuth || isOnboarding || isSplash || isProfileCompletion || isVerificationSuccess)) {
        if (user != null && user.role == 'admin') {
          return '/admin';
        }
        return '/home';
      }

      // 6. Otherwise, no redirect
      return null;
    },
  );
});

class _VerificationSuccessWrapper extends StatefulWidget {
  @override
  State<_VerificationSuccessWrapper> createState() => _VerificationSuccessWrapperState();
}

class _VerificationSuccessWrapperState extends State<_VerificationSuccessWrapper> {
  bool _loading = false;
  String? _error;

  Future<void> _reloadAndCheck() async {
    setState(() { _loading = true; _error = null; });
    try {
      await FirebaseAuth.instance.currentUser?.reload();
      // This will trigger the router to re-evaluate
      setState(() {});
    } catch (e) {
      setState(() { _error = 'Could not refresh. Please try again.'; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return VerificationSuccessScreen(
      message: "A verification email has been sent to your email address. Please check your inbox and verify your email to continue.",
      buttonText: _loading ? "Checking..." : "I've Verified My Email",
      onButtonPressed: _loading ? () {} : () { _reloadAndCheck(); },
    );
  }
}
