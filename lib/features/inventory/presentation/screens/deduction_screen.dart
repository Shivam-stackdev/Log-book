import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:army_mess_inventory/main.dart';
import 'package:army_mess_inventory/features/inventory/presentation/widgets/glass_widgets.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/item_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/transaction_entity.dart';
import 'package:army_mess_inventory/features/reports/data/pdf_report_service.dart';
import 'package:uuid/uuid.dart';

class DeductionScreen extends ConsumerStatefulWidget {
  const DeductionScreen({super.key});

  @override
  ConsumerState<DeductionScreen> createState() => _DeductionScreenState();
}

class _DeductionScreenState extends ConsumerState<DeductionScreen> {
  ItemEntity? _selectedItem;
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController(text: 'Daily Messing');
  final TextEditingController _searchController = TextEditingController();
  bool _showDropdown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionChangeProvider).loadTodayTransactions();
      ref.read(inventoryChangeProvider).loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = ref.watch(inventoryChangeProvider);
    final transactionProvider = ref.watch(transactionChangeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: GlassAppBar(
        title: 'Daily Deduction',
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Generate Daily Bill PDF',
            onPressed: () => _generateDailyBillPdf(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Record Consumption',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            // Searchable Item Dropdown
            _buildSearchableDropdown(inventoryProvider.items, isDark),
            const SizedBox(height: 20),

            TextField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: 'Quantity',
                suffixText: _selectedItem?.unit ?? '',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(labelText: 'Reason/Event'),
            ),

            if (_selectedItem != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.blue.withValues(alpha: 0.15) : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Available: ${_selectedItem!.currentStock.toStringAsFixed(1)} ${_selectedItem!.unit}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    if (_selectedItem!.unitCost > 0) ...[
                      const Spacer(),
                      Text(
                        'Rs ${_selectedItem!.unitCost.toStringAsFixed(2)}/${_selectedItem!.unit}',
                        style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            const Spacer(),

            // Today's deductions summary
            _buildTodaySummary(transactionProvider, isDark),
            const SizedBox(height: 16),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _saveDeduction,
              child: const Text('Confirm Deduction', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchableDropdown(List<ItemEntity> items, bool isDark) {
    final activeItem = _selectedItem != null
        ? (items.where((i) => i.id == _selectedItem!.id).firstOrNull ?? _selectedItem)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: () => setState(() => _showDropdown = !_showDropdown),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(
                color: _showDropdown
                    ? Colors.green
                    : (isDark ? Colors.white24 : Colors.grey.shade300),
                width: _showDropdown ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade100,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    activeItem != null
                        ? '${activeItem.name} (${activeItem.currentStock.toStringAsFixed(1)} ${activeItem.unit})'
                        : 'Select Item',
                    style: TextStyle(
                      color: activeItem != null
                          ? (isDark ? Colors.white : Colors.black87)
                          : (isDark ? Colors.white54 : Colors.black54),
                    ),
                  ),
                ),
                Icon(
                  _showDropdown ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ],
            ),
          ),
        ),
        if (_showDropdown) ...[
          const SizedBox(height: 4),
          Container(
            constraints: const BoxConstraints(maxHeight: 250),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search items...',
                      prefixIcon: Icon(Icons.search, size: 20),
                      isDense: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: items
                        .where((item) => item.name.toLowerCase().contains(_searchController.text.toLowerCase()))
                        .map((item) {
                      final isZero = item.currentStock <= 0;
                      return ListTile(
                        dense: true,
                        title: Text(
                          '${item.name} (${item.currentStock.toStringAsFixed(1)} ${item.unit})',
                          style: TextStyle(
                            color: isZero ? Colors.red : null,
                            fontWeight: isZero ? FontWeight.bold : null,
                          ),
                        ),
                        trailing: isZero
                            ? const Text('OUT', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold))
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedItem = item;
                            _showDropdown = false;
                            _searchController.clear();
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTodaySummary(dynamic transactionProvider, bool isDark) {
    final todayDeductions = transactionProvider.todayTransactions
        .where((t) => t.type == 'deduction')
        .toList();

    if (todayDeductions.isEmpty) return const SizedBox.shrink();

    final totalCost = todayDeductions.fold<double>(0, (sum, t) => sum + t.cost);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.orange.withValues(alpha: 0.15) : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Deductions: ${todayDeductions.length} items | Rs ${totalCost.toStringAsFixed(2)}",
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  void _saveDeduction() async {
    if (_selectedItem == null || _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an item and enter quantity')),
      );
      return;
    }

    final inventoryProvider = ref.read(inventoryChangeProvider);
    final item = inventoryProvider.getItemById(_selectedItem!.id) ?? _selectedItem!;
    final itemName = item.name;
    final itemUnit = item.unit;

    final quantity = double.tryParse(_quantityController.text) ?? 0;
    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid quantity')),
      );
      return;
    }

    if (quantity > item.currentStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Insufficient stock! Only ${item.currentStock.toStringAsFixed(1)} $itemUnit available.')),
      );
      return;
    }

    final cost = quantity * item.unitCost;

    final transaction = TransactionEntity(
      id: const Uuid().v4(),
      itemId: item.id,
      itemName: itemName,
      quantity: quantity,
      type: 'deduction',
      reason: _reasonController.text.trim().isEmpty ? 'Daily Messing' : _reasonController.text.trim(),
      date: DateTime.now(),
      cost: cost,
      unitPrice: item.unitCost,
    );

    // Reset local selection & form state BEFORE calling async reloads
    _quantityController.clear();
    setState(() {
      _selectedItem = null;
      _showDropdown = false;
    });

    try {
      final success = await ref.read(transactionChangeProvider).addTransaction(transaction);
      if (success) {
        await ref.read(inventoryChangeProvider).loadItems();
        await ref.read(dashboardChangeProvider).refresh();
        await ref.read(transactionChangeProvider).loadTodayTransactions();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Deducted ${quantity.toStringAsFixed(1)} $itemUnit of $itemName')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to record deduction')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error recording deduction: $e')),
        );
      }
    }
  }

  void _generateDailyBillPdf(BuildContext context) async {
    final items = ref.read(inventoryChangeProvider).items;
    final todayTxns = ref.read(transactionChangeProvider).todayTransactions
        .where((t) => t.type == 'deduction')
        .toList();

    if (todayTxns.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No deductions today to generate bill')),
      );
      return;
    }

    final pdfService = PdfReportService();
    await pdfService.generateDailyBillPdf(todayTxns, items);
  }
}
