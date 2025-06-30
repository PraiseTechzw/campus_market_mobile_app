import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'presentation/core/app_theme.dart';
import 'presentation/core/app_router.dart';

void main() {
  runApp(const ProviderScope(child: CampusMarketApp()));
}

class CampusMarketApp extends HookWidget {
  const CampusMarketApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final router = useProvider(appRouterProvider);
    return MaterialApp.router(
      title: 'CampusMarket',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
