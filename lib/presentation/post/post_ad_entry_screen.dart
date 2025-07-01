import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/profile_provider.dart';

class PostAdEntryScreen extends HookConsumerWidget {
  const PostAdEntryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(profileProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF32CD32);

    Widget buildCard({
      required IconData icon,
      required IconData lockedIcon,
      required String title,
      required String description,
      required VoidCallback? onTap,
      bool locked = false,
      String? semanticLabel,
    }) {
      return AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: locked ? 0.6 : 1.0,
        child: GestureDetector(
          onTap: locked ? null : onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                if (!locked)
                  BoxShadow(
                    color: primaryColor.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Semantics(
              label: semanticLabel,
              button: true,
              child: Card(
                elevation: locked ? 1 : 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: isDark ? Colors.grey[900] : Colors.white,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: primaryColor.withOpacity(0.15),
                        child: Icon(locked ? lockedIcon : icon, size: 36, color: primaryColor),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                if (locked) ...[
                                  const SizedBox(width: 8),
                                  Icon(Icons.lock_outline, color: Colors.red, size: 20),
                                ]
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(description, style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black54)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Ad'),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('How Posting Works'),
                  content: const Text(
                    'You can post a product/service for sale, or a room for rent. Only verified users with complete profiles can post. Choose the option that matches your listing.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (user) {
          final bool profileComplete =
            user != null &&
            user.phone != null && user.phone!.isNotEmpty &&
            user.school != null && user.school!.isNotEmpty &&
            user.campus != null && user.campus!.isNotEmpty &&
            user.studentId != null && user.studentId!.isNotEmpty &&
            user.studentIdPhotoUrl != null && user.studentIdPhotoUrl!.isNotEmpty &&
            user.location != null && user.location!.isNotEmpty;
          final bool locked = user == null || !user.verified || !profileComplete;
          final bool pendingVerification = profileComplete && user != null && !user.verified;
          // Debug prints
          debugPrint('User: ' + (user?.toMap().toString() ?? 'null'));
          debugPrint('profileComplete: $profileComplete');
          debugPrint('locked: $locked');
          debugPrint('pendingVerification: $pendingVerification');
          return LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  children: [
                    // Branding/Illustration
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        children: [
                          Image.asset(
                            isDark ? 'assets/logo_dark.png' : 'assets/logo_light.png',
                            height: 64,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 12),
                          Text('What would you like to post?',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor)),
                        ],
                      ),
                    ),
                    buildCard(
                      icon: Icons.shopping_bag,
                      lockedIcon: Icons.shopping_bag_outlined,
                      title: 'Post Product or Serv..',
                      description: 'Sell items or offer services to other students.',
                      locked: locked,
                      onTap: () => context.goNamed('addProductStep1'),
                      semanticLabel: 'Post Product or Service',
                    ),
                    const SizedBox(height: 24),
                    buildCard(
                      icon: Icons.home_work,
                      lockedIcon: Icons.home_work_outlined,
                      title: 'Post Room for Rent',
                      description: 'List a room or accommodation for students.',
                      locked: locked,
                      onTap: () => context.goNamed('addRoomStep1'),
                      semanticLabel: 'Post Room for Rent',
                    ),
                    if (locked) ...[
                      const SizedBox(height: 32),
                      _PendingOrLockedMessage(
                        pendingVerification: pendingVerification,
                        onProfileTap: () => context.go('/profile'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PendingOrLockedMessage extends StatefulWidget {
  final bool pendingVerification;
  final VoidCallback onProfileTap;
  const _PendingOrLockedMessage({Key? key, required this.pendingVerification, required this.onProfileTap}) : super(key: key);

  @override
  State<_PendingOrLockedMessage> createState() => _PendingOrLockedMessageState();
}

class _PendingOrLockedMessageState extends State<_PendingOrLockedMessage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.15).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.pendingVerification ? Colors.orange : Colors.red;
    final icon = widget.pendingVerification ? Icons.hourglass_top : Icons.info_outline;
    final message = widget.pendingVerification
        ? "Your profile is complete! 🎉\n\nNow just sit tight while our team verifies your account. You'll be able to post as soon as you're approved."
        : 'You must be verified and have a complete profile to post. Tap your ';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ScaleTransition(
          scale: widget.pendingVerification ? _pulse : AlwaysStoppedAnimation(1.0),
          child: Icon(icon, color: color, size: 32),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: TextStyle(color: color, fontSize: 15),
              children: [
                TextSpan(text: message),
                if (!widget.pendingVerification)
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: GestureDetector(
                      onTap: widget.onProfileTap,
                      child: Text('profile', style: TextStyle(decoration: TextDecoration.underline, color: color, fontWeight: FontWeight.bold)),
                    ),
                  ),
                if (!widget.pendingVerification)
                  const TextSpan(text: ' to complete verification.'),
                if (widget.pendingVerification)
                  const TextSpan(text: ''),
              ],
            ),
          ),
        ),
        if (widget.pendingVerification)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: ScaleTransition(
              scale: _pulse,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Pending', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
      ],
    );
  }
}
