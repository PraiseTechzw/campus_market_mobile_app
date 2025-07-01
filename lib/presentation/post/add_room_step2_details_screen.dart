import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/add_room_provider.dart';

class AddRoomStep2DetailsScreen extends HookConsumerWidget {
  const AddRoomStep2DetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addRoomProvider);
    final notifier = ref.read(addRoomProvider.notifier);
    final titleController = TextEditingController(text: state.title);
    final descController = TextEditingController(text: state.description);
    final priceController = TextEditingController(text: state.price == 0.0 ? '' : state.price.toString());
    final amenities = ['WiFi', 'Water', 'Furnished', 'Electricity', 'Parking'];
    final isValid = state.title.isNotEmpty && state.description.isNotEmpty && state.price > 0 && state.city.isNotEmpty && state.school.isNotEmpty && state.campus.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Room Details'),
        leading: BackButton(onPressed: () {
          // TODO: Go back to previous step
        }),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              onChanged: notifier.updateTitle,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
              onChanged: notifier.updateDescription,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price per month (USD)'),
              keyboardType: TextInputType.number,
              onChanged: (v) => notifier.updatePrice(double.tryParse(v) ?? 0.0),
            ),
            const SizedBox(height: 12),
            const Text('Amenities'),
            Wrap(
              spacing: 8,
              children: amenities.map((amenity) => FilterChip(
                label: Text(amenity),
                selected: state.amenities.contains(amenity),
                onSelected: (selected) {
                  final newAmenities = List<String>.from(state.amenities);
                  if (selected) {
                    newAmenities.add(amenity);
                  } else {
                    newAmenities.remove(amenity);
                  }
                  notifier.updateAmenities(newAmenities);
                },
              )).toList(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: TextEditingController(text: state.city),
              decoration: const InputDecoration(labelText: 'City'),
              onChanged: notifier.updateCity,
            ),
            TextField(
              controller: TextEditingController(text: state.school),
              decoration: const InputDecoration(labelText: 'School'),
              onChanged: notifier.updateSchool,
            ),
            TextField(
              controller: TextEditingController(text: state.campus),
              decoration: const InputDecoration(labelText: 'Campus'),
              onChanged: notifier.updateCampus,
            ),
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
                    onPressed: isValid ? () {
                      // TODO: Go to next step
                    } : null,
                    child: const Text('Next'),
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