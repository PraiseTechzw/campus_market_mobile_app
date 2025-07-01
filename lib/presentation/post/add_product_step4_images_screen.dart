import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/add_product_provider.dart';
import 'package:go_router/go_router.dart';
import 'listing_access_guard.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class AddProductStep4ImagesScreen extends HookConsumerWidget {
  const AddProductStep4ImagesScreen({Key? key}) : super(key: key);

  Future<String> _uploadImage(File file) async {
    final ref = FirebaseStorage.instance.ref('product_images/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}');
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addProductProvider);
    final notifier = ref.read(addProductProvider.notifier);
    final primaryColor = const Color(0xFF32CD32);
    final isLoading = useState(false);
    final picker = ImagePicker();

    Future<void> pickAndUploadImage() async {
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked != null) {
        isLoading.value = true;
        try {
          final url = await _uploadImage(File(picked.path));
          notifier.updateImages([...state.imageUrls, url]);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload image: $e')),
          );
        } finally {
          isLoading.value = false;
        }
      }
    }

    void removeImage(int index) {
      final newList = List<String>.from(state.imageUrls)..removeAt(index);
      notifier.updateImages(newList);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Images'),
        backgroundColor: primaryColor,
        leading: BackButton(onPressed: () {
          context.goNamed('addProductStep3');
        }),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator
            Row(
              children: [
                Text('Step 4 of 5', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                Expanded(
                  child: LinearProgressIndicator(
                    value: 0.8,
                    color: primaryColor,
                    backgroundColor: primaryColor.withOpacity(0.15),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Add 1–5 images', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: Stack(
                children: [
                  ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.imageUrls.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      if (index < state.imageUrls.length) {
                        final url = state.imageUrls[index];
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(url, width: 100, height: 100, fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 0, right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () => removeImage(index),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return GestureDetector(
                          onTap: state.imageUrls.length < 5 && !isLoading.value ? pickAndUploadImage : null,
                          child: Container(
                            width: 100, height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: primaryColor, width: 2),
                            ),
                            child: isLoading.value
                              ? const Center(child: CircularProgressIndicator())
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo, color: primaryColor, size: 32),
                                    const SizedBox(height: 4),
                                    Text('Add', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      context.goNamed('addProductStep3');
                    },
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: state.imageUrls.isNotEmpty ? primaryColor : Colors.grey[800],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: state.imageUrls.isNotEmpty && !isLoading.value ? () {
                      context.pushNamed('addProductStep5');
                    } : null,
                    child: const Text('Next', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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