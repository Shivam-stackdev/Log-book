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
  
  // Controllers for the editable table
  final List<TextEditingController> _nameControllers = [];
  final List<TextEditingController> _qtyControllers = [];
  final List<TextEditingController> _rateControllers = [];
  final List<TextEditingController> _unitControllers = [];

  @override
  void dispose() {
    _ocrService.dispose();
    for (var c in _nameControllers) c.dispose();
    for (var c in _qtyControllers) c.dispose();
    for (var c in _rateControllers) c.dispose();
    for (var c in _unitControllers) c.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1200,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isProcessing = true;
      });

      try {
        final items = await _ocrService.processImage(pickedFile.path);
        
        // Clear old controllers
        for (var c in _nameControllers) c.dispose();
        for (var c in _qtyControllers) c.dispose();
        for (var c in _rateControllers) c.dispose();
        for (var c in _unitControllers) c.dispose();
        _nameControllers.clear();
        _qtyControllers.clear();
        _rateControllers.clear();
        _unitControllers.clear();

        // Create new controllers
        for (var item in items) {
          _nameControllers.add(TextEditingController(text: item.name));
          _qtyControllers.add(TextEditingController(text: item.quantity.toString()));
          _rateControllers.add(TextEditingController(text: item.rate.toString()));
          _unitControllers.add(TextEditingController(text: item.unit));
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
                    const Text(
                      'Scan a bill to extract items automatically',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Camera'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Gallery'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          else ...[
            Container(
              height: 160,
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(image: FileImage(_image!), fit: BoxFit.cover),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      radius: 18,
                      child: IconButton(
                        icon: const Icon(Icons.close, size: 18, color: Colors.white),
                        onPressed: () => setState(() {
                          _image = null;
                          _extractedItems = [];
                        }),
                      ),
                    ),
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
              backgroundColor: Colors.green.shade700,
            )
          : null,
    );
  }

  Widget _buildEditableTable() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.receipt, color: Colors.green.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${_extractedItems.length} items detected',
                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green.shade800),
                ),
                const Spacer(),
                Text(
                  'Total: ₹${_calculateTotal().toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade800),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                const Expanded(flex: 3, child: Text('Item', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                const Expanded(flex: 1, child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                const Expanded(flex: 1, child: Text('Rate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                const Expanded(flex: 1, child: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                const SizedBox(width: 36),
              ],
            ),
          ),
          // Table rows
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: _extractedItems.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: index % 2 == 0 ? Colors.white : Colors.grey.shade50,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: Row(
                      children: [
                        // Item name
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _nameControllers[index],
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 4),
                            ),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        // Quantity
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: _qtyControllers[index],
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 4),
                            ),
                            style: const TextStyle(fontSize: 13),
                            onChanged: (_) => _onFieldChanged(),
                          ),
                        ),
                        // Rate
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: _rateControllers[index],
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 4),
                            ),
                            style: const TextStyle(fontSize: 13),
                            onChanged: (_) => _onFieldChanged(),
                          ),
                        ),
                        // Amount (read-only)
                        Expanded(
                          flex: 1,
                          child: Text(
                            '₹${_calculateItemAmount(index).toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                        // Delete button
                        SizedBox(
                          width: 36,
                          child: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                            onPressed: () => _removeItem(index),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  double _calculateItemAmount(int index) {
    final qty = double.tryParse(_qtyControllers[index].text) ?? 0;
    final rate = double.tryParse(_rateControllers[index].text) ?? 0;
    return qty * rate;
  }

  double _calculateTotal() {
    double total = 0;
    for (int i = 0; i < _extractedItems.length; i++) {
      total += _calculateItemAmount(i);
    }
    return total;
  }

  void _onFieldChanged() {
    // Only rebuild the summary, not the entire table
    setState(() {
      // Minimal rebuild - just updates the summary bar text
    });
  }

  void _removeItem(int index) {
    setState(() {
      _extractedItems.removeAt(index);
      _nameControllers.removeAt(index).dispose();
      _qtyControllers.removeAt(index).dispose();
      _rateControllers.removeAt(index).dispose();
      _unitControllers.removeAt(index).dispose();
    });
  }

  void _showCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bill Category'),
        content: const Text('Yeh bill kis chiz ke liye hai? / What is this bill for?'),
        actions: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.people, color: Colors.purple),
                title: const Text('Officers Party'),
                subtitle: const Text('अफ़सरों की पार्टी के लिए'),
                onTap: () {
                  Navigator.pop(context);
                  _handleSave('party');
                },
              ),
              ListTile(
                leading: const Icon(Icons.remove_circle, color: Colors.red),
                title: const Text('Daily Deduction'),
                subtitle: const Text('रोज़ाना कटौती के लिए'),
                onTap: () {
                  Navigator.pop(context);
                  _handleSave('deduction');
                },
              ),
              ListTile(
                leading: const Icon(Icons.inventory_2, color: Colors.blue),
                title: const Text('Per Month Stock Fill'),
                subtitle: const Text('मासिक स्टॉक भरने के लिए'),
                onTap: () {
                  Navigator.pop(context);
                  _handleSave('stock');
                },
              ),
            ],
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
      final unit = _unitControllers[i].text.trim().isNotEmpty 
          ? _unitControllers[i].text.trim() 
          : 'unit';
      
      if (name.isNotEmpty && qty > 0) {
        finalItems.add(BillItem(
          name: name,
          quantity: qty,
          unit: unit,
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
      await _saveToParty(finalItems);
    } else if (category == 'deduction') {
      await _saveToDeduction(finalItems);
    } else {
      await _saveToStock(finalItems);
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stock updated successfully')),
        );
        setState(() {
          _image = null;
          _extractedItems = [];
        });
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deduction recorded successfully')),
        );
        setState(() {
          _image = null;
          _extractedItems = [];
        });
      }
    }
  }

  Future<void> _saveToParty(List<BillItem> items) async {
    final officersAsync = ref.read(officerListProvider);
    OfficerEntity? selectedOfficer;
    final List<OfficerEntity> allOfficers = [];
    
    officersAsync.when(
      data: (officers) {
        allOfficers.clear();
        allOfficers.addAll(officers);
      },
      loading: () {},
      error: (_, __) {},
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Select Officer'),
          content: allOfficers.isEmpty
              ? const Text('No officers registered. Please add officers first.')
              : SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemCount: allOfficers.length,
                    itemBuilder: (context, index) {
                      final officer = allOfficers[index];
                      return RadioListTile<OfficerEntity>(
                        value: officer,
                        groupValue: selectedOfficer,
                        title: Text('${officer.rank} ${officer.name}'),
                        subtitle: Text('PN: ${officer.personalNumber}'),
                        onChanged: (val) => setDialogState(() => selectedOfficer = val),
                      );
                    },
                  ),
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
      final partyRepo = ref.read(officerRepositoryProvider);
      final inventoryRepo = ref.read(inventoryRepositoryProvider);
      double totalAmount = items.fold(0, (sum, item) => sum + item.amount);
      final partyEntryId = const Uuid().v4();
      
      // Create party entry
      await partyRepo.addPartyEntry(PartyEntryEntity(
        id: partyEntryId,
        officerId: selectedOfficer!.id,
        date: DateTime.now(),
        amount: totalAmount,
        description: 'Bill Scan: ${items.length} items',
      ));
      
      // Also save individual party items to the new table
      final db = (ref.read(databaseHelperProvider));
      final database = await db.database;
      
      for (var item in items) {
        await database.insert('party_items', {
          'id': const Uuid().v4(),
          'partyEntryId': partyEntryId,
          'itemName': item.name,
          'quantity': item.quantity,
          'rate': item.rate,
          'amount': item.amount,
          'unit': item.unit,
        });
      }
      
      // Also create deduction entries for stock management
      for (var item in items) {
        final existingItems = await inventoryRepo.getItems();
        String itemId = '';
        
        existingItems.fold((_) => null, (list) {
          final found = list.where((e) => e.name.toLowerCase() == item.name.toLowerCase());
          if (found.isNotEmpty) {
            itemId = found.first.id;
          }
        });

        if (itemId.isNotEmpty) {
          await inventoryRepo.addDeductionEntry(DeductionEntryEntity(
            id: const Uuid().v4(),
            itemId: itemId,
            date: DateTime.now(),
            quantity: item.quantity,
            reason: 'Party - ${selectedOfficer.name}',
          ));
        }
      }
      
      ref.read(inventoryListProvider.notifier).loadItems();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Party expense recorded successfully with all items')),
        );
        setState(() {
          _image = null;
          _extractedItems = [];
        });
      }
    }
  }
}
