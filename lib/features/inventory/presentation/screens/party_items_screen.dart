import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:army_mess_inventory/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:army_mess_inventory/features/inventory/presentation/widgets/glass_widgets.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/officer_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/party_items_entity.dart';
import 'package:army_mess_inventory/features/inventory/data/models/party_entry_model.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/party_entry_entity.dart';
import 'package:army_mess_inventory/core/utils/database_helper.dart';
import 'package:intl/intl.dart';

class PartyItemsScreen extends ConsumerStatefulWidget {
  final String officerId;
  final String officerName;

  const PartyItemsScreen({
    super.key,
    required this.officerId,
    required this.officerName,
  });

  @override
  ConsumerState<PartyItemsScreen> createState() => _PartyItemsScreenState();
}

class _PartyItemsScreenState extends ConsumerState<PartyItemsScreen> {
  List<PartyEntryEntity> _partyEntries = [];
  List<Map<String, dynamic>> _allPartyData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final repository = ref.read(officerRepositoryProvider);
    final dbHelper = ref.read(databaseHelperProvider);
    final db = await dbHelper.database;

    // Load party entries for this officer
    final entriesResult = await repository.getPartyEntries(widget.officerId);
    entriesResult.fold(
      (_) => _partyEntries = [],
      (entries) => _partyEntries = entries,
    );

    // Load detailed party items for each entry
    _allPartyData = [];
    for (var entry in _partyEntries) {
      final itemResults = await db.query(
        'party_items',
        where: 'partyEntryId = ?',
        whereArgs: [entry.id],
      );
      final items = itemResults.map((row) => PartyItemEntity.fromMap(row)).toList();
      _allPartyData.add({
        'entry': entry,
        'items': items,
      });
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(
        title: '${widget.officerName} - Party',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddPartyItemDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allPartyData.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.no_drinks, size: 60, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('No party items yet', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _showAddPartyItemDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Party Items'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _allPartyData.length,
                    itemBuilder: (context, index) {
                      final data = _allPartyData[index];
                      final entry = data['entry'] as PartyEntryEntity;
                      final items = data['items'] as List<PartyItemEntity>;
                      return _buildPartyCard(entry, items);
                    },
                  ),
                ),
    );
  }

  Widget _buildPartyCard(PartyEntryEntity entry, List<PartyItemEntity> items) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        initiallyExpanded: false,
        title: Row(
          children: [
            const Icon(Icons.local_bar, color: Colors.purple, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.description,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    DateFormat('dd MMM yyyy, hh:mm a').format(entry.date),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Text(
              '₹${entry.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.purple.shade700,
              ),
            ),
          ],
        ),
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Items:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.itemName,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Text(
                        '${item.quantity} ${item.unit}',
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '₹${item.rate.toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '₹${item.amount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ],
                  ),
                )),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('Total: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      '₹${entry.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddPartyItemDialog() {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    final rateController = TextEditingController();
    final unitController = TextEditingController(text: 'bottle');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Item to Party'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Item Name (Bar Item)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: unitController,
              decoration: const InputDecoration(labelText: 'Unit (e.g., bottle, peg, glass)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: rateController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Rate per unit (₹)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final qty = double.tryParse(quantityController.text) ?? 0;
              final rate = double.tryParse(rateController.text) ?? 0;
              final unit = unitController.text.trim();

              if (name.isEmpty || qty <= 0 || rate <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields correctly')),
                );
                return;
              }

              final db = await ref.read(databaseHelperProvider).database;
              final amount = qty * rate;

              // Create or get a party entry for today
              final today = DateTime.now();
              final todayStr = today.toIso8601String().split('T')[0];
              
              // Check if there's already an entry for this officer today
              var existingEntries = await db.query(
                'party_entries',
                where: 'officerId = ? AND date LIKE ?',
                whereArgs: [widget.officerId, '$todayStr%'],
              );

              String partyEntryId;
              if (existingEntries.isNotEmpty) {
                partyEntryId = existingEntries.first['id'] as String;
                // Update existing entry amount
                final currentAmount = existingEntries.first['amount'] as double;
                await db.update(
                  'party_entries',
                  {'amount': currentAmount + amount},
                  where: 'id = ?',
                  whereArgs: [partyEntryId],
                );
              } else {
                partyEntryId = const Uuid().v4();
                await db.insert('party_entries', {
                  'id': partyEntryId,
                  'officerId': widget.officerId,
                  'date': today.toIso8601String(),
                  'amount': amount,
                  'description': 'Bar Items - $name',
                });
              }

              // Insert party item
              await db.insert('party_items', {
                'id': const Uuid().v4(),
                'partyEntryId': partyEntryId,
                'itemName': name,
                'quantity': qty,
                'rate': rate,
                'amount': amount,
                'unit': unit,
              });

              Navigator.pop(context);
              await _loadData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Item added to party')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
