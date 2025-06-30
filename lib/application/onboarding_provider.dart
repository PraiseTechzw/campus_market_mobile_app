import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('onboarding_complete') ?? false;
  }

  Future<void> setComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    state = true;
  }
}

final onboardingCompleteProvider = StateNotifierProvider<OnboardingNotifier, bool>((ref) => OnboardingNotifier());