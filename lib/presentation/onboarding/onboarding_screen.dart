import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/onboarding_provider.dart';
import '../core/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// OnboardingScreen displays the animated onboarding flow with images, icon, and welcoming text.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

/// State for OnboardingScreen, manages page transitions and onboarding completion.
class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      title: 'Marketplace',
      description: 'Buy and sell student products easily on campus.',
      image: 'assets/images/marketplace.png',
    ),
    _OnboardingPageData(
      title: 'Accommodation',
      description: 'Find and book student rooms with real-time availability.',
      image: 'assets/images/accomodation.png',
    ),
    _OnboardingPageData(
      title: 'Messaging',
      description: 'Chat with buyers, sellers, and landlords securely.',
      image: 'assets/images/message.png',
    ),
  ];

  void _onSkip() async {
    await ref.read(onboardingCompleteProvider.notifier).setComplete();
    if (mounted) context.go('/login');
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      _onSkip();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor.withOpacity(0.05),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            // Animated app logo icon, image, and welcoming tagline
            Column(
              children: [
                Icon(Icons.school, size: 48, color: AppTheme.primaryColor)
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(begin: const Offset(0.7, 0.7), end: Offset(1, 1), duration: 600.ms, curve: Curves.easeOut),
                const SizedBox(height: 8),
               
                Text(
                  'Welcome to CampusMarket!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 200.ms)
                    .slideY(begin: -0.1, end: 0, duration: 600.ms, curve: Curves.easeOut),
                const SizedBox(height: 4),
                Text(
                  'Your campus, your marketplace.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 400.ms)
                    .slideY(begin: -0.05, end: 0, duration: 600.ms, curve: Curves.easeOut),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, i) => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.1, 0),
                        end: Offset.zero,
                      ).animate(anim),
                      child: child,
                    ),
                  ),
                  child: _OnboardingPage(
                    key: ValueKey(i),
                    data: _pages[i],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage < _pages.length - 1)
                    TextButton(
                      onPressed: _onSkip,
                      child: const Text('Skip'),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 100.ms),
                  Row(
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOut,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _currentPage ? 16 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == _currentPage ? AppTheme.primaryColor : Colors.grey[300],
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _onNext,
                    child: Text(_currentPage == _pages.length - 1 ? 'Get Started' : 'Next'),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 100.ms)
                      .scale(begin: const Offset(0.95, 0.95), end: Offset(1, 1), duration: 400.ms, curve: Curves.easeOut),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Data model for each onboarding page.
class _OnboardingPageData {
  final String title;
  final String description;
  final String image;
  _OnboardingPageData({required this.title, required this.description, required this.image});
}

/// Widget for a single onboarding page, with animated image, title, and description.
class _OnboardingPage extends StatelessWidget {
  final _OnboardingPageData data;
  const _OnboardingPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            data.image,
            height: 400,
            fit: BoxFit.contain,
          )
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.2, end: 0, duration: 600.ms, curve: Curves.easeOut),
          const SizedBox(height: 32),
          Text(
            data.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 200.ms)
              .slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOut),
          const SizedBox(height: 16),
          Text(
            data.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 400.ms)
              .slideY(begin: 0.05, end: 0, duration: 500.ms, curve: Curves.easeOut),
        ],
      ),
    );
  }
} 