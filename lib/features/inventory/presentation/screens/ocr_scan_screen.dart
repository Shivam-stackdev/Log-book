import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:army_mess_inventory/features/ocr/data/ocr_service.dart';
import 'package:army_mess_inventory/features/ocr/domain/bill_item.dart';
import 'package:army_mess_inventory/features/inventory/presentation/widgets/glass_widgets.dart';

class OcrScanScreen extends StatefulWidget {
  const OcrScanScreen({super.key});

  @override
  State<OcrScanScreen> createState() => _OcrScanScreenState();
}

class _OcrScanScreenState extends State<OcrScanScreen> {
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
              Expanded(
                child: _buildEditableTable(),
              ),
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
            DataCell(Text(item.amount.toString())),
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

  void _saveBill() {
    // Implement mapping and saving logic
    Navigator.pop(context);
  }
}
