import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:army_mess_inventory/features/ocr/data/ocr_service.dart';
import 'package:army_mess_inventory/features/ocr/domain/bill_item.dart';
import 'package:army_mess_inventory/features/inventory/presentation/widgets/glass_widgets.dart';
import 'package:army_mess_inventory/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/stock_entry_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/deduction_entry_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/party_entry_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/item_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/officer_entity.dart';

class OcrScanScreen extends ConsumerStatefulWidget {
  const OcrScanScreen({super.key});

  @override
  ConsumerState<OcrScanScreen> createState() => _OcrScanScreenState();
}

class _OcrScanScreenState extends ConsumerState<OcrScanScreen> {
  File? _image;
  bool _isProcessing = false;
  List<BillItem> _extractedItems = [];
  final OcrService _ocrService = OcrService();
  
  // Controllers for the table to avoid laggy setState on every keystroke
  final List<TextEditingController> _nameControllers = [];
  final List<TextEditingController> _qtyControllers = [];
  final List<TextEditingController> _rateControllers = [];

  @override
  void dispose() {
    _ocrService.dispose();
    for (var c in _nameControllers) {
      c.dispose();
    }
    for (var c in _qtyControllers) {
      c.dispose();
    }
    for (var c in _rateControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isProcessing = true;
      });

