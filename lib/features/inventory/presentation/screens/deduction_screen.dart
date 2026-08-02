import 'package:army_mess_inventory/features/inventory/domain/entities/deduction_entry_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:army_mess_inventory/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:army_mess_inventory/features/inventory/presentation/widgets/glass_widgets.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/item_entity.dart';
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

  @override
  Widget build(BuildContext context) {
    final inventoryAsync = ref.watch(inventoryListProvider);

    return Scaffold(
      appBar: const GlassAppBar(title: 'Daily Deduction'),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Record Consumption',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            inventoryAsync.when(
              data: (items) => DropdownButtonFormField<ItemEntity>(
                decoration: InputDecoration(
                  labelText: 'Select Item',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                value: _selectedItem,
                items: items.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text('${item.name} (${item.currentStock} ${item.unit} avail)'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedItem = value;
                  });
                },
              ),
              loading: () => const LinearProgressIndicator(),
              error: (err, stack) => Text('Error loading items'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixText: _selectedItem?.unit ?? '',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                labelText: 'Reason/Event',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _saveDeduction,
              child: const Text('Confirm Deduction', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
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

    final quantity = double.tryParse(_quantityController.text) ?? 0;
    if (quantity > _selectedItem!.currentStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient stock')),
      );
      return;
    }

    final entry = DeductionEntryEntity(
      id: const Uuid().v4(),
      itemId: _selectedItem!.id,
      date: DateTime.now(),
      quantity: quantity,
      reason: _reasonController.text,
    );

    final repository = ref.read(inventoryRepositoryProvider);
    await repository.addDeductionEntry(entry);
    
    // Refresh inventory
    ref.read(inventoryListProvider.notifier).loadItems();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deduction recorded successfully')),
      );
      Navigator.pop(context);
    }
  }
}
