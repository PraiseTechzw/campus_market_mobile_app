import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/add_product_provider.dart';
import 'package:go_router/go_router.dart';

class AddProductStep3CustomFieldsScreen extends HookConsumerWidget {
  const AddProductStep3CustomFieldsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addProductProvider);
    final notifier = ref.read(addProductProvider.notifier);
    final primaryColor = const Color(0xFF32CD32);
    List<Widget> fields = [];
    if (state.category == 'Phones') {
      fields = [
        TextField(
          decoration: InputDecoration(
            labelText: 'Brand',
            prefixIcon: const Icon(Icons.branding_watermark),
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            helperText: 'E.g. Samsung, Apple',
          ),
          onChanged: (v) => notifier.updateCustomFields({...state.customFields, 'brand': v}),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Model',
            prefixIcon: const Icon(Icons.phone_android),
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            helperText: 'E.g. Galaxy S21, iPhone 12',
          ),
          onChanged: (v) => notifier.updateCustomFields({...state.customFields, 'model': v}),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Storage',
            prefixIcon: const Icon(Icons.sd_storage),
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            helperText: 'E.g. 128GB',
          ),
          onChanged: (v) => notifier.updateCustomFields({...state.customFields, 'storage': v}),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Network',
            prefixIcon: const Icon(Icons.network_cell),
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            helperText: 'E.g. 4G, 5G',
          ),
          onChanged: (v) => notifier.updateCustomFields({...state.customFields, 'network': v}),
        ),
      ];
    } else if (state.category == 'Clothing') {
      fields = [
        TextField(
          decoration: InputDecoration(
            labelText: 'Size',
            prefixIcon: const Icon(Icons.straighten),
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            helperText: 'E.g. M, L, XL',
          ),
          onChanged: (v) => notifier.updateCustomFields({...state.customFields, 'size': v}),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Gender',
            prefixIcon: const Icon(Icons.wc),
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            helperText: 'E.g. Male, Female, Unisex',
          ),
          onChanged: (v) => notifier.updateCustomFields({...state.customFields, 'gender': v}),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Material',
            prefixIcon: const Icon(Icons.texture),
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            helperText: 'E.g. Cotton, Polyester',
          ),
          onChanged: (v) => notifier.updateCustomFields({...state.customFields, 'material': v}),
        ),
      ];
    } else if (state.category == 'Hairdressing') {
      fields = [
        TextField(
          decoration: InputDecoration(
            labelText: 'Service Type',
            prefixIcon: const Icon(Icons.cut),
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            helperText: 'E.g. Braiding, Barber',
          ),
          onChanged: (v) => notifier.updateCustomFields({...state.customFields, 'serviceType': v}),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Duration',
            prefixIcon: const Icon(Icons.timer),
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            helperText: 'E.g. 1 hour',
          ),
          onChanged: (v) => notifier.updateCustomFields({...state.customFields, 'duration': v}),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Gender Served',
            prefixIcon: const Icon(Icons.people),
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            helperText: 'E.g. Male, Female, All',
          ),
          onChanged: (v) => notifier.updateCustomFields({...state.customFields, 'genderServed': v}),
        ),
      ];
    } else {
      fields = [
        const Text('No custom fields for this category.'),
      ];
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Fields'),
        backgroundColor: primaryColor,
        leading: BackButton(onPressed: () {
          context.goNamed('addProductStep2');
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
            const Spacer(),
            Row(
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
          ],
        ),
      ),
    );
  }
}
