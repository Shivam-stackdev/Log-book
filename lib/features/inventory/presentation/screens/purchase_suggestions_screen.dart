import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:army_mess_inventory/core/theme/app_theme.dart';
import 'package:army_mess_inventory/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/purchase_suggestion_entity.dart';
import 'package:army_mess_inventory/features/inventory/presentation/widgets/ui_widgets.dart';

class PurchaseSuggestionsScreen extends ConsumerWidget {
  const PurchaseSuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionsAsync = ref.watch(purchaseSuggestionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Purchase Suggestions')),
      body: suggestionsAsync.when(
        data: (suggestions) {
          if (suggestions.isEmpty) {
            return const EmptyState(icon: Icons.check_circle, title: 'All items are well stocked', subtitle: 'No purchase needed at this time');
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(purchaseSuggestionsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: suggestions.length,
              itemBuilder: (context, index) => _buildSuggestionCard(suggestions[index]),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildSuggestionCard(PurchaseSuggestionEntity suggestion) {
    final priorityColor = switch (suggestion.priority) {
      'High' => AppColors.error,
      'Medium' => AppColors.warning,
      _ => AppColors.primary,
    };
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: priorityColor.withOpacity(0.1), child: Icon(Icons.shopping_cart, color: priorityColor)),
        title: Text(suggestion.item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('Current: ${suggestion.item.currentStock} ${suggestion.item.unit} | Suggested: ${suggestion.suggestedQuantity.toStringAsFixed(1)} ${suggestion.item.unit}'),
        trailing: Chip(label: Text(suggestion.priority, style: TextStyle(color: priorityColor, fontSize: 12, fontWeight: FontWeight.bold))),
      ),
    );
  }
}
