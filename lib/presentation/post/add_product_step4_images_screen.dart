import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/add_product_provider.dart';
import 'package:go_router/go_router.dart';
import 'listing_access_guard.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/cupertino.dart';

class AddProductStep4ImagesScreen extends HookConsumerWidget {
  const AddProductStep4ImagesScreen({super.key});

  Future<String> _uploadImage(File file, void Function(double) onProgress) async {
    final ref = FirebaseStorage.instance.ref('product_images/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}');
    final uploadTask = ref.putFile(file);
    uploadTask.snapshotEvents.listen((event) {
      if (event.totalBytes > 0) {
        onProgress(event.bytesTransferred / event.totalBytes);
      }
    });
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addProductProvider);
    final notifier = ref.read(addProductProvider.notifier);
    final primaryColor = const Color(0xFF32CD32);
    final isLoading = useState(false);
    final uploadProgress = useState<List<double>>(List.filled(state.imageUrls.length + 1, 0.0));
    final picker = ImagePicker();
    final images = useState<List<String>>(List.from(state.imageUrls));

    Future<void> pickAndUploadImage(ImageSource source) async {
      final picked = await picker.pickImage(source: source, imageQuality: 85);
      if (picked != null) {
        isLoading.value = true;
        uploadProgress.value = [...uploadProgress.value, 0.0];
        try {
          final url = await _uploadImage(File(picked.path), (progress) {
            final idx = images.value.length;
            final updated = List<double>.from(uploadProgress.value);
            if (idx < updated.length) updated[idx] = progress;
            uploadProgress.value = updated;
          });
          images.value = [...images.value, url];
          notifier.updateImages(images.value);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload image: $e')),
          );
        } finally {
          isLoading.value = false;
        }
      }
    }

    void showImageSourcePicker() {
      showModalBottomSheet(
        context: context,
        builder: (ctx) => SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  pickAndUploadImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(ctx);
                  pickAndUploadImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      );
    }

    Future<void> removeImage(int index) async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Remove Image'),
          content: const Text('Are you sure you want to remove this image?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Remove', style: TextStyle(color: Colors.red))),
          ],
        ),
      );
      if (confirm == true) {
        final newList = List<String>.from(images.value)..removeAt(index);
        images.value = newList;
        notifier.updateImages(newList);
      }
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
              height: 120,
              child: ReorderableListView(
                scrollDirection: Axis.horizontal,
                onReorder: (oldIndex, newIndex) {
                  if (oldIndex < newIndex) newIndex--;
                  final newList = List<String>.from(images.value);
                  final item = newList.removeAt(oldIndex);
                  newList.insert(newIndex, item);
                  images.value = newList;
                  notifier.updateImages(newList);
                },
                children: [
                  for (int i = 0; i < images.value.length; i++)
                    Stack(
                      key: ValueKey(images.value[i]),
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(images.value[i], width: 100, height: 100, fit: BoxFit.cover),
                        ),
                        if (uploadProgress.value.length > i && uploadProgress.value[i] < 1.0)
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withOpacity(0.3),
                              child: Center(
                                child: CircularProgressIndicator(value: uploadProgress.value[i]),
                              ),
                            ),
                          ),
                        Positioned(
                          top: 0, right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => removeImage(i),
                          ),
                        ),
                      ],
                    ),
                  if (images.value.length < 5)
                    Container(
                      key: const ValueKey('add'),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: isLoading.value ? null : showImageSourcePicker,
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
                      ),
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
                      backgroundColor: images.value.isNotEmpty ? primaryColor : Colors.grey[800],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: images.value.isNotEmpty && !isLoading.value ? () {
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