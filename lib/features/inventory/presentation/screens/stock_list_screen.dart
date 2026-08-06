import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:army_mess_inventory/main.dart';
import 'package:army_mess_inventory/features/inventory/data/preloaded_inventory_assets.dart';
import 'package:army_mess_inventory/features/inventory/presentation/widgets/glass_widgets.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/item_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/transaction_entity.dart';
import 'package:uuid/uuid.dart';

enum _StockSortMode { frequent, alphabetical }

class StockListScreen extends ConsumerStatefulWidget {
  const StockListScreen({super.key});

  @override
  ConsumerState<StockListScreen> createState() => _StockListScreenState();
}

class _StockListScreenState extends ConsumerState<StockListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  _StockSortMode _sortMode = _StockSortMode.frequent;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(inventoryChangeProvider).loadItems();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
            tooltip: 'Add custom item',
            onPressed: () => _showItemDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(inventoryProvider.categories),
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

  Widget _buildSearchAndFilters(List<String> categories) {
    final allCategories = ['All', ...categories];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Fast search by name or category...',
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
            onChanged: (value) => setState(() => _searchQuery = value.trim().toLowerCase()),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: allCategories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = allCategories[index];
                      return ChoiceChip(
                        label: Text(category),
                        selected: _selectedCategory == category,
                        onSelected: (_) => setState(() => _selectedCategory = category),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<_StockSortMode>(
                value: _sortMode,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(value: _StockSortMode.frequent, child: Text('Frequent')),
                  DropdownMenuItem(value: _StockSortMode.alphabetical, child: Text('A-Z')),
                ],
                onChanged: (mode) {
                  if (mode != null) setState(() => _sortMode = mode);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemList(List<ItemEntity> items, bool isDark) {
    final filteredItems = items.where((item) {
      final matchesSearch = _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(_searchQuery) ||
          item.category.toLowerCase().contains(_searchQuery);
      final matchesCategory = _selectedCategory == 'All' || item.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    filteredItems.sort((a, b) {
      if (_sortMode == _StockSortMode.frequent) {
        final usageCompare = b.usageCount.compareTo(a.usageCount);
        if (usageCompare != 0) return usageCompare;
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filteredItems.length,
      itemExtent: 88,
      cacheExtent: 900,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return _buildItemCard(item, isDark);
      },
    );
  }

  Widget _buildItemCard(ItemEntity item, bool isDark) {
    final bool isLowStock = item.reorderLevel > 0 && item.currentStock <= item.reorderLevel;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: isLowStock ? Colors.red.withValues(alpha: 0.15) : Colors.green.withValues(alpha: 0.15),
          child: Icon(
            Icons.inventory_2,
            color: isLowStock ? Colors.red : Colors.green,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                item.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: item.isPreloaded ? Colors.blue.withValues(alpha: 0.12) : Colors.purple.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                item.isPreloaded ? 'Asset' : 'Custom',
                style: TextStyle(fontSize: 10, color: item.isPreloaded ? Colors.blue : Colors.purple),
              ),
            ),
          ],
        ),
        subtitle: Text('${item.category} | ${item.unit} | Used ${item.usageCount}x'),
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
            if (isLowStock) const Text('Low Stock', style: TextStyle(color: Colors.red, fontSize: 10)),
          ],
        ),
        onTap: () => _showStockBottomSheet(item),
      ),
    );
  }

  void _showStockBottomSheet(ItemEntity item) {
    final addQtyCtrl = TextEditingController();
    final addCostCtrl = TextEditingController(text: item.unitCost == 0 ? '' : item.unitCost.toString());
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
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Edit Item Details'),
                onPressed: () {
                  Navigator.pop(ctx);
                  _showItemDialog(context, item: item);
                },
              ),
              const SizedBox(height: 20),

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
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
                onPressed: () => _addStock(ctx, item, addQtyCtrl.text, addCostCtrl.text),
              ),

              const SizedBox(height: 20),
              Divider(color: isDark ? Colors.white24 : Colors.grey.shade300),
              const SizedBox(height: 12),

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
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade700),
                onPressed: () => _deductStock(ctx, item, deductQtyCtrl.text),
              ),

              const SizedBox(height: 20),
              Divider(color: isDark ? Colors.white24 : Colors.grey.shade300),
              const SizedBox(height: 8),

              if (item.isPreloaded)
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.lock_outline),
                  title: Text('Preloaded asset'),
                  subtitle: Text('Protected assets can be edited but are not deletable by default.'),
                )
              else
                TextButton.icon(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text('Delete Custom Item', style: TextStyle(color: Colors.red)),
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
        title: const Text('Delete Custom Item'),
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
      final success = await ref.read(inventoryChangeProvider).deleteItem(item.id);
      await ref.read(dashboardChangeProvider).refresh();
      if (mounted) {
        Navigator.pop(ctx);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(success ? '${item.name} deleted' : 'This preloaded asset cannot be deleted')),
        );
      }
    }
  }

  void _showItemDialog(BuildContext context, {ItemEntity? item}) {
    final nameController = TextEditingController(text: item?.name ?? '');
    final categoryController = TextEditingController(text: item?.category ?? '');
    final stockController = TextEditingController(text: item == null ? '0' : item.currentStock.toString());
    final reorderController = TextEditingController(text: item == null ? '' : item.reorderLevel.toString());
    final unitCostController = TextEditingController(text: item == null || item.unitCost == 0 ? '' : item.unitCost.toString());
    final availableUnits = {...InventoryCatalog.supportedUnits, if (item != null) item.unit}.toList();
    String selectedUnit = item?.unit ?? 'Kg';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(item == null ? 'Add New Item' : 'Edit Item Details'),
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
                DropdownButtonFormField<String>(
                  value: selectedUnit,
                  decoration: const InputDecoration(labelText: 'Default Unit'),
                  items: availableUnits.map((unit) => DropdownMenuItem(value: unit, child: Text(unit))).toList(),
                  onChanged: (unit) {
                    if (unit != null) setDialogState(() => selectedUnit = unit);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: stockController,
                  decoration: const InputDecoration(labelText: 'Opening / Current Stock'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: reorderController,
                  decoration: const InputDecoration(labelText: 'Low Stock Threshold'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: unitCostController,
                  decoration: const InputDecoration(labelText: 'Cost/Unit (Rs)', prefixText: 'Rs '),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty || selectedUnit.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name and Unit are required')),
                  );
                  return;
                }

                final stock = double.tryParse(stockController.text.trim()) ?? 0;
                final savedItem = ItemEntity(
                  id: item?.id ?? const Uuid().v4(),
                  name: nameController.text.trim(),
                  unit: selectedUnit.trim(),
                  category: categoryController.text.trim().isEmpty ? 'General' : categoryController.text.trim(),
                  currentStock: stock < 0 ? 0 : stock,
                  reorderLevel: double.tryParse(reorderController.text.trim()) ?? 0,
                  unitCost: double.tryParse(unitCostController.text.trim()) ?? item?.unitCost ?? 0,
                  isPreloaded: item?.isPreloaded ?? false,
                  usageCount: item?.usageCount ?? 0,
                  assetKey: item?.assetKey,
                );

                final success = item == null
                    ? await ref.read(inventoryChangeProvider).addItem(savedItem)
                    : await ref.read(inventoryChangeProvider).updateItem(savedItem);
                await ref.read(dashboardChangeProvider).refresh();
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(success ? 'Item saved' : 'Failed to save item')),
                  );
                }
              },
              child: Text(item == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}
