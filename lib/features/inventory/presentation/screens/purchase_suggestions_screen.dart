import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:army_mess_inventory/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:army_mess_inventory/features/inventory/presentation/widgets/glass_widgets.dart';

class PurchaseSuggestionsScreen extends ConsumerWidget {
  const PurchaseSuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionsAsync = ref.watch(purchaseSuggestionsProvider);

    return Scaffold(
      appBar: const GlassAppBar(title: 'Purchase Suggestions'),
      body: suggestionsAsync.when(
        data: (suggestions) {
          if (suggestions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
                  SizedBox(height: 20),
                  Text('All items are well stocked!', style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = suggestions[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getPriorityColor(suggestion.priority).withOpacity(0.1),
                    child: Icon(Icons.shopping_cart, color: _getPriorityColor(suggestion.priority)),
                  ),
                  title: Text(suggestion.item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Current: ${suggestion.item.currentStock} | Suggest: +${suggestion.suggestedQuantity.toStringAsFixed(1)} ${suggestion.item.unit}'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(suggestion.priority).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      suggestion.priority,
                      style: TextStyle(
                        color: _getPriorityColor(suggestion.priority),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High': return Colors.red;
      case 'Medium': return Colors.orange;
      default: return Colors.blue;
    }
  }
}
