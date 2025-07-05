import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/add_room_provider.dart';
import 'package:go_router/go_router.dart';
import 'listing_access_guard.dart';
import '../../infrastructure/room_repository.dart';
import '../../domain/room_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../presentation/core/app_router.dart';

class AddRoomStep4ReviewAndSubmitScreen extends HookConsumerWidget {
  const AddRoomStep4ReviewAndSubmitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addRoomProvider);
    final repo = ref.read(roomRepositoryProvider);
    final primaryColor = const Color(0xFF32CD32);
    final isLoading = useState(false);
    final userEntityAsync = ref.watch(userEntityProvider);
    final userEntity = userEntityAsync.asData?.value;
    if (userEntityAsync.isLoading || userEntity == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    Future<void> submit() async {
      isLoading.value = true;
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) throw Exception('Not logged in');
        final room = RoomEntity(
          id: '',
          school: userEntity.school ?? '',
          campus: userEntity.campus ?? '',
          city: userEntity.location ?? '',
          location: '', // TODO: add location field to state if needed
          description: state.description,
          images: state.imageUrls,
          price: state.price,
          type: state.roomType,
          amenities: state.amenities,
          tags: const [],
          availability: const [],
          userId: user.uid,
          createdAt: DateTime.now(),
          verificationStatus: 'pending',
          isBooked: false,
        );
        await repo.addRoom(room);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Room listing submitted!')),
          );
          context.go('/home');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: $e')),
        );
      } finally {
        isLoading.value = false;
      }
    }
    return ListingAccessGuard(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Review & Submit'),
          leading: BackButton(onPressed: () {
            context.goNamed('addRoomStep3');
          }),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (state.imageUrls.isNotEmpty)
                                Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      state.imageUrls.first,
                                      height: 140,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              if (state.imageUrls.isNotEmpty) const SizedBox(height: 16),
                              Row(
                                children: [
                                  Icon(Icons.meeting_room, color: primaryColor),
                                  const SizedBox(width: 8),
                                  Chip(
                                    label: Text(state.roomType, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    backgroundColor: primaryColor.withOpacity(0.1),
                                    labelStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.title, color: primaryColor),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      state.title,
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.attach_money, color: primaryColor),
                                  const SizedBox(width: 8),
                                  Text('USD ${state.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Divider(height: 24),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.description, color: primaryColor),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      state.description,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.apartment, color: primaryColor),
                                  const SizedBox(width: 8),
                                  Text('School: ${userEntity.school ?? ''}'),
                                  const SizedBox(width: 12),
                                  Text('Campus: ${userEntity.campus ?? ''}'),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.location_city, color: primaryColor),
                                  const SizedBox(width: 8),
                                  Text('City: ${userEntity.location ?? ''}'),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.checklist, color: primaryColor),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text('Amenities: ${state.amenities.join(", ")}'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.image, color: primaryColor),
                                  const SizedBox(width: 8),
                                  Text('Images: ${state.imageUrls.length} selected'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (isLoading.value)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  if (!isLoading.value)
                    Padding(
                      padding: EdgeInsets.only(
                        left: 16, right: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                context.goNamed('addRoomStep3');
                              },
                              child: const Text('Back'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              onPressed: submit,
                              child: const Text('Submit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
} 