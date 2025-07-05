import 'package:campus_market/presentation/marketplace/marketplace_screen.dart';
import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../accommodation/accommodation_screen.dart';
import '../post/post_ad_entry_screen.dart';
import '../chat/chat_stub.dart';
import '../profile/profile_stub.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/chat_providers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _pages = [
    MarketplaceScreen(),
    AccommodationScreen(),
    PostAdEntryScreen(),
    ChatStub(),
    ProfileStub(),
  ];

  @override
  Widget build(BuildContext context) {
    print('DEBUG: HomeScreen build called');
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Consumer(
        builder: (context, ref, child) {
          final unreadCountAsync = ref.watch(unreadCountProvider);
          
          return BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.storefront),
                label: 'Marketplace',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_work),
                label: 'Accommodation',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.add_box),
                label: 'Post Ad',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    const Icon(Icons.chat_bubble_outline),
                    unreadCountAsync.when(
                      data: (count) => count > 0
                          ? Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  count > 99 ? '99+' : count.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
                label: 'Chat',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          );
        },
      ),
    );
  }
} 