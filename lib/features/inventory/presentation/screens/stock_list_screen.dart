import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:army_mess_inventory/main.dart';
import 'package:army_mess_inventory/features/inventory/presentation/widgets/glass_widgets.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/item_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/transaction_entity.dart';
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
    final inventoryProvider = ref.watch(inventoryChangeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),
          Expanded(
            child: inventoryProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : inventoryProvider.error != null
                    ? Center(child: Text(inventoryProvider.error!))
                    : _buildItemList(inventoryProvider.items, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildItemList(List<ItemEntity> items, bool isDark) {
    final filteredItems = items.where((item) {
      return item.name.toLowerCase().contains(_searchQuery) ||
          item.category.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: isDark ? Colors.white38 : Colors.grey),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'No items in inventory' : 'No matching items',
              style: TextStyle(fontSize: 16, color: isDark ? Colors.white54 : Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredItems.length,
      itemExtent: 80,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return _buildItemCard(item, isDark);
      },
    );
  }

  Widget _buildItemCard(ItemEntity item, bool isDark) {
    final bool isLowStock = item.currentStock <= item.reorderLevel;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: isLowStock
              ? Colors.red.withValues(alpha: 0.15)
              : Colors.green.withValues(alpha: 0.15),
          child: Icon(
            Icons.inventory_2,
            color: isLowStock ? Colors.red : Colors.green,
          ),
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${item.category} | ${item.unit}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${item.currentStock.toStringAsFixed(1)} ${item.unit}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isLowStock ? Colors.red : (isDark ? Colors.white : Colors.black87),
              ),
            ),
            if (isLowStock)
              const Text('Low Stock', style: TextStyle(color: Colors.red, fontSize: 10)),
          ],
        ),
        onTap: () => _showStockBottomSheet(item),
      ),
    );
  }

  void _showStockBottomSheet(ItemEntity item) {
    final addQtyCtrl = TextEditingController();
    final addCostCtrl = TextEditingController();
    final deductQtyCtrl = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white30 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                item.name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.green.withValues(alpha: 0.15) : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Current Stock', style: TextStyle(fontSize: 16)),
                    Text(
                      '${item.currentStock.toStringAsFixed(1)} ${item.unit}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Add Stock Section
              Text('Add Stock', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.green.shade700)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: addQtyCtrl,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        suffixText: item.unit,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: addCostCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Cost/Unit (Rs)',
                        prefixText: 'Rs ',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Stock'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                ),
                onPressed: () => _addStock(ctx, item, addQtyCtrl.text, addCostCtrl.text),
              ),

              const SizedBox(height: 20),
              Divider(color: isDark ? Colors.white24 : Colors.grey.shade300),
              const SizedBox(height: 12),

              // Deduct Stock Section
              Text('Deduct Stock (Manual Correction)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.orange.shade700)),
              const SizedBox(height: 8),
              TextField(
                controller: deductQtyCtrl,
                decoration: InputDecoration(
                  labelText: 'Quantity to Deduct',
                  suffixText: item.unit,
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.remove),
                label: const Text('Deduct Stock'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                ),
                onPressed: () => _deductStock(ctx, item, deductQtyCtrl.text),
              ),

              const SizedBox(height: 20),
              Divider(color: isDark ? Colors.white24 : Colors.grey.shade300),
              const SizedBox(height: 8),

              // Delete item
              TextButton.icon(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text('Delete Item', style: TextStyle(color: Colors.red)),
                onPressed: () => _deleteItem(ctx, item),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _addStock(BuildContext ctx, ItemEntity item, String qtyStr, String costStr) async {
    final qty = double.tryParse(qtyStr) ?? 0;
    final cost = double.tryParse(costStr) ?? 0;

    if (qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid quantity')),
      );
      return;
    }

    final transaction = TransactionEntity(
      id: const Uuid().v4(),
      itemId: item.id,
      itemName: item.name,
      quantity: qty,
      type: 'addition',
      reason: 'Stock Addition',
      date: DateTime.now(),
      cost: qty * cost,
      unitPrice: cost,
    );

    final success = await ref.read(transactionChangeProvider).addTransaction(transaction);
    if (success) {
      await ref.read(inventoryChangeProvider).loadItems();
      await ref.read(dashboardChangeProvider).refresh();
      if (mounted) {
        Navigator.pop(ctx);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added $qty ${item.unit} of ${item.name}')),
        );
      }
    }
  }

  void _deductStock(BuildContext ctx, ItemEntity item, String qtyStr) async {
    final qty = double.tryParse(qtyStr) ?? 0;

    if (qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid quantity')),
      );
      return;
    }

    if (qty > item.currentStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient stock!')),
      );
      return;
    }

    final transaction = TransactionEntity(
      id: const Uuid().v4(),
      itemId: item.id,
      itemName: item.name,
      quantity: qty,
      type: 'deduction',
      reason: 'Manual Correction',
      date: DateTime.now(),
      cost: qty * item.unitCost,
      unitPrice: item.unitCost,
    );

    final success = await ref.read(transactionChangeProvider).addTransaction(transaction);
    if (success) {
      await ref.read(inventoryChangeProvider).loadItems();
      await ref.read(dashboardChangeProvider).refresh();
      if (mounted) {
        Navigator.pop(ctx);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deducted $qty ${item.unit} of ${item.name}')),
        );
      }
    }
  }

  void _deleteItem(BuildContext ctx, ItemEntity item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(inventoryChangeProvider).deleteItem(item.id);
      await ref.read(dashboardChangeProvider).refresh();
      if (mounted) {
        Navigator.pop(ctx);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${item.name} deleted')),
        );
      }
    }
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
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: unitController,
                decoration: const InputDecoration(labelText: 'Unit (e.g., kg, ltr, pkt)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
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
            onPressed: () async {
              if (nameController.text.isEmpty || unitController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Name and Unit are required')),
                );
                return;
              }
              final newItem = ItemEntity(
                id: const Uuid().v4(),
                name: nameController.text.trim(),
                unit: unitController.text.trim(),
                category: categoryController.text.trim().isEmpty ? 'General' : categoryController.text.trim(),
                currentStock: 0,
                reorderLevel: double.tryParse(reorderController.text) ?? 0,
              );
              await ref.read(inventoryChangeProvider).addItem(newItem);
              await ref.read(dashboardChangeProvider).refresh();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
