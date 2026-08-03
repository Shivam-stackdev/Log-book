import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:army_mess_inventory/main.dart';
import 'package:army_mess_inventory/features/inventory/presentation/widgets/glass_widgets.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/item_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/officer_party_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/party_item_entity.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class _PartyItem {
  ItemEntity item;
  double quantity;
  double get amount => quantity * item.unitCost;
  _PartyItem({required this.item, required this.quantity});
}

class OfficerPartyScreen extends ConsumerStatefulWidget {
  const OfficerPartyScreen({super.key});

  @override
  ConsumerState<OfficerPartyScreen> createState() => _OfficerPartyScreenState();
}

class _OfficerPartyScreenState extends ConsumerState<OfficerPartyScreen> {
  final _officerCountCtrl = TextEditingController();
  final _perOfficerCostCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _partyDate = DateTime.now();
  final List<_PartyItem> _partyItems = [];

  double get _totalItemsCost => _partyItems.fold(0, (sum, pi) => sum + pi.amount);
  int get _officerCount => int.tryParse(_officerCountCtrl.text) ?? 0;
  double get _totalPartyCost {
    final perOfficer = double.tryParse(_perOfficerCostCtrl.text);
    if (perOfficer != null && perOfficer > 0) {
      return _officerCount * perOfficer;
    }
    return _totalItemsCost;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inventoryProvider = ref.watch(inventoryChangeProvider);
    final partyProvider = ref.watch(partyChangeProvider);

    return Scaffold(
      appBar: const GlassAppBar(title: 'Officer Party'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Party Info Card
            _buildPartyInfoCard(isDark),
            const SizedBox(height: 20),

            // Items Consumed Section
            Text(
              'Items Consumed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            ..._partyItems.asMap().entries.map((entry) => _buildPartyItemTile(entry.key, entry.value, isDark)),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
              onPressed: () => _showAddItemDialog(inventoryProvider.items),
            ),

            const SizedBox(height: 20),

            // Total Summary
            _buildTotalSummary(isDark),

            const SizedBox(height: 20),

            // Save button
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Deduct from Stock & Save Party', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _saveParty,
            ),

            const SizedBox(height: 30),

            // Past Parties List
            Text(
              'Past Parties',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            ...partyProvider.parties.map((party) => _buildPastPartyCard(party, isDark)),
            if (partyProvider.parties.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No parties recorded yet',
                    style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartyInfoCard(bool isDark) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _officerCountCtrl,
            decoration: const InputDecoration(
              labelText: 'No. of Officers',
              prefixIcon: Icon(Icons.people),
            ),
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _perOfficerCostCtrl,
            decoration: const InputDecoration(
              labelText: 'Per Officer Cost (Rs) - Optional Override',
              prefixIcon: Icon(Icons.currency_rupee),
              hintText: 'Auto-calculated from items if empty',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _partyDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (picked != null) setState(() => _partyDate = picked);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today),
                  const SizedBox(width: 12),
                  Text(
                    DateFormat('dd MMM yyyy').format(_partyDate),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesCtrl,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              prefixIcon: Icon(Icons.note),
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildPartyItemTile(int index, _PartyItem pi, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        dense: true,
        title: Text(pi.item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${pi.quantity.toStringAsFixed(1)} ${pi.item.unit} @ Rs ${pi.item.unitCost.toStringAsFixed(2)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Rs ${pi.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red, size: 20),
              onPressed: () => setState(() => _partyItems.removeAt(index)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSummary(bool isDark) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Items Cost:', style: TextStyle(fontSize: 16)),
              Text('Rs ${_totalItemsCost.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Party Cost:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                'Rs ${_totalPartyCost.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green.shade700),
              ),
            ],
          ),
          if (_officerCount > 0 && _totalPartyCost > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Rs ${(_totalPartyCost / _officerCount).toStringAsFixed(2)} per officer',
                style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPastPartyCard(OfficerPartyEntity party, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.withValues(alpha: 0.15),
          child: const Icon(Icons.celebration, color: Colors.green),
        ),
        title: Text('${party.officerCount} Officers | ${DateFormat('dd MMM yyyy').format(party.date)}'),
        subtitle: Text('Total: Rs ${party.totalCost.toStringAsFixed(2)} | Per Head: Rs ${party.perOfficerCost.toStringAsFixed(2)}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showPartyDetails(party),
      ),
    );
  }

  void _showAddItemDialog(List<ItemEntity> allItems) {
    final usedIds = _partyItems.map((pi) => pi.item.id).toSet();
    final available = allItems.where((i) => !usedIds.contains(i.id) && i.currentStock > 0).toList();

    ItemEntity? selected;
    final qtyCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Item to Party'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<ItemEntity>(
                decoration: const InputDecoration(labelText: 'Select Item'),
                items: available.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text('${item.name} (${item.currentStock.toStringAsFixed(1)} ${item.unit} avail)'),
                  );
                }).toList(),
                onChanged: (v) => setDialogState(() => selected = v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: qtyCtrl,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  suffixText: selected?.unit ?? '',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (selected == null || qtyCtrl.text.isEmpty) return;
                final qty = double.tryParse(qtyCtrl.text) ?? 0;
                if (qty <= 0) return;
                if (qty > selected!.currentStock) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Insufficient stock! Only ${selected!.currentStock.toStringAsFixed(1)} ${selected!.unit} available')),
                  );
                  return;
                }
                setState(() {
                  _partyItems.add(_PartyItem(item: selected!, quantity: qty));
                });
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveParty() async {
    if (_officerCount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the number of officers')),
      );
      return;
    }
    if (_partyItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    // Check stock sufficiency
    for (final pi in _partyItems) {
      final latestItem = ref.read(inventoryChangeProvider).getItemById(pi.item.id);
      if (latestItem != null && pi.quantity > latestItem.currentStock) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Insufficient stock for ${pi.item.name}. Available: ${latestItem.currentStock.toStringAsFixed(1)} ${latestItem.unit}')),
        );
        return;
      }
    }

    final partyId = const Uuid().v4();
    final perOfficer = _totalPartyCost / _officerCount;

    final party = OfficerPartyEntity(
      id: partyId,
      date: _partyDate,
      officerCount: _officerCount,
      perOfficerCost: perOfficer,
      totalCost: _totalPartyCost,
      notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
    );

    final partyItemEntities = _partyItems.map((pi) => PartyItemEntity(
      id: const Uuid().v4(),
      partyId: partyId,
      itemId: pi.item.id,
      itemName: pi.item.name,
      quantity: pi.quantity,
      rate: pi.item.unitCost,
      amount: pi.amount,
    )).toList();

    final success = await ref.read(partyChangeProvider).addParty(party, partyItemEntities);
    if (success) {
      await ref.read(inventoryChangeProvider).loadItems();
      await ref.read(dashboardChangeProvider).refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Party saved and stock deducted!')),
        );
        setState(() {
          _partyItems.clear();
          _officerCountCtrl.clear();
          _perOfficerCostCtrl.clear();
          _notesCtrl.clear();
          _partyDate = DateTime.now();
        });
      }
    }
  }

  void _showPartyDetails(OfficerPartyEntity party) async {
    final items = await ref.read(partyChangeProvider).getPartyItems(party.id);
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Party - ${DateFormat('dd MMM yyyy').format(party.date)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Officers: ${party.officerCount} | Per Head: Rs ${party.perOfficerCost.toStringAsFixed(2)}'),
            Text('Total: Rs ${party.totalCost.toStringAsFixed(2)}'),
            if (party.notes != null) Text('Notes: ${party.notes}'),
            const SizedBox(height: 16),
            const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...items.map((item) => ListTile(
              dense: true,
              title: Text(item.itemName),
              subtitle: Text('${item.quantity.toStringAsFixed(1)} x Rs ${item.rate.toStringAsFixed(2)}'),
              trailing: Text('Rs ${item.amount.toStringAsFixed(2)}'),
            )),
          ],
        ),
      ),
    );
  }
}
