import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:army_mess_inventory/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:army_mess_inventory/features/inventory/presentation/widgets/glass_widgets.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/item_entity.dart';
import 'package:uuid/uuid.dart';

class StockListScreen extends ConsumerStatefulWidget {
  const StockListScreen({super.key});

  @override
  ConsumerState<StockListScreen> createState() => _StockListScreenState();
}

class _StockListScreenState extends ConsumerState<StockListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final inventoryAsync = ref.watch(inventoryListProvider);

    return Scaffold(
      appBar: GlassAppBar(
        title: 'Stock Inventory',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddItemDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search items...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: inventoryAsync.when(
              data: (items) {
                final filteredItems = items.where((item) {
                  return item.name.toLowerCase().contains(_searchQuery) ||
                      item.category.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredItems.isEmpty) {
                  return const Center(child: Text('No items found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return _buildItemCard(item);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(ItemEntity item) {
    final bool isLowStock = item.currentStock <= item.reorderLevel;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: isLowStock ? Colors.red.shade50 : Colors.green.shade50,
          child: Icon(
            Icons.inventory_2,
            color: isLowStock ? Colors.red : Colors.green,
          ),
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${item.category} • ${item.unit}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${item.currentStock}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isLowStock ? Colors.red : Colors.black87,
              ),
            ),
            if (isLowStock)
              const Text(
                'Low Stock',
                style: TextStyle(color: Colors.red, fontSize: 10),
              ),
          ],
        ),
        onTap: () => _showItemDetails(item),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final nameController = TextEditingController();
    final unitController = TextEditingController();
    final categoryController = TextEditingController();
    final reorderController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
              ),
              TextField(
                controller: unitController,
                decoration: const InputDecoration(labelText: 'Unit (e.g., kg, ltr, pkt)'),
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              TextField(
                controller: reorderController,
                decoration: const InputDecoration(labelText: 'Reorder Level'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newItem = ItemEntity(
                id: const Uuid().v4(),
                name: nameController.text,
                unit: unitController.text,
                category: categoryController.text,
                currentStock: 0,
                reorderLevel: double.tryParse(reorderController.text) ?? 0,
              );
              ref.read(inventoryListProvider.notifier).addItem(newItem);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showItemDetails(ItemEntity item) {
    // Show item details and history
  }
}
