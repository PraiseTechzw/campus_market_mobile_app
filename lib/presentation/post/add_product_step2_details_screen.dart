import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/add_product_provider.dart';
import 'package:go_router/go_router.dart';
import 'listing_access_guard.dart';

class AddProductStep2DetailsScreen extends HookConsumerWidget {
  const AddProductStep2DetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addProductProvider);
    final notifier = ref.read(addProductProvider.notifier);
    final primaryColor = const Color(0xFF32CD32);
    final titleController = TextEditingController(text: state.title);
    final descController = TextEditingController(text: state.description);
    final priceController = TextEditingController(text: state.price == 0.0 ? '' : state.price.toString());
    final conditions = ['New', 'Used'];
    final isValid = state.title.isNotEmpty && state.description.isNotEmpty && state.price > 0 && state.condition.isNotEmpty;
    return ListingAccessGuard(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Product Details'),
          backgroundColor: primaryColor,
          leading: BackButton(onPressed: () {
            context.goNamed('addProductStep1');
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
                  Text('Step 2 of 5', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: 0.4,
                      color: primaryColor,
                      backgroundColor: primaryColor.withOpacity(0.15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  prefixIcon: const Icon(Icons.title),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  helperText: 'E.g. iPhone 12, Math Tutoring, etc.',
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
                  helperText: 'Describe your product or service...',
                ),
                maxLines: 3,
                onChanged: notifier.updateDescription,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: 'Price (USD)',
                  prefixIcon: const Icon(Icons.attach_money),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  helperText: 'Enter the price (numbers only)',
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) => notifier.updatePrice(double.tryParse(v) ?? 0.0),
              ),
              const SizedBox(height: 16),
              const Text('Condition', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: conditions.map((cond) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ChoiceChip(
                    label: Text(cond),
                    selected: state.condition == cond,
                    selectedColor: primaryColor,
                    onSelected: (_) => notifier.updateCondition(cond),
                    labelStyle: TextStyle(
                      color: state.condition == cond ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    backgroundColor: Colors.grey[900],
                    side: BorderSide(color: state.condition == cond ? primaryColor : Colors.grey[700]!),
                  ),
                )).toList(),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isValid ? primaryColor : Colors.grey[800],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: isValid ? () {
                    context.pushNamed('addProductStep3');
                  } : null,
                  child: const Text('Next', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 