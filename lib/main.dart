import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'presentation/core/app_theme.dart';
import 'presentation/core/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: CampusMarketApp()));
}

class CampusMarketApp extends ConsumerWidget {
  const CampusMarketApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use a FutureBuilder to handle Firebase initialization
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show splash/loading while initializing
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
            debugShowCheckedModeBanner: false,
          );
        } else if (snapshot.hasError) {
          // Show error UI if Firebase fails to initialize
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Failed to initialize Firebase: \n${snapshot.error}'),
              ),
            ),
            debugShowCheckedModeBanner: false,
          );
        }
        // Firebase initialized, proceed with app
        final router = ref.watch(appRouterProvider);
        return MaterialApp.router(
          title: 'CampusMarket',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
