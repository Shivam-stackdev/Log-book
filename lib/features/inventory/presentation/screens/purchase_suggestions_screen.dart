import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:army_mess_inventory/main.dart';
import 'package:army_mess_inventory/features/inventory/presentation/widgets/glass_widgets.dart';

class PurchaseSuggestionsScreen extends ConsumerWidget {
  const PurchaseSuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryProvider = ref.watch(inventoryChangeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final lowStockItems = inventoryProvider.items
        .where((item) => item.reorderLevel > 0 && item.currentStock <= item.reorderLevel)
        .toList();

    // Sort: highest priority (zero stock) first
    lowStockItems.sort((a, b) {
      if (a.currentStock == 0 && b.currentStock > 0) return -1;
      if (b.currentStock == 0 && a.currentStock > 0) return 1;
      return (a.currentStock / (a.reorderLevel == 0 ? 1 : a.reorderLevel))
          .compareTo(b.currentStock / (b.reorderLevel == 0 ? 1 : b.reorderLevel));
    });

    return Scaffold(
      appBar: const GlassAppBar(title: 'Purchase Suggestions'),
      body: lowStockItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 80, color: Colors.green.shade400),
                  const SizedBox(height: 20),
                  Text(
                    'All items are well stocked!',
                    style: TextStyle(
                      fontSize: 18,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: lowStockItems.length,
              itemBuilder: (context, index) {
                final item = lowStockItems[index];
                final deficit = item.reorderLevel - item.currentStock;
                final suggestedQty = deficit + (item.reorderLevel * 0.5);

                String priority = 'Low';
                Color priorityColor = Colors.blue;
                if (item.currentStock == 0) {
                  priority = 'Critical';
                  priorityColor = Colors.red;
                } else if (item.currentStock <= item.reorderLevel * 0.5) {
                  priority = 'High';
                  priorityColor = Colors.orange;
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: priorityColor.withValues(alpha: 0.15),
                      child: Icon(Icons.shopping_cart, color: priorityColor),
                    ),
                    title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      'Stock: ${item.currentStock.toStringAsFixed(1)} ${item.unit} | Suggest: +${suggestedQty.toStringAsFixed(1)} ${item.unit}',
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: priorityColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        priority,
                        style: TextStyle(
                          color: priorityColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
