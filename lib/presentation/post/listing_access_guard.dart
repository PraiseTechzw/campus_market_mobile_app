import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/profile_provider.dart';
import 'package:go_router/go_router.dart';

class ListingAccessGuard extends HookConsumerWidget {
  final Widget child;
  const ListingAccessGuard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(profileProvider);
    return userAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (user) {
        if (user == null) {
          return const Center(child: Text('Not logged in.'));
        }
        if (!user.verified || !(user.profileCompleted ?? false)) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'You must be a verified user with a complete profile to post listings.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    context.go('/profile-completion');
                  },
                  child: const Text('Complete Profile'),
                ),
              ],
            ),
          );
        }
        return child;
      },
    );
  }
} 