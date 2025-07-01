import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/add_room_provider.dart';

class AddRoomStep1TypeScreen extends HookConsumerWidget {
  const AddRoomStep1TypeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addRoomProvider);
    final notifier = ref.read(addRoomProvider.notifier);
    final types = ['Single Room', '2-share', '3-share'];
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Room Type')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Room Type', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: types.map((type) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ChoiceChip(
                  label: Text(type),
                  selected: state.roomType == type,
                  onSelected: (_) => notifier.updateRoomType(type),
                ),
              )).toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state.roomType.isNotEmpty ? () {
                  // TODO: Go to next step
                } : null,
                child: const Text('Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 