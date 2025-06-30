import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class ChatStub extends StatelessWidget {
  const ChatStub({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: AppTheme.primaryColor),
          const SizedBox(height: 16),
          Text('Chat', style: Theme.of(context).textTheme.headlineSmall),
        ],
      ),
    );
  }
} 