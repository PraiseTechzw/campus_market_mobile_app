import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/add_product_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class AddProductStep3CustomFieldsScreen extends HookConsumerWidget {
  const AddProductStep3CustomFieldsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addProductProvider);
    final notifier = ref.read(addProductProvider.notifier);
    final primaryColor = const Color(0xFF32CD32);

    // Category to fields map
    final Map<String, List<Map<String, dynamic>>> categoryFields = {
      'Phones': [
        {'label': 'Brand', 'icon': Icons.branding_watermark, 'key': 'brand', 'hint': 'E.g. Samsung, Apple'},
        {'label': 'Model', 'icon': Icons.phone_android, 'key': 'model', 'hint': 'E.g. Galaxy S21, iPhone 12'},
        {'label': 'Storage', 'icon': Icons.sd_storage, 'key': 'storage', 'hint': 'E.g. 128GB'},
        {'label': 'Network', 'icon': Icons.network_cell, 'key': 'network', 'hint': 'E.g. 4G, 5G'},
      ],
      'Clothing': [
        {'label': 'Size', 'icon': Icons.straighten, 'key': 'size', 'hint': 'E.g. M, L, XL'},
        {'label': 'Gender', 'icon': Icons.wc, 'key': 'gender', 'hint': 'E.g. Male, Female, Unisex'},
        {'label': 'Material', 'icon': Icons.texture, 'key': 'material', 'hint': 'E.g. Cotton, Polyester'},
      ],
      'Hairdressing': [
        {'label': 'Service Type', 'icon': Icons.cut, 'key': 'serviceType', 'hint': 'E.g. Braiding, Barber'},
        {'label': 'Duration', 'icon': Icons.timer, 'key': 'duration', 'hint': 'E.g. 1 hour'},
        {'label': 'Gender Served', 'icon': Icons.people, 'key': 'genderServed', 'hint': 'E.g. Male, Female, All'},
      ],
      'Electronics': [
        {'label': 'Brand', 'icon': Icons.branding_watermark, 'key': 'brand', 'hint': 'E.g. HP, Dell, Apple'},
        {'label': 'Model', 'icon': Icons.laptop, 'key': 'model', 'hint': 'E.g. MacBook Pro, XPS 13'},
        {'label': 'Specs', 'icon': Icons.memory, 'key': 'specs', 'hint': 'E.g. 8GB RAM, 256GB SSD'},
      ],
      // Add more categories as needed
    };

    final customFields = Map<String, String>.from(state.customFields);
    final customFieldKeys = useState<List<String>>(customFields.keys.where((k) => k.startsWith('custom_')).toList());
    final newKeyController = useTextEditingController();
    final newValueController = useTextEditingController();

    List<Widget> fields = [];
    final fieldsForCategory = categoryFields[state.category];
    if (fieldsForCategory != null) {
      for (final field in fieldsForCategory) {
        fields.add(
          TextField(
            decoration: InputDecoration(
              labelText: field['label'],
              prefixIcon: Icon(field['icon'] as IconData),
              filled: true,
              fillColor: Colors.grey[900],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              helperText: field['hint'],
            ),
            onChanged: (v) => notifier.updateCustomFields({...state.customFields, field['key']: v}),
          ),
        );
        fields.add(const SizedBox(height: 16));
      }
    }

    // Show all user-added custom fields
    for (final key in customFieldKeys.value) {
      fields.add(
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: key.replaceFirst('custom_', '').capitalize(),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                controller: useTextEditingController(text: customFields[key] ?? ''),
                onChanged: (v) => notifier.updateCustomFields({...state.customFields, key: v}),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                final updated = Map<String, dynamic>.from(state.customFields);
                updated.remove(key);
                notifier.updateCustomFields(updated);
                customFieldKeys.value = List<String>.from(customFieldKeys.value)..remove(key);
              },
            ),
          ],
        ),
      );
      fields.add(const SizedBox(height: 16));
    }

    // Add custom field input
    fields.add(
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: newKeyController,
              decoration: const InputDecoration(
                labelText: 'Custom Field Name',
                hintText: 'e.g. Color, Material',
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: newValueController,
              decoration: const InputDecoration(
                labelText: 'Value',
                hintText: 'e.g. Red, Leather',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.add, color: primaryColor),
            onPressed: () {
              final key = newKeyController.text.trim();
              final value = newValueController.text.trim();
              if (key.isNotEmpty && value.isNotEmpty) {
                final customKey = 'custom_${key.toLowerCase().replaceAll(' ', '_')}';
                notifier.updateCustomFields({...state.customFields, customKey: value});
                customFieldKeys.value = List<String>.from(customFieldKeys.value)..add(customKey);
                newKeyController.clear();
                newValueController.clear();
              }
            },
          ),
        ],
      ),
    );
    fields.add(const SizedBox(height: 16));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Fields'),
        backgroundColor: primaryColor,
        leading: BackButton(onPressed: () {
          context.goNamed('addProductStep2');
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Progress indicator
                        Row(
                          children: [
                            Text('Step 3 of 5', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: 0.6,
                                color: primaryColor,
                                backgroundColor: primaryColor.withOpacity(0.15),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ...fields,
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 16, right: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            context.goNamed('addProductStep2');
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
                          onPressed: () {
                            context.pushNamed('addProductStep4');
                          },
                          child: const Text('Next', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
    );
  }
}

extension StringCasingExtension on String {
  String capitalize() => isEmpty ? '' : this[0].toUpperCase() + substring(1);
}
