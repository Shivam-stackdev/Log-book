import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:army_mess_inventory/core/theme/app_theme.dart';
import 'package:army_mess_inventory/core/utils/app_localizations.dart';
import 'package:army_mess_inventory/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:army_mess_inventory/features/inventory/presentation/widgets/ui_widgets.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/item_entity.dart';
import 'package:uuid/uuid.dart';

class StockListScreen extends ConsumerStatefulWidget {
  const StockListScreen({super.key});
  @override
  ConsumerState<StockListScreen> createState() => _StockListScreenState();
}

class _StockListScreenState extends ConsumerState<StockListScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  late List<String> _categories;

  @override
  void initState() {
    super.initState();
    _categories = ['All', 'Food', 'Vegetables', 'Meat', 'Grocery', 'Beverages', 'Other'];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final inventoryAsync = ref.watch(inventoryListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('stock_management'))),
      body: inventoryAsync.when(
        data: (items) {
          final filtered = _filterItems(items);
          if (filtered.isEmpty) {
            return EmptyState(
              icon: Icons.inventory_2,
              title: 'No items found',
              subtitle: _searchQuery.isEmpty ? 'Add your first item' : 'Try a different search',
              actionButton: _searchQuery.isEmpty ? FilledButton.icon(
                onPressed: () => _showAddItemDialog(context, l10n),
                icon: const Icon(Icons.add), label: const Text('Add Item'),
              ) : null,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.read(inventoryListProvider.notifier).refresh(),
            child: Column(
              children: [
                _buildSearchAndFilter(l10n),
                Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    itemBuilder: (context, index) => _buildItemCard(context, filtered[index], l10n),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context, l10n),
        child: const Icon(Icons.add),
      ),
    );
  }

  List<ItemEntity> _filterItems(List<ItemEntity> items) {
    return items.where((item) {
      final matchesSearch = _searchQuery.isEmpty || item.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || item.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  Widget _buildSearchAndFilter(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Search items...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _searchQuery = '')) : null,
          ),
          onChanged: (v) => setState(() => _searchQuery = v),
        ),
        const SizedBox(height: AppSpacing.sm),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
          for (final cat in _categories)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: FilterChip(
                label: Text(cat),
                selected: _selectedCategory == cat,
                onSelected: (_) => setState(() => _selectedCategory = cat),
              ),
            ),
        ])),
      ]),
    );
  }

  Widget _buildItemCard(BuildContext context, ItemEntity item, AppLocalizations l10n) {
    final stockColor = item.isOutOfStock ? AppColors.error : item.isLowStock ? AppColors.warning : AppColors.success;
    final stockLabel = item.isOutOfStock ? 'Out of Stock' : item.isLowStock ? 'Low Stock' : 'Adequate';

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: stockColor.withOpacity(0.1), child: Icon(Icons.inventory_2, color: stockColor)),
        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text('${item.category} • ${item.rate > 0 ? 'Rs. ${item.rate}/${item.unit}' : 'No rate set'}'),
        trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${item.currentStock}', style: TextStyle(fontWeight: FontWeight.bold, color: stockColor, fontSize: 18)),
          Text(item.unit, style: Theme.of(context).textTheme.labelSmall),
        ]),
        onTap: () => _showItemDetails(context, item, l10n),
        onLongPress: () => _showItemActions(context, item, l10n),
      ),
    );
  }

  void _showItemDetails(BuildContext context, ItemEntity item, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.name, style: Theme.of(context).textTheme.headlineSmall),
          const Divider(height: 32),
          _detailRow('Category', item.category),
          _detailRow('Current Stock', '${item.currentStock} ${item.unit}'),
          _detailRow('Reorder Level', '${item.reorderLevel} ${item.unit}'),
          _detailRow('Rate', 'Rs. ${item.rate}/${item.unit}'),
          const SizedBox(height: AppSpacing.lg),
          Row(children: [
            Expanded(child: OutlinedButton.icon(icon: const Icon(Icons.edit), label: const Text('Edit'), onPressed: () { Navigator.pop(ctx); _showEditItemDialog(context, item, l10n); })),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: FilledButton.icon(icon: const Icon(Icons.delete_outline), label: const Text('Delete'), style: FilledButton.styleFrom(backgroundColor: AppColors.error), onPressed: () { Navigator.pop(ctx); _deleteItem(item); })),
          ]),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ]),
    );
  }

  void _showItemActions(BuildContext context, ItemEntity item, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(leading: const Icon(Icons.edit), title: const Text('Edit Item'), onTap: () { Navigator.pop(ctx); _showEditItemDialog(context, item, l10n); }),
        ListTile(leading: const Icon(Icons.delete_outline, color: AppColors.error), title: const Text('Delete Item', style: TextStyle(color: AppColors.error)), onTap: () { Navigator.pop(ctx); _deleteItem(item); }),
      ]),
    );
  }

  void _showAddItemDialog(BuildContext context, AppLocalizations l10n, {ItemEntity? existing}) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final stockController = TextEditingController(text: existing?.currentStock.toString() ?? '0');
    final reorderController = TextEditingController(text: existing?.reorderLevel.toString() ?? '10');
    final rateController = TextEditingController(text: existing?.rate.toString() ?? '0');
    final unitController = TextEditingController(text: existing?.unit ?? 'Kg');
    final categoryController = TextEditingController(text: existing?.category ?? 'Food');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Add New Item' : 'Edit Item'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Item Name'), autofocus: true),
          const SizedBox(height: AppSpacing.sm),
          Row(children: [
            Expanded(child: TextField(controller: stockController, decoration: const InputDecoration(labelText: 'Current Stock'), keyboardType: TextInputType.number)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: TextField(controller: unitController, decoration: const InputDecoration(labelText: 'Unit'), keyboardType: TextInputType.text)),
          ]),
          const SizedBox(height: AppSpacing.sm),
          Row(children: [
            Expanded(child: TextField(controller: reorderController, decoration: const InputDecoration(labelText: 'Reorder Level'), keyboardType: TextInputType.number)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: TextField(controller: rateController, decoration: const InputDecoration(labelText: 'Rate (Rs.)'), keyboardType: TextInputType.number)),
          ]),
          const SizedBox(height: AppSpacing.sm),
          TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Category')),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () async {
            Navigator.pop(ctx);
            final item = ItemEntity(
              id: existing?.id ?? const Uuid().v4(),
              name: nameController.text,
              unit: unitController.text,
              currentStock: double.tryParse(stockController.text) ?? 0,
              reorderLevel: double.tryParse(reorderController.text) ?? 10,
              category: categoryController.text,
              rate: double.tryParse(rateController.text) ?? 0,
            );
            final notifier = ref.read(inventoryListProvider.notifier);
            if (existing == null) {
              await notifier.addItem(item);
            } else {
              await notifier.updateItem(item);
            }
          }, child: const Text('Save')),
        ],
      ),
    );
  }

  void _showEditItemDialog(BuildContext context, ItemEntity item, AppLocalizations l10n) {
    _showAddItemDialog(context, l10n, existing: item);
  }

  Future<void> _deleteItem(ItemEntity item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Delete "${item.name}"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(style: FilledButton.styleFrom(backgroundColor: AppColors.error), onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(inventoryListProvider.notifier).deleteItem(item.id);
    }
  }
}
