import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class PostAdStub extends StatelessWidget {
  const PostAdStub({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_box, size: 80, color: AppTheme.primaryColor),
          const SizedBox(height: 16),
          Text('Post Ad', style: Theme.of(context).textTheme.headlineSmall),
        ],
      ),
    );
  }
} 