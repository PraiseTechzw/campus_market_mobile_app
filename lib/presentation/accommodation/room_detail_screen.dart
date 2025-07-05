import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../core/app_theme.dart';
import '../core/components/app_button.dart';
import '../core/components/app_toast.dart';
import '../../domain/room_entity.dart';
import '../../domain/user_entity.dart';
import '../../application/user_providers.dart';
import '../../application/chat_providers.dart';
import '../chat/chat_screen.dart';
import '../../application/room_providers.dart';
import '../../application/chat_providers.dart';

class RoomDetailScreen extends StatefulWidget {
  final RoomEntity room;

  const RoomDetailScreen({super.key, required this.room});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showContactOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ContactOptionsSheet(room: widget.room),
    );
  }

  void _shareRoom() {
    Share.share(
      'Check out this ${widget.room.type} room at ${widget.room.campus} for \$${widget.room.price}/month!',
      subject: 'Room for Rent - ${widget.room.campus}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Images
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Image Gallery
                  if (widget.room.images.isNotEmpty)
                    PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemCount: widget.room.images.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          widget.room.images[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 80,
                                color: Colors.grey,
                              ),
                            );
                          },
                        );
                      },
                    )
                  else
                    Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.home_work,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
                  // Image Indicators
                  if (widget.room.images.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.room.images.length,
                          (index) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImageIndex == index
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _shareRoom,
              ),
            ],
          ),
          // Room Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${widget.room.type} Room',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '\$${widget.room.price.toStringAsFixed(0)}/month',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Location
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 20, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${widget.room.campus}, ${widget.room.city}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.room.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  // Amenities
                  Text(
                    'Amenities',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: widget.room.amenities.map((amenity) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          amenity,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  // Availability
                  Text(
                    'Availability',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (widget.room.availability.isNotEmpty)
                    ...widget.room.availability.take(3).map((date) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, size: 20, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text(
                              date.toString().split(' ')[0],
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      );
                    })
                  else
                    Text(
                      'Contact owner for availability',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  const SizedBox(height: 24),
                  // Tags
                  if (widget.room.tags.isNotEmpty) ...[
                    Text(
                      'Features',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: widget.room.tags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          backgroundColor: Colors.grey[100],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                  // Contact Button
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      onPressed: _showContactOptions,
                      text: 'Contact Owner',
                      icon: Icons.message,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Book Now Button
                  Consumer(
                    builder: (context, ref, child) {
                      final isBooked = widget.room.isBooked;
                      final currentUserId = ref.watch(currentUserIdProvider);
                      final bookRoomAsync = ref.watch(bookRoomProvider({'roomId': widget.room.id, 'userId': currentUserId ?? ''}));
                      if (isBooked) {
                        return SizedBox(
                          width: double.infinity,
                          child: AppButton(
                            onPressed: null,
                            text: 'Booked',
                            icon: Icons.lock,
                          ),
                        );
                      }
                      return SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          onPressed: currentUserId == null || bookRoomAsync.isLoading
                              ? null
                              : () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Book Room'),
                                      content: const Text('Are you sure you want to book this room?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('Book Now'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true) {
                                    ref.refresh(bookRoomProvider({'roomId': widget.room.id, 'userId': currentUserId!}));
                                  }
                                },
                          text: bookRoomAsync.isLoading ? 'Booking...' : 'Book Now',
                          icon: Icons.book_online,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ContactOptionsSheet extends StatelessWidget {
  final RoomEntity room;

  const ContactOptionsSheet({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Contact Options',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          // Chat Option
          Consumer(
            builder: (context, ref, child) {
              return ListTile(
                leading: const Icon(Icons.chat_bubble_outline, color: AppTheme.primaryColor),
                title: const Text('Send Message'),
                subtitle: const Text('Start a conversation with the owner'),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    // Get user information for the room owner
                    final userName = await ref.read(sellerNameProvider(room.userId));
                    
                    // Create direct chat
                    final chatId = await ref.read(createDirectChatProvider({
                      'otherUserId': room.userId,
                      'otherUserName': userName,
                      'initialMessage': 'Hi, I\'m interested in your ${room.type} room at ${room.campus}',
                    }).future);
                    
                    // Get the chat entity
                    final chat = await ref.read(chatProvider(chatId).future);
                    
                    if (chat != null && context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(chat: chat),
                        ),
                      );
                    } else {
                      if (context.mounted) {
                        AppToast.show(context, 'Chat created successfully! Check your chat list.');
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      AppToast.show(context, 'Failed to create chat: $e');
                    }
                  }
                },
              );
            },
          ),
          // Call Option
          ListTile(
            leading: const Icon(Icons.phone, color: AppTheme.primaryColor),
            title: const Text('Call Owner'),
            subtitle: const Text('Make a phone call'),
            onTap: () async {
              Navigator.pop(context);
              // TODO: Get user phone number from user profile
              const phoneNumber = '+1234567890'; // Placeholder
              final url = Uri.parse('tel:$phoneNumber');
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              } else {
                if (context.mounted) {
                  AppToast.show(context, 'Could not launch phone app');
                }
              }
            },
          ),
          // Email Option
          ListTile(
            leading: const Icon(Icons.email, color: AppTheme.primaryColor),
            title: const Text('Send Email'),
            subtitle: const Text('Send an email to the owner'),
            onTap: () async {
              Navigator.pop(context);
              // TODO: Get user email from user profile
              const email = 'owner@example.com'; // Placeholder
              final url = Uri.parse('mailto:$email?subject=Room Inquiry - ${room.campus}');
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              } else {
                if (context.mounted) {
                  AppToast.show(context, 'Could not launch email app');
                }
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
} 