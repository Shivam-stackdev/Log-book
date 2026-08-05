import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:army_mess_inventory/core/theme/app_theme.dart';
import 'package:army_mess_inventory/core/error/app_exceptions.dart';
import 'package:army_mess_inventory/core/logging/logger.dart';
import 'package:army_mess_inventory/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/item_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/deduction_entry_entity.dart';
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
  bool _isProcessing = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventoryAsync = ref.watch(inventoryListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Deduction')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Record Consumption', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.lg),
            _buildItemSelector(inventoryAsync),
            const SizedBox(height: AppSpacing.md),
            _buildQuantityField(),
            const SizedBox(height: AppSpacing.md),
            _buildReasonField(),
            const Spacer(),
            _buildActionButton(),
            const SizedBox(height: AppSpacing.sm),
            _buildUndoButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildItemSelector(AsyncValue<List<ItemEntity>> inventoryAsync) {
    return inventoryAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('No items available. Add items first.'));
        }
        return DropdownButtonFormField<ItemEntity>(
          decoration: const InputDecoration(labelText: 'Select Item'),
          value: _selectedItem,
          isExpanded: true,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                '${item.name} (${item.currentStock.toStringAsFixed(1)} ${item.unit} avail)',
                style: TextStyle(color: item.isLowStock ? AppColors.error : null),
              ),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedItem = value),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (err, stack) => Text('Error loading items: $err'),
    );
  }

  Widget _buildQuantityField() {
    return TextField(
      controller: _quantityController,
      decoration: InputDecoration(
        labelText: 'Quantity',
        suffixText: _selectedItem?.unit ?? '',
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildReasonField() {
    return TextField(
      controller: _reasonController,
      decoration: const InputDecoration(
        labelText: 'Reason / Event',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildActionButton() {
    return ElevatedButton(
      onPressed: _isProcessing ? null : _recordDeduction,
      child: _isProcessing
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : const Text('Record Deduction', style: TextStyle(fontSize: 16)),
    );
  }

  Widget _buildUndoButton() {
    return OutlinedButton.icon(
      onPressed: () => _showUndoDialog(),
      icon: const Icon(Icons.undo),
      label: const Text('Undo Last Deduction'),
    );
  }

  Future<void> _recordDeduction() async {
    if (_selectedItem == null) {
      _showError('Please select an item');
      return;
    }

    final quantity = double.tryParse(_quantityController.text) ?? 0;
    if (quantity <= 0) {
      _showError('Please enter a valid quantity');
      return;
    }

    if (quantity > _selectedItem!.currentStock) {
      _showError(
        'Insufficient stock: Only ${_selectedItem!.currentStock} ${_selectedItem!.unit} available',
      );
      return;
    }

    setState(() => _isProcessing = true);

    final entry = DeductionEntryEntity(
      id: const Uuid().v4(),
      itemId: _selectedItem!.id,
      date: DateTime.now(),
      quantity: quantity,
      reason: _reasonController.text.trim().isEmpty ? 'Daily Messing' : _reasonController.text.trim(),
    );

    final repository = ref.read(inventoryRepositoryProvider);
    final result = await repository.addDeductionEntry(entry);

    setState(() => _isProcessing = false);

    result.fold(
      (error) {
        AppLogger.e('DeductionScreen', 'Deduction failed', error);
        _showError(error.message);
      },
      (_) {
        AppLogger.i('DeductionScreen', 'Deduction recorded: ${_selectedItem!.name} - $quantity');
        ref.read(inventoryListProvider.notifier).refresh();
        _clearForm();
        _showSuccess('Deduction recorded successfully');
      },
    );
  }

  Future<void> _showUndoDialog() async {
    final repository = ref.read(inventoryRepositoryProvider);
    final deductionEntries = await repository.getDeductionEntries(_selectedItem?.id ?? '');

    deductionEntries.fold(
      (error) {
        _showError('Could not load deduction history');
      },
      (entries) {
        if (entries.isEmpty) {
          _showError('No deductions to undo');
          return;
        }
        // Find today's deduction for the selected item
        final todayEntry = entries.where((e) =>
          e.date.day == DateTime.now().day &&
          e.date.month == DateTime.now().month &&
          e.date.year == DateTime.now().year
        ).firstOrNull;

        if (todayEntry == null) {
          _showError('No deduction found for today');
          return;
        }

        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Undo Deduction'),
            content: Text(
              'Undo deduction of ${todayEntry.quantity} '
              '${_selectedItem?.unit ?? 'units'} of ${_selectedItem?.name ?? 'item'}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  final deleteResult = await repository.deleteDeductionEntry(todayEntry.id);
                  deleteResult.fold(
                    (error) => _showError(error.message),
                    (_) {
                      ref.read(inventoryListProvider.notifier).refresh();
                      _showSuccess('Deduction undone');
                    },
                  );
                },
                child: const Text('Undo'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _clearForm() {
    _quantityController.clear();
    _reasonController.text = 'Daily Messing';
    setState(() => _selectedItem = null);
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.success),
    );
  }
}
