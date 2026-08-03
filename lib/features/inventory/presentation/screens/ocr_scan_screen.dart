import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:army_mess_inventory/main.dart';
import 'package:army_mess_inventory/features/ocr/data/ocr_service.dart';
import 'package:army_mess_inventory/features/ocr/domain/bill_item.dart';
import 'package:army_mess_inventory/features/inventory/presentation/widgets/glass_widgets.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/transaction_entity.dart';
import 'package:uuid/uuid.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                    Icon(Icons.receipt_long, size: 80, color: isDark ? Colors.white38 : Colors.grey),
                    const SizedBox(height: 20),
                    Text(
                      'No bill selected',
                      style: TextStyle(fontSize: 18, color: isDark ? Colors.white54 : Colors.grey),
                    ),
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
                        OutlinedButton.icon(
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
              height: 200,
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(image: FileImage(_image!), fit: BoxFit.cover),
              ),
            ),
            if (_isProcessing)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(child: _buildEditableTable()),
          ],
        ],
      ),
      floatingActionButton: _extractedItems.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _saveBill,
              label: const Text('Save to Inventory'),
              icon: const Icon(Icons.save),
            )
          : null,
    );
  }

  Widget _buildEditableTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Item')),
          DataColumn(label: Text('Qty')),
          DataColumn(label: Text('Rate')),
          DataColumn(label: Text('Amount')),
        ],
        rows: _extractedItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return DataRow(cells: [
            DataCell(TextFormField(
              initialValue: item.name,
              onChanged: (val) => _updateItem(index, name: val),
            )),
            DataCell(TextFormField(
              initialValue: item.quantity.toString(),
              keyboardType: TextInputType.number,
              onChanged: (val) => _updateItem(index, quantity: double.tryParse(val) ?? 0),
            )),
            DataCell(TextFormField(
              initialValue: item.rate.toString(),
              keyboardType: TextInputType.number,
              onChanged: (val) => _updateItem(index, rate: double.tryParse(val) ?? 0),
            )),
            DataCell(Text(item.amount.toStringAsFixed(2))),
          ]);
        }).toList(),
      ),
    );
  }

  void _updateItem(int index, {String? name, double? quantity, double? rate}) {
    setState(() {
      final item = _extractedItems[index];
      final newQty = quantity ?? item.quantity;
      final newRate = rate ?? item.rate;
      _extractedItems[index] = item.copyWith(
        name: name,
        quantity: newQty,
        rate: newRate,
        amount: newQty * newRate,
      );
    });
  }

  void _saveBill() async {
    // Add each extracted item as a stock addition
    final txProvider = ref.read(transactionChangeProvider);
    final inventoryProvider = ref.read(inventoryChangeProvider);

    for (final billItem in _extractedItems) {
      // Try to match to existing inventory item
      final matchedItem = inventoryProvider.items.firstWhere(
        (i) => i.name.toLowerCase() == billItem.name.toLowerCase(),
        orElse: () => inventoryProvider.items.first, // fallback
      );

      final txn = TransactionEntity(
        id: const Uuid().v4(),
        itemId: matchedItem.id,
        itemName: billItem.name,
        quantity: billItem.quantity,
        type: 'addition',
        reason: 'OCR Bill Import',
        date: DateTime.now(),
        cost: billItem.amount,
        unitPrice: billItem.rate,
      );
      await txProvider.addTransaction(txn);
    }

    await inventoryProvider.loadItems();
    await ref.read(dashboardChangeProvider).refresh();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bill items added to inventory!')),
      );
      Navigator.pop(context);
    }
  }
}
