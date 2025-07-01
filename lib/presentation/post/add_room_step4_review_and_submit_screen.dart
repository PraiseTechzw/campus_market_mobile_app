import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/add_room_provider.dart';

class AddRoomStep4ReviewAndSubmitScreen extends HookConsumerWidget {
  const AddRoomStep4ReviewAndSubmitScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addRoomProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review & Submit'),
        leading: BackButton(onPressed: () {
          // TODO: Go back to previous step
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
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: Go back
                    },
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Submit room listing
                    },
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 