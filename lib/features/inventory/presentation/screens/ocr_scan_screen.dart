import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:army_mess_inventory/core/theme/app_theme.dart';
import 'package:army_mess_inventory/core/logging/logger.dart';
import 'package:army_mess_inventory/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/item_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/stock_entry_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/deduction_entry_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/party_entry_entity.dart';
// PartyItemEntity is in party_entry_entity.dart
import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

enum BillCategory { officersParty, dailyDeduction, monthlyStockFill }

class OcrScanScreen extends ConsumerStatefulWidget {
  const OcrScanScreen({super.key});
  @override
  ConsumerState<OcrScanScreen> createState() => _OcrScanScreenState();
}

class _OcrScanScreenState extends ConsumerState<OcrScanScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  String _extractedText = '';
  bool _isProcessing = false;
  BillCategory? _selectedCategory;
  List<OcrItemRow> _detectedItems = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bill Scanner')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('Scan a bill to extract items automatically', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          _buildImageSelector(),
          if (_imageFile != null) ...[const SizedBox(height: 16), ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_imageFile!, height: 200, width: double.infinity, fit: BoxFit.cover))],
          if (_isProcessing) ...[const SizedBox(height: 16), const Center(child: CircularProgressIndicator())],
          if (_detectedItems.isNotEmpty && !_isProcessing) ...[const SizedBox(height: 16), _buildItemsTable(), const SizedBox(height: 16), _buildCategorySelector()],
          if (_detectedItems.isNotEmpty && _selectedCategory != null && !_isProcessing) ...[const SizedBox(height: 16), FilledButton.icon(onPressed: _saveBill, icon: const Icon(Icons.save), label: const Text('Save Bill'))],
          if (_extractedText.isNotEmpty && _detectedItems.isEmpty && !_isProcessing) ...[const SizedBox(height: 16), const Text('No items detected. Try another image.', style: TextStyle(color: AppColors.warning))],
        ]),
      ),
    );
  }

  Widget _buildImageSelector() {
    return Row(children: [
      Expanded(child: OutlinedButton.icon(icon: const Icon(Icons.camera_alt), label: const Text('Camera'), onPressed: () => _pickImage(ImageSource.camera))),
      const SizedBox(width: 12),
      Expanded(child: OutlinedButton.icon(icon: const Icon(Icons.photo_library), label: const Text('Gallery'), onPressed: () => _pickImage(ImageSource.gallery))),
    ]);
  }

  Widget _buildItemsTable() {
    return Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.all(12), child: Text('Detected Items (${_detectedItems.length})', style: const TextStyle(fontWeight: FontWeight.w600))),
      const Divider(height: 1),
      ..._detectedItems.asMap().entries.map((e) => Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), child: Row(children: [
        Expanded(child: Text(e.value.name, style: const TextStyle(fontWeight: FontWeight.w500))),
        SizedBox(width: 60, child: TextField(controller: TextEditingController(text: e.value.quantity.toString()), textAlign: TextAlign.right, keyboardType: TextInputType.number, style: const TextStyle(fontSize: 13), decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 6)), onChanged: (v) => e.value.quantity = double.tryParse(v) ?? 0)),
        const SizedBox(width: 4),
        SizedBox(width: 80, child: TextField(controller: TextEditingController(text: e.value.rate.toString()), textAlign: TextAlign.right, keyboardType: TextInputType.number, style: const TextStyle(fontSize: 13), decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 6)), onChanged: (v) => e.value.rate = double.tryParse(v) ?? 0)),
        const SizedBox(width: 8),
        Text('Rs. ${(e.value.quantity * e.value.rate).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w600)),
      ]))),
      Padding(padding: const EdgeInsets.all(12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
        Text('Rs. ${_detectedItems.fold(0.0, (s, i) => s + (i.quantity * i.rate)).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
      ])),
    ]));
  }

  Widget _buildCategorySelector() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Bill Category:', style: TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      ...BillCategory.values.map((cat) => RadioListTile<BillCategory>(value: cat, groupValue: _selectedCategory, title: Text(_categoryLabel(cat)), subtitle: Text(_categorySubtitle(cat), style: TextStyle(color: AppColors.textSecondary, fontSize: 12)), onChanged: (v) => setState(() => _selectedCategory = v))),
    ]);
  }

  String _categoryLabel(BillCategory cat) => switch (cat) { BillCategory.officersParty => 'Officers Party', BillCategory.dailyDeduction => 'Daily Deduction', BillCategory.monthlyStockFill => 'Per Month Stock Fill' };
  String _categorySubtitle(BillCategory cat) => switch (cat) { BillCategory.officersParty => 'अफ़सरों की पार्टी', BillCategory.dailyDeduction => 'रोज़ाना कटौती', BillCategory.monthlyStockFill => 'मासिक स्टॉक भरना' };

  Future<void> _pickImage(ImageSource source) async {
    final image = await _picker.pickImage(source: source);
    if (image == null) return;
    setState(() { _imageFile = File(image.path); _extractedText = ''; _detectedItems = []; _selectedCategory = null; });
    await _performOcr();
  }

  Future<void> _performOcr() async {
    if (_imageFile == null) return;
    setState(() => _isProcessing = true);
    try {
      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final inputImage = InputImage.fromFile(_imageFile!);
      final recognizedText = await recognizer.processImage(inputImage);
      _extractedText = recognizedText.text;
      AppLogger.i('OCR', 'Extracted ${_extractedText.length} chars');
      _detectedItems = _parseItemsFromText(_extractedText);
      AppLogger.i('OCR', 'Detected ${_detectedItems.length} items');
      setState(() => _isProcessing = false);
    } catch (e) {
      AppLogger.e('OCR', 'OCR failed', e);
      setState(() => _isProcessing = false);
    }
  }

  List<OcrItemRow> _parseItemsFromText(String text) {
    List<OcrItemRow> items = [];
    final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
    for (var line in lines) {
      final regex = RegExp(r'([A-Za-z]+[A-Za-z\s\.]*?)\s*(\d+\.?\d*)\s*(x|@|×|X|x)\s*(\d+\.?\d*)');
      final match = regex.firstMatch(line);
      if (match != null) {
        items.add(OcrItemRow(name: match.group(1)!.trim(), quantity: double.tryParse(match.group(2)!) ?? 0, rate: double.tryParse(match.group(4)!) ?? 0));
      }
    }
    if (items.isEmpty) {
      final priceRegex = RegExp(r'([A-Za-z\s\.]+?)\s+(\d+\.?\d*)');
      for (var line in lines) {
        final match = priceRegex.firstMatch(line);
        if (match != null && match.group(1)!.trim().length > 2) {
          final price = double.tryParse(match.group(2)!) ?? 0;
          if (price > 0) items.add(OcrItemRow(name: match.group(1)!.trim(), quantity: 1, rate: price));
        }
      }
    }
    return items;
  }

  Future<void> _saveBill() async {
    if (_selectedCategory == null || _detectedItems.isEmpty) return;
    setState(() => _isProcessing = true);
    try {
      switch (_selectedCategory!) {
        case BillCategory.monthlyStockFill: await _saveAsStockEntries(); break;
        case BillCategory.dailyDeduction: await _saveAsDeductions(); break;
        case BillCategory.officersParty: await _saveAsPartyEntry(); break;
      }
      setState(() => _isProcessing = false);
      _showSuccess('Bill saved successfully');
      setState(() { _detectedItems = []; _selectedCategory = null; _extractedText = ''; });
    } catch (e) {
      AppLogger.e('OCR', 'Save failed', e);
      setState(() => _isProcessing = false);
      _showError('Failed to save: $e');
    }
  }

  Future<void> _saveAsStockEntries() async {
    final repository = ref.read(inventoryRepositoryProvider);
    for (var item in _detectedItems) {
      final allItems = await repository.getItems();
      allItems.fold((_) => null, (items) {
        final existing = items.where((i) => i.name.toLowerCase() == item.name.toLowerCase()).firstOrNull;
        if (existing == null) {
          final newItem = ItemEntity(id: const Uuid().v4(), name: item.name, unit: 'Kg', currentStock: 0, reorderLevel: 10, category: 'Grocery', rate: item.rate);
          repository.addItem(newItem).then((r) {
            r.fold((_) => null, (_) {
              final entry = StockEntryEntity(id: const Uuid().v4(), itemId: newItem.id, date: DateTime.now(), quantity: item.quantity, unitPrice: item.rate, supplier: 'Bill Import');
              repository.addStockEntry(entry);
            });
          });
        } else {
          final entry = StockEntryEntity(id: const Uuid().v4(), itemId: existing.id, date: DateTime.now(), quantity: item.quantity, unitPrice: item.rate, supplier: 'Bill Import');
          repository.addStockEntry(entry);
        }
      });
    }
    ref.read(inventoryListProvider.notifier).refresh();
  }

  Future<void> _saveAsDeductions() async {
    final repository = ref.read(inventoryRepositoryProvider);
    final allItems = await repository.getItems();
    allItems.fold((_) => null, (items) {
      for (var item in _detectedItems) {
        final existing = items.where((i) => i.name.toLowerCase() == item.name.toLowerCase()).firstOrNull;
        if (existing != null) {
          final entry = DeductionEntryEntity(id: const Uuid().v4(), itemId: existing.id, date: DateTime.now(), quantity: item.quantity, reason: 'Bill Import - Daily Deduction');
          repository.addDeductionEntry(entry);
        }
      }
    });
    ref.read(inventoryListProvider.notifier).refresh();
  }

  Future<void> _saveAsPartyEntry() async {
    final repository = ref.read(officerRepositoryProvider);
    final totalAmount = _detectedItems.fold(0.0, (s, i) => s + (i.quantity * i.rate));
    final entry = PartyEntryEntity(id: const Uuid().v4(), officerId: 'general', date: DateTime.now(), amount: totalAmount, description: 'Bill Import - ${DateFormat('dd MMM yyyy').format(DateTime.now())}');
    await repository.addPartyEntry(entry);
    for (var item in _detectedItems) {
      final partyItem = PartyItemEntity(id: const Uuid().v4(), partyEntryId: entry.id, itemName: item.name, quantity: item.quantity, rate: item.rate, amount: item.quantity * item.rate, unit: 'pcs');
      await repository.addPartyItem(partyItem);
    }
    AppLogger.i('OCR', 'Party entry saved with ${_detectedItems.length} items');
  }

  void _showSuccess(String message) { if (!mounted) return; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: AppColors.success)); }
  void _showError(String message) { if (!mounted) return; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: AppColors.error)); }
}

class OcrItemRow { String name; double quantity; double rate; OcrItemRow({required this.name, required this.quantity, required this.rate}); }
