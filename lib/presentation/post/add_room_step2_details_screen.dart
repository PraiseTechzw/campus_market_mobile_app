import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/add_room_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/services.dart';
import '../../presentation/core/app_router.dart';

class AddRoomStep2DetailsScreen extends HookConsumerWidget {
  const AddRoomStep2DetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addRoomProvider);
    final notifier = ref.read(addRoomProvider.notifier);
    final titleController = useTextEditingController(text: state.title);
    final descController = useTextEditingController(text: state.description);
    final priceController = useTextEditingController(text: state.price == 0.0 ? '' : state.price.toString());
    final cityController = useTextEditingController(text: state.city);
    final schoolController = useTextEditingController(text: state.school);
    final campusController = useTextEditingController(text: state.campus);
    final amenities = ['WiFi', 'Water', 'Furnished', 'Electricity', 'Parking'];
    final isValid = state.title.isNotEmpty && state.description.isNotEmpty && state.price > 0 && state.city.isNotEmpty && state.school.isNotEmpty && state.campus.isNotEmpty;
    final priceError = useState<String?>(null);
    final primaryColor = const Color(0xFF32CD32);
    final userEntityAsync = ref.watch(userEntityProvider);
    final userEntity = userEntityAsync.asData?.value;
    final didPrefill = useRef(false);
    useEffect(() {
      if (!didPrefill.value && userEntity != null) {
        if ((state.school == null || state.school.isEmpty) && ((userEntity.school ?? '').isNotEmpty)) {
          schoolController.text = userEntity.school!;
          notifier.updateSchool(userEntity.school!);
        }
        if ((state.campus == null || state.campus.isEmpty) && ((userEntity.campus ?? '').isNotEmpty)) {
          campusController.text = userEntity.campus!;
          notifier.updateCampus(userEntity.campus!);
        }
        if ((state.city == null || state.city.isEmpty) && ((userEntity.location ?? '').isNotEmpty)) {
          cityController.text = userEntity.location!;
          notifier.updateCity(userEntity.location!);
        }
        didPrefill.value = true;
      }
      return null;
    }, [userEntity]);
    if (userEntityAsync.isLoading || userEntity == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    void onPriceChanged(String v) {
      final parsed = double.tryParse(v);
      if (parsed == null || parsed < 0) {
        priceError.value = 'Enter a valid price';
        notifier.updatePrice(0.0);
      } else {
        priceError.value = null;
        notifier.updatePrice(parsed);
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Room Details'),
        backgroundColor: primaryColor,
        leading: BackButton(onPressed: () {
          context.goNamed('addRoomStep1');
        }),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
              child: Row(
                children: [
                  Text('Step 2 of 4', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: 0.5,
                      color: primaryColor,
                      backgroundColor: primaryColor.withOpacity(0.15),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        prefixIcon: const Icon(Icons.title),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        helperText: 'E.g. Spacious single room, Cozy 2-share',
                      ),
                      onChanged: notifier.updateTitle,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        prefixIcon: const Icon(Icons.description),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        helperText: 'Describe the room, location, and features...',
                      ),
                      maxLines: 3,
                      onChanged: notifier.updateDescription,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: priceController,
                      decoration: InputDecoration(
                        labelText: 'Price per month (USD)',
                        prefixIcon: const Icon(Icons.attach_money),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        helperText: 'Enter the monthly price (numbers only)',
                        errorText: priceError.value,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*\.?[0-9]*')),
                      ],
                      onChanged: onPriceChanged,
                    ),
                    const SizedBox(height: 16),
                    const Text('Amenities', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: amenities.map((amenity) => FilterChip(
                        label: Text(amenity),
                        selected: state.amenities.contains(amenity),
                        selectedColor: primaryColor,
                        onSelected: (selected) {
                          final newAmenities = List<String>.from(state.amenities);
                          if (selected) {
                            newAmenities.add(amenity);
                          } else {
                            newAmenities.remove(amenity);
                          }
                          notifier.updateAmenities(newAmenities);
                        },
                        labelStyle: TextStyle(
                          color: state.amenities.contains(amenity) ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        backgroundColor: Colors.grey[900],
                        side: BorderSide(color: state.amenities.contains(amenity) ? primaryColor : Colors.grey[700]!),
                      )).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: cityController,
                      decoration: InputDecoration(
                        labelText: 'City',
                        prefixIcon: const Icon(Icons.location_city),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        helperText: 'E.g. Harare, Bulawayo',
                      ),
                      onChanged: notifier.updateCity,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: schoolController,
                      decoration: InputDecoration(
                        labelText: 'School',
                        prefixIcon: const Icon(Icons.school),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        helperText: 'E.g. UZ, NUST',
                      ),
                      onChanged: notifier.updateSchool,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: campusController,
                      decoration: InputDecoration(
                        labelText: 'Campus',
                        prefixIcon: const Icon(Icons.location_on),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        helperText: 'E.g. Main, City',
                      ),
                      onChanged: notifier.updateCampus,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 16, right: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isValid ? primaryColor : Colors.grey[800],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: isValid ? () {
                    context.pushNamed('addRoomStep3');
                  } : null,
                  child: const Text('Next', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 