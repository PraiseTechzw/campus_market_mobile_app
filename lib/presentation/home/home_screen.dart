import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../marketplace/marketplace_stub.dart';
import '../accommodation/accommodation_stub.dart';
import '../post/post_ad_stub.dart';
import '../chat/chat_stub.dart';
import '../profile/profile_stub.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _pages = const [
    MarketplaceStub(),
    AccommodationStub(),
    PostAdStub(),
    ChatStub(),
    ProfileStub(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: 'Marketplace',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_work),
            label: 'Accommodation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: 'Post Ad',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
} 