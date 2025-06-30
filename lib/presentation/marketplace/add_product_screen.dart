import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/product_providers.dart';
import '../../domain/product_entity.dart';
import '../core/components/app_text_input.dart';
import '../core/components/app_button.dart';
import '../core/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  List<XFile> _images = [];
  bool _loading = false;
  String? _error;

  Future<List<String>> _uploadImages(List<XFile> files) async {
    final urls = <String>[];
    for (final file in files) {
      final ref = FirebaseStorage.instance.ref('products/${DateTime.now().millisecondsSinceEpoch}_${file.name}');
      final upload = await ref.putData(await file.readAsBytes());
      final url = await upload.ref.getDownloadURL();
      urls.add(url);
    }
    return urls;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _images.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final imageUrls = await _uploadImages(_images);
      final product = ProductEntity(
        id: '',
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        images: imageUrls,
        price: double.parse(_priceController.text.trim()),
        userId: 'TODO_USER_ID', // Replace with actual userId
        createdAt: DateTime.now(),
      );
      await ref.read(addProductProvider(product).future);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage();
    if (files != null && files.isNotEmpty) {
      setState(() => _images = files);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextInput(
                label: 'Title',
                controller: _titleController,
                validator: (v) => v == null || v.isEmpty ? 'Enter title' : null,
              ),
              const SizedBox(height: 16),
              AppTextInput(
                label: 'Description',
                controller: _descController,
                validator: (v) => v == null || v.isEmpty ? 'Enter description' : null,
              ),
              const SizedBox(height: 16),
              AppTextInput(
                label: 'Price (USD)',
                controller: _priceController,
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Enter price' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  AppButton(
                    text: 'Pick Images',
                    icon: Icons.image,
                    expanded: false,
                    onPressed: _pickImages,
                  ),
                  const SizedBox(width: 12),
                  Text('${_images.length} selected'),
                ],
              ),
              const SizedBox(height: 16),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              AppButton(
                text: 'Submit',
                loading: _loading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 