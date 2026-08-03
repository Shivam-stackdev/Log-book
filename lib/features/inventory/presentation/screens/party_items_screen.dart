import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:army_mess_inventory/core/theme/app_theme.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/party_entry_entity.dart';
// PartyItemEntity is in party_entry_entity.dart
import 'package:army_mess_inventory/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:uuid/uuid.dart';

class PartyItemsScreen extends ConsumerStatefulWidget {
  final String officerId;
  final String officerName;
  const PartyItemsScreen({super.key, required this.officerId, required this.officerName});
  @override
  ConsumerState<PartyItemsScreen> createState() => _PartyItemsScreenState();
}

class _PartyItemsScreenState extends ConsumerState<PartyItemsScreen> {
  List<Map<String, dynamic>> _partyData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final repository = ref.read(officerRepositoryProvider);
    final entriesResult = await repository.getPartyEntries(widget.officerId);
    entriesResult.fold(
      (error) => setState(() => _isLoading = false),
      (entries) async {
        List<Map<String, dynamic>> data = [];
        for (var entry in entries) {
          final itemsResult = await repository.getPartyItems(entry.id);
          itemsResult.fold((_) => null, (items) => data.add({'entry': entry, 'items': items}));
        }
        if (mounted) setState(() { _partyData = data; _isLoading = false; });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Party - ${widget.officerName}')),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : _partyData.isEmpty ? _buildEmptyState() : RefreshIndicator(
        onRefresh: _loadData,
        child: ListView.builder(padding: const EdgeInsets.all(16), itemCount: _partyData.length, itemBuilder: (context, index) => _buildPartyCard(index)),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => _showAddPartyEntryDialog(), child: const Icon(Icons.add)),
    );
  }

  Widget _buildEmptyState() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.celebration, size: 64, color: AppColors.textSecondary.withOpacity(0.4)),
      const SizedBox(height: 16),
      Text('No party entries yet', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      Text('Add a party entry to start tracking', style: TextStyle(color: AppColors.textSecondary)),
    ]));
  }

  Widget _buildPartyCard(int index) {
    final data = _partyData[index];
    final PartyEntryEntity entry = data['entry'];
    final List<PartyItemEntity> items = data['items'] ?? [];
    return Card(margin: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(entry.description, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        Text('Rs. ${entry.amount.toStringAsFixed(0)}', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
      ]),
      const SizedBox(height: 4),
      Text(entry.dateFormatted, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      if (items.isNotEmpty) ...[const SizedBox(height: 12), const Divider(), const SizedBox(height: 8), ...items.map((item) => Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(children: [
        Expanded(flex: 3, child: Text(item.itemName)),
        Expanded(flex: 1, child: Text('${item.quantity} ${item.unit}')),
        Expanded(flex: 1, child: Text('Rs. ${item.rate}', textAlign: TextAlign.right)),
        Expanded(flex: 1, child: Text('Rs. ${item.amount}', textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w500))),
      ]))],
    ])));
  }

  void _showAddPartyEntryDialog() {
    final descCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    List<PartyItemInput> itemInputs = [];
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setState) => AlertDialog(
      title: const Text('Add Party Entry'),
      content: SizedBox(width: double.maxFinite, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description'), autofocus: true),
        const SizedBox(height: 8),
        TextField(controller: amountCtrl, decoration: const InputDecoration(labelText: 'Total Amount (Rs.)'), keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        const Text('Items:', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...itemInputs.asMap().entries.map((e) => _buildItemRow(e.key, e.value, itemInputs, setState)),
        const SizedBox(height: 8),
        OutlinedButton.icon(onPressed: () => setState(() => itemInputs.add(PartyItemInput())), icon: const Icon(Icons.add, size: 18), label: const Text('Add Item')),
      ]))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(onPressed: () async {
          Navigator.pop(ctx);
          await _savePartyEntry(descCtrl.text, double.tryParse(amountCtrl.text) ?? 0, itemInputs);
        }, child: const Text('Save')),
      ],
    )));
  }

  Widget _buildItemRow(int index, PartyItemInput input, List<PartyItemInput> itemInputs, StateSetter setState) {
    return Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
      Expanded(flex: 3, child: TextField(controller: input.nameCtrl, decoration: const InputDecoration(labelText: 'Item', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6)))),
      const SizedBox(width: 4),
      Expanded(child: TextField(controller: input.qtyCtrl, decoration: const InputDecoration(labelText: 'Qty', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6)), keyboardType: TextInputType.number)),
      const SizedBox(width: 4),
      Expanded(child: TextField(controller: input.rateCtrl, decoration: const InputDecoration(labelText: 'Rate', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6)), keyboardType: TextInputType.number)),
      const SizedBox(width: 4),
      IconButton(icon: const Icon(Icons.remove_circle, color: AppColors.error, size: 20), onPressed: () => setState(() => itemInputs.removeAt(index))),
    ]));
  }

  Future<void> _savePartyEntry(String description, double totalAmount, List<PartyItemInput> itemInputs) async {
    if (description.isEmpty) return;
    final repository = ref.read(officerRepositoryProvider);
    final entry = PartyEntryEntity(id: const Uuid().v4(), officerId: widget.officerId, date: DateTime.now(), amount: totalAmount, description: description);
    final result = await repository.addPartyEntry(entry);
    result.fold(
      (error) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message))),
      (_) async {
        for (var input in itemInputs) {
          if (input.nameCtrl.text.isEmpty) continue;
          final partyItem = PartyItemEntity(id: const Uuid().v4(), partyEntryId: entry.id, itemName: input.nameCtrl.text, quantity: double.tryParse(input.qtyCtrl.text) ?? 0, rate: double.tryParse(input.rateCtrl.text) ?? 0, amount: (double.tryParse(input.qtyCtrl.text) ?? 0) * (double.tryParse(input.rateCtrl.text) ?? 0), unit: 'pcs');
          await repository.addPartyItem(partyItem);
        }
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Party entry saved')));
      },
    );
  }
}

class PartyItemInput {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController qtyCtrl = TextEditingController();
  final TextEditingController rateCtrl = TextEditingController();
}
