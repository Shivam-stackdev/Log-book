import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:army_mess_inventory/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:army_mess_inventory/features/inventory/presentation/widgets/glass_widgets.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/stock_entry_entity.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryAsync = ref.watch(inventoryListProvider);

    return Scaffold(
      appBar: const GlassAppBar(title: 'Inventory History'),
      body: inventoryAsync.when(
        data: (items) {
          if (items.isEmpty) return const Center(child: Text('No items in inventory'));
          
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ExpansionTile(
                leading: const Icon(Icons.history),
                title: Text(item.name),
                subtitle: Text('Current Stock: ${item.currentStock} ${item.unit}'),
                children: [
                  ref.watch(itemHistoryProvider(item.id)).when(
                    data: (history) {
                      if (history.isEmpty) return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No history for this item'),
                      );
                      
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: history.length,
                        itemBuilder: (context, hIndex) {
                          final entry = history[hIndex];
                          final bool isStock = entry is StockEntryEntity;
                          
                          return ListTile(
                            leading: Icon(
                              isStock ? Icons.add_circle_outline : Icons.remove_circle_outline,
                              color: isStock ? Colors.green : Colors.red,
                            ),
                            title: Text(isStock ? 'Added: ${entry.quantity} ${item.unit}' : 'Deducted: ${entry.quantity} ${item.unit}'),
                            subtitle: Text(DateFormat('dd MMM yyyy, hh:mm a').format(entry.date)),
                            trailing: Text(isStock ? 'From: ${entry.supplier}' : 'Reason: ${entry.reason}', style: const TextStyle(fontSize: 12)),
                          );
                        },
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (e, s) => Text('Error: $e'),
                  ),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
