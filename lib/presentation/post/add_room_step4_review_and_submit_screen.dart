import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/add_room_provider.dart';
import 'package:go_router/go_router.dart';
import 'listing_access_guard.dart';
import '../../infrastructure/room_repository.dart';
import '../../domain/room_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class AddRoomStep4ReviewAndSubmitScreen extends HookConsumerWidget {
  const AddRoomStep4ReviewAndSubmitScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addRoomProvider);
    final repo = ref.read(roomRepositoryProvider);
    final primaryColor = const Color(0xFF32CD32);
    final isLoading = useState(false);
    Future<void> submit() async {
      isLoading.value = true;
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) throw Exception('Not logged in');
        final room = RoomEntity(
          id: '',
          school: state.school,
          campus: state.campus,
          city: state.city,
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
          context.go('/');
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
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Review your room listing:'),
              const SizedBox(height: 16),
              Text('Room Type: ${state.roomType}'),
              Text('Title: ${state.title}'),
              Text('Description: ${state.description}'),
              Text('Price: ${state.price}'),
              Text('Amenities: ${state.amenities.join(", ")}'),
              Text('City: ${state.city}'),
              Text('School: ${state.school}'),
              Text('Campus: ${state.campus}'),
              Text('Images: ${state.imageUrls.length} selected'),
              const Spacer(),
              if (isLoading.value) const Center(child: CircularProgressIndicator()),
              if (!isLoading.value)
                Row(
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
                        onPressed: submit,
                        child: const Text('Submit'),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
} 