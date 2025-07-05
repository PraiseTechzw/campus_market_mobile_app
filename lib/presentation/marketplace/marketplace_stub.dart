import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class MarketplaceStub extends StatelessWidget {
  const MarketplaceStub({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.storefront, size: 80, color: AppTheme.primaryColor),
          const SizedBox(height: 16),
          Text('Marketplace', style: Theme.of(context).textTheme.headlineSmall),
        ],
      ),
    );
  }
} 