      try {
        final items = await _ocrService.processImage(pickedFile.path);
        
        // Clear old controllers
        for (var c in _nameControllers) {
          c.dispose();
        }
        for (var c in _qtyControllers) {
          c.dispose();
        }
        for (var c in _rateControllers) {
          c.dispose();
        }
        _nameControllers.clear();
        _qtyControllers.clear();
        _rateControllers.clear();

        // Create new controllers
        for (var item in items) {
          _nameControllers.add(TextEditingController(text: item.name));
          _qtyControllers.add(TextEditingController(text: item.quantity.toString()));
          _rateControllers.add(TextEditingController(text: item.rate.toString()));
        }

        setState(() {
          _extractedItems = items;
          _isProcessing = false;
        });
      } catch (e) {
        setState(() => _isProcessing = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('OCR Failed: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GlassAppBar(title: 'Bill Scanner'),
      body: Column(
        children: [
          if (_image == null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.receipt_long, size: 80, color: Colors.grey),
                    const SizedBox(height: 20),
                    const Text('No bill selected', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Camera'),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Gallery'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          else ...[
            Container(
              height: 180,
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(image: FileImage(_image!), fit: BoxFit.cover),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            if (_isProcessing)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: _buildEditableTable(),
              ),
          ],
        ],
      ),
      floatingActionButton: _extractedItems.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _showCategoryDialog,
              label: const Text('Save Bill'),
              icon: const Icon(Icons.save),
            )
          : null,
    );
  }

  Widget _buildEditableTable() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 80),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 24,
          columns: const [
            DataColumn(label: Text('Item Name', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Rate', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: List<DataRow>.generate(_extractedItems.length, (index) {
            return DataRow(cells: [
              DataCell(
                SizedBox(
                  width: 150,
                  child: TextField(
                    controller: _nameControllers[index],
                    decoration: const InputDecoration(isDense: true, border: InputBorder.none),
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: _qtyControllers[index],
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(isDense: true, border: InputBorder.none),
                    onChanged: (val) => _updateAmount(index),
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _rateControllers[index],
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(isDense: true, border: InputBorder.none),
                    onChanged: (val) => _updateAmount(index),
                  ),
                ),
              ),
              DataCell(
                Text('₹${_calculateItemAmount(index).toStringAsFixed(2)}'),
              ),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => _removeItem(index),
                ),
              ),
            ]);
          }),
        ),
      ),
    );
  }

  double _calculateItemAmount(int index) {
    final qty = double.tryParse(_qtyControllers[index].text) ?? 0;
    final rate = double.tryParse(_rateControllers[index].text) ?? 0;
    return qty * rate;
  }

  void _updateAmount(int index) {
    setState(() {
      // Just to trigger UI refresh for the Amount column
    });
  }

  void _removeItem(int index) {
    setState(() {
      _extractedItems.removeAt(index);
      _nameControllers.removeAt(index).dispose();
      _qtyControllers.removeAt(index).dispose();
      _rateControllers.removeAt(index).dispose();
    });
  }

  void _showCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Bill Category'),
        content: const Text('What is this bill for?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleSave('party');
            },
            child: const Text('Officers Party'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleSave('deduction');
            },
            child: const Text('Daily Deduction'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleSave('stock');
            },
            child: const Text('Per Month Stock Fill'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave(String category) async {
    // Collect updated items from controllers
    final List<BillItem> finalItems = [];
    for (int i = 0; i < _extractedItems.length; i++) {
      final name = _nameControllers[i].text.trim();
      final qty = double.tryParse(_qtyControllers[i].text) ?? 0;
      final rate = double.tryParse(_rateControllers[i].text) ?? 0;
      
      if (name.isNotEmpty && qty > 0) {
        finalItems.add(BillItem(
          name: name,
          quantity: qty,
          unit: "unit",
          rate: rate,
          amount: qty * rate,
        ));
      }
    }

    if (finalItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No valid items to save')),
      );
      return;
    }

    if (category == 'party') {
      _saveToParty(finalItems);
    } else if (category == 'deduction') {
      _saveToDeduction(finalItems);
    } else {
      _saveToStock(finalItems);
    }
  }

  Future<void> _saveToStock(List<BillItem> items) async {
    final supplierController = TextEditingController();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stock Fill Details'),
        content: TextField(
          controller: supplierController,
          decoration: const InputDecoration(labelText: 'Supplier Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );

    if (confirmed == true) {
      final repository = ref.read(inventoryRepositoryProvider);
      final supplier = supplierController.text.trim().isEmpty ? 'Unknown' : supplierController.text.trim();
      
      for (var item in items) {
        // Find or create item first
        final existingItems = await repository.getItems();
        String itemId = '';
        
        existingItems.fold((_) => null, (list) {
          final found = list.where((e) => e.name.toLowerCase() == item.name.toLowerCase());
          if (found.isNotEmpty) {
            itemId = found.first.id;
          }
        });

        if (itemId.isEmpty) {
          itemId = const Uuid().v4();
          await repository.addItem(ItemEntity(
            id: itemId,
            name: item.name,
            unit: item.unit,
            currentStock: 0,
            reorderLevel: 5,
            category: 'General',
          ));
        }

        await repository.addStockEntry(StockEntryEntity(
          id: const Uuid().v4(),
          itemId: itemId,
          date: DateTime.now(),
          quantity: item.quantity,
          unitPrice: item.rate,
          supplier: supplier,
        ));
      }
      
      ref.read(inventoryListProvider.notifier).loadItems();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Stock updated successfully')));
        Navigator.pop(context);
      }
    }
  }

  Future<void> _saveToDeduction(List<BillItem> items) async {
    final reasonController = TextEditingController(text: 'Daily Mess Deduction');
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deduction Details'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(labelText: 'Reason'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );

    if (confirmed == true) {
      final repository = ref.read(inventoryRepositoryProvider);
      final reason = reasonController.text.trim();
      
      for (var item in items) {
        final existingItems = await repository.getItems();
        String itemId = '';
        
        existingItems.fold((_) => null, (list) {
          final found = list.where((e) => e.name.toLowerCase() == item.name.toLowerCase());
          if (found.isNotEmpty) {
            itemId = found.first.id;
          }
        });

        if (itemId.isNotEmpty) {
          await repository.addDeductionEntry(DeductionEntryEntity(
            id: const Uuid().v4(),
            itemId: itemId,
            date: DateTime.now(),
            quantity: item.quantity,
            reason: reason,
          ));
        }
      }
      
      ref.read(inventoryListProvider.notifier).loadItems();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deduction recorded successfully')));
        Navigator.pop(context);
      }
    }
  }

  Future<void> _saveToParty(List<BillItem> items) async {
    final officersAsync = ref.read(officerListProvider);
    OfficerEntity? selectedOfficer;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Select Officer'),
          content: officersAsync.when(
            data: (officers) => DropdownButton<OfficerEntity>(
              isExpanded: true,
              value: selectedOfficer,
              hint: const Text('Choose Officer'),
              items: officers.map((o) => DropdownMenuItem(value: o, child: Text(o.name))).toList(),
              onChanged: (val) => setDialogState(() => selectedOfficer = val),
            ),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const Text('Error loading officers'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            TextButton(
              onPressed: selectedOfficer != null ? () => Navigator.pop(context, true) : null,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && selectedOfficer != null) {
      final repository = ref.read(officerRepositoryProvider);
      double totalAmount = items.fold(0, (sum, item) => sum + item.amount);
      
      await repository.addPartyEntry(PartyEntryEntity(
        id: const Uuid().v4(),
        officerId: selectedOfficer!.id,
        date: DateTime.now(),
        amount: totalAmount,
        description: 'Bill Scan: ${items.length} items',
      ));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Party expense recorded successfully')));
        Navigator.pop(context);
      }
    }
  }
}
