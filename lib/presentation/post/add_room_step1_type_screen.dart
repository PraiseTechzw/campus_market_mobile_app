import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/add_room_provider.dart';
import 'package:go_router/go_router.dart';
import 'listing_access_guard.dart';

class AddRoomStep1TypeScreen extends HookConsumerWidget {
  const AddRoomStep1TypeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addRoomProvider);
    final notifier = ref.read(addRoomProvider.notifier);
    final types = [
      {'label': 'Single Room', 'icon': Icons.person, 'desc': 'Private room for one'},
      {'label': '2-share', 'icon': Icons.people, 'desc': 'Shared room for two'},
      {'label': '3-share', 'icon': Icons.groups, 'desc': 'Shared room for three'},
      {'label': '4-share', 'icon': Icons.groups_2, 'desc': 'Shared room for four'},
    ];
    final primaryColor = const Color(0xFF32CD32);
    return ListingAccessGuard(
      child: Scaffold(
        appBar: AppBar(title: const Text('Choose Room Type'), backgroundColor: primaryColor),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress indicator
                  Row(
                    children: [
                      Text('Step 1 of 4', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: 0.25,
                          color: primaryColor,
                          backgroundColor: primaryColor.withOpacity(0.15),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Select Room Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.8,
                      children: types.map((type) {
                        final isSelected = state.roomType == type['label'];
                        return GestureDetector(
                          onTap: () => notifier.updateRoomType(type['label'] as String),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected ? primaryColor.withOpacity(0.08) : Colors.grey[900],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? primaryColor : Colors.grey[700]!,
                                width: isSelected ? 2.5 : 1.2,
                              ),
                              boxShadow: isSelected
                                ? [BoxShadow(color: primaryColor.withOpacity(0.15), blurRadius: 8, offset: Offset(0, 4))]
                                : [],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(type['icon'] as IconData, color: primaryColor, size: 40),
                                const SizedBox(height: 12),
                                Text(
                                  type['label'] as String,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isSelected ? primaryColor : Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  type['desc'] as String,
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 0, right: 0, bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: state.roomType.isNotEmpty ? primaryColor : Colors.grey[800],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: state.roomType.isNotEmpty ? () {
                          context.pushNamed('addRoomStep2');
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