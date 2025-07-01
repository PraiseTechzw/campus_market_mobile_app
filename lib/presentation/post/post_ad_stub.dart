import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PostAdEntryScreen extends StatelessWidget {
  const PostAdEntryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Ad')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.shopping_bag),
              label: const Text('Post Product or Service'),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              onPressed: () {
                context.goNamed('addProductStep1');
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.home_work),
              label: const Text('Post Room for Rent'),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              onPressed: () {
                context.goNamed('addRoomStep1');
              },
            ),
          ],
        ),
      ),
    );
  }
} 