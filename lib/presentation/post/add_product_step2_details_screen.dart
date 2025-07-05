import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/add_product_provider.dart';
import 'package:go_router/go_router.dart';
import 'listing_access_guard.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/services.dart';

class AddProductStep2DetailsScreen extends HookConsumerWidget {
  const AddProductStep2DetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addProductProvider);
    final notifier = ref.read(addProductProvider.notifier);
    final primaryColor = const Color(0xFF32CD32);
    final titleController = useTextEditingController(text: state.title);
    final descController = useTextEditingController(text: state.description);
    final priceController = useTextEditingController(text: state.price == 0.0 ? '' : state.price.toString());
    final conditions = ['New', 'Used'];
    final isValid = state.title.isNotEmpty && state.description.isNotEmpty && state.price > 0 && state.condition.isNotEmpty;
    final priceError = useState<String?>(null);
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
    return ListingAccessGuard(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Product Details'),
          backgroundColor: primaryColor,
          leading: BackButton(onPressed: () {
            context.goNamed('addProductStep1');
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
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: IntrinsicHeight(
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
                                  suffixIcon: titleController.text.isNotEmpty
                                      ? IconButton(icon: const Icon(Icons.clear), onPressed: () => titleController.clear())
                                      : null,
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
                                  suffixIcon: descController.text.isNotEmpty
                                      ? IconButton(icon: const Icon(Icons.clear), onPressed: () => descController.clear())
                                      : null,
                                ),
                                maxLines: 3,
                                onChanged: notifier.updateDescription,
                              ),
                              const SizedBox(height: 16),
                              AppTextInput(
                                label: 'Meetup Location (Optional)',
                                hint: 'e.g., Campus Library, Student Center, Coffee Shop...',
                                value: state.meetupLocation ?? '',
                                onChanged: (value) => ref.read(addProductProvider.notifier).updateMeetupLocation(value),
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
                                  errorText: priceError.value,
                                  suffixIcon: priceController.text.isNotEmpty
                                      ? IconButton(icon: const Icon(Icons.clear), onPressed: () => priceController.clear())
                                      : null,
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*\.?[0-9]*')),
                                ],
                                onChanged: onPriceChanged,
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
                            ],
                          ),
                        ),
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
                          context.pushNamed('addProductStep3');
                        } : null,
                        child: const Text('Next', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
} 