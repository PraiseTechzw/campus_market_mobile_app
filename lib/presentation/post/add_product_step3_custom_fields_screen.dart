import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/add_product_provider.dart';
import 'package:go_router/go_router.dart';
import 'listing_access_guard.dart';

class AddProductStep3CustomFieldsScreen extends HookConsumerWidget {
  const AddProductStep3CustomFieldsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addProductProvider);
    final notifier = ref.read(addProductProvider.notifier);
    // Example: show different fields for Phones, Clothing, Hairdressing, etc.
    List<Widget> fields = [];
    if (state.category == 'Phones') {
      fields = [
        TextField(
          decoration: const InputDecoration(labelText: 'Brand'),
          onChanged: (v) => notifier.updateCustomFields({...state.customFields, 'brand': v}),
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Model'),
          onChanged: (v) => notifier.updateCustomFields({...state.customFields, 'model': v}),
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Storage'),
          onChanged: (v) => notifier.updateCustomFields({...state.customFields, 'storage': v}),
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Network'),
          onChanged: (v) => notifier.updateCustomFields({...state.customFields, 'network': v}),
        ),
      ];
    } else if (state.category == 'Clothing') {
      fields = [
        TextField(
          decoration: const InputDecoration(labelText: 'Size'),
          onChanged: (v) => notifier.updateCustomFields({...state.customFields, 'size': v}),
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Gender'),
          onChanged: (v) => notifier.updateCustomFields({...state.customFields, 'gender': v}),
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Material'),
          onChanged: (v) => notifier.updateCustomFields({...state.customFields, 'material': v}),
        ),
      ];
    } else if (state.category == 'Hairdressing') {
      fields = [
        TextField(
          decoration: const InputDecoration(labelText: 'Service Type'),
          onChanged: (v) => notifier.updateCustomFields({...state.customFields, 'serviceType': v}),
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Duration'),
          onChanged: (v) => notifier.updateCustomFields({...state.customFields, 'duration': v}),
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Gender Served'),
          onChanged: (v) => notifier.updateCustomFields({...state.customFields, 'genderServed': v}),
        ),
      ];
    } else {
      fields = [
        const Text('No custom fields for this category.'),
      ];
    }
    return ListingAccessGuard(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Custom Fields'),
          leading: BackButton(onPressed: () {
            context.goNamed('addProductStep2');
          }),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      onPressed: () {
                        context.pushNamed('addProductStep4');
                      },
                      child: const Text('Next'),
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