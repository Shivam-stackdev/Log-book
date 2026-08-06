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

class _PendingDeduction {
  final ItemEntity item;
  final double quantity;
  final String reason;

  const _PendingDeduction({
    required this.item,
    required this.quantity,
    required this.reason,
  });

  double get cost => quantity * item.unitCost;
}

class _DeductionScreenState extends ConsumerState<DeductionScreen> {
  ItemEntity? _selectedItem;
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController(text: 'Daily Messing');
  final TextEditingController _searchController = TextEditingController();
  final List<_PendingDeduction> _pendingDeductions = [];
  bool _showDropdown = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionChangeProvider).loadTodayTransactions();
      ref.read(inventoryChangeProvider).loadItems();
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    _searchController.dispose();
    super.dispose();
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  children: [
                    Text(
                      'Record Consumption',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add multiple items to the batch, then save them together. The page stays open for continuous daily deductions.',
                      style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
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
                      _buildSelectedItemInfo(_selectedItem!, isDark),
                    ],

                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.playlist_add),
                      onPressed: _isSaving ? null : _addCurrentEntryToBatch,
                      label: const Text('Add Item to Deduction List'),
                    ),

                    const SizedBox(height: 20),
                    _buildPendingDeductions(isDark),
                    const SizedBox(height: 16),

                    // Today's deductions summary
                    _buildTodaySummary(transactionProvider, isDark),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _isSaving ? null : _saveDeductionBatch,
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _pendingDeductions.isEmpty
                            ? 'Confirm Current Deduction'
                            : 'Confirm ${_pendingDeductions.length} Deductions',
                        style: const TextStyle(fontSize: 18),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedItemInfo(ItemEntity selectedItem, bool isDark) {
    final item = _freshItem(selectedItem) ?? selectedItem;
    final reserved = _reservedQuantityFor(item.id);
    final availableAfterBatch = item.currentStock - reserved;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.blue.withValues(alpha: 0.15) : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Available: ${item.currentStock.toStringAsFixed(1)} ${item.unit}'
              '${reserved > 0 ? ' | In batch: ${reserved.toStringAsFixed(1)} | Left: ${availableAfterBatch.toStringAsFixed(1)}' : ''}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          if (item.unitCost > 0)
            Text(
              'Rs ${item.unitCost.toStringAsFixed(2)}/${item.unit}',
              style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchableDropdown(List<ItemEntity> items, bool isDark) {
    final activeItem = _selectedItem != null ? (_freshItem(_selectedItem!) ?? _selectedItem) : null;
    final query = _searchController.text.trim().toLowerCase();
    final filteredItems = items
        .where((item) => item.name.toLowerCase().contains(query) || item.category.toLowerCase().contains(query))
        .take(80)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: () => setState(() => _showDropdown = !_showDropdown),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(
                color: _showDropdown ? Colors.green : (isDark ? Colors.white24 : Colors.grey.shade300),
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
            constraints: const BoxConstraints(maxHeight: 300),
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
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      final reserved = _reservedQuantityFor(item.id);
                      final availableAfterBatch = item.currentStock - reserved;
                      final isZero = availableAfterBatch <= 0;
                      return ListTile(
                        dense: true,
                        title: Text(
                          '${item.name} (${availableAfterBatch.toStringAsFixed(1)} ${item.unit})',
                          style: TextStyle(
                            color: isZero ? Colors.red : null,
                            fontWeight: isZero ? FontWeight.bold : null,
                          ),
                        ),
                        subtitle: Text(item.category),
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
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPendingDeductions(bool isDark) {
    if (_pendingDeductions.isEmpty) return const SizedBox.shrink();

    final totalCost = _pendingDeductions.fold<double>(0, (sum, deduction) => sum + deduction.cost);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.green.withValues(alpha: 0.12) : Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Pending Deduction List (${_pendingDeductions.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text('Rs ${totalCost.toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 8),
          ..._pendingDeductions.asMap().entries.map((entry) {
            final index = entry.key;
            final deduction = entry.value;
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(deduction.item.name),
              subtitle: Text(deduction.reason),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${deduction.quantity.toStringAsFixed(1)} ${deduction.item.unit}'),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: _isSaving
                        ? null
                        : () => setState(() {
                              _pendingDeductions.removeAt(index);
                            }),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTodaySummary(dynamic transactionProvider, bool isDark) {
    final todayDeductions = transactionProvider.todayTransactions.where((t) => t.type == 'deduction').toList();

    if (todayDeductions.isEmpty) return const SizedBox.shrink();

    final totalCost = todayDeductions.fold<double>(0, (sum, t) => sum + t.cost);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.orange.withValues(alpha: 0.15) : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "Today's Deductions: ${todayDeductions.length} items | Rs ${totalCost.toStringAsFixed(2)}",
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }

  ItemEntity? _freshItem(ItemEntity item) {
    return ref.read(inventoryChangeProvider).getItemById(item.id);
  }

  double _reservedQuantityFor(String itemId) {
    return _pendingDeductions
        .where((deduction) => deduction.item.id == itemId)
        .fold<double>(0, (sum, deduction) => sum + deduction.quantity);
  }

  bool _addCurrentEntryToBatch() {
    if (_selectedItem == null || _quantityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an item and enter quantity')),
      );
      return false;
    }

    final item = _freshItem(_selectedItem!) ?? _selectedItem!;
    final quantity = double.tryParse(_quantityController.text.trim()) ?? 0;
    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid quantity')),
      );
      return false;
    }

    final reserved = _reservedQuantityFor(item.id);
    if (quantity + reserved > item.currentStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Insufficient stock! Only ${(item.currentStock - reserved).toStringAsFixed(1)} ${item.unit} available after pending deductions.')),
      );
      return false;
    }

    setState(() {
      _pendingDeductions.add(
        _PendingDeduction(
          item: item,
          quantity: quantity,
          reason: _reasonController.text.trim().isEmpty ? 'Daily Messing' : _reasonController.text.trim(),
        ),
      );
      _selectedItem = null;
      _quantityController.clear();
      _showDropdown = false;
    });
    return true;
  }

  void _saveDeductionBatch() async {
    if (_pendingDeductions.isEmpty && !_addCurrentEntryToBatch()) return;

    final deductions = List<_PendingDeduction>.from(_pendingDeductions);
    final transactions = deductions
        .map(
          (deduction) => TransactionEntity(
            id: const Uuid().v4(),
            itemId: deduction.item.id,
            itemName: deduction.item.name,
            quantity: deduction.quantity,
            type: 'deduction',
            reason: deduction.reason,
            date: DateTime.now(),
            cost: deduction.cost,
            unitPrice: deduction.item.unitCost,
          ),
        )
        .toList();

    setState(() => _isSaving = true);
    try {
      final success = await ref.read(transactionChangeProvider).addTransactions(transactions);
      if (success) {
        await Future.wait([
          ref.read(inventoryChangeProvider).loadItems(),
          ref.read(dashboardChangeProvider).refresh(),
          ref.read(transactionChangeProvider).loadTodayTransactions(),
        ]);
        if (mounted) {
          setState(() {
            _pendingDeductions.clear();
            _selectedItem = null;
            _quantityController.clear();
            _showDropdown = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Saved ${transactions.length} daily deduction${transactions.length == 1 ? '' : 's'}')),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to record deduction. Please check stock quantities.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error recording deduction: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _generateDailyBillPdf(BuildContext context) async {
    final items = ref.read(inventoryChangeProvider).items;
    final todayTxns = ref.read(transactionChangeProvider).todayTransactions.where((t) => t.type == 'deduction').toList();

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
