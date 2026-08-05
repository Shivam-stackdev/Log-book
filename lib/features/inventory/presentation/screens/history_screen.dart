import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:army_mess_inventory/core/theme/app_theme.dart';
import 'package:army_mess_inventory/core/utils/database_helper.dart';
import 'package:army_mess_inventory/core/logging/logger.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});
  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final dbHelper = DatabaseHelper.instance;
      final db = await dbHelper.database;
      final stockEntries = await db.query('stock_entries', orderBy: 'date DESC', limit: 200);
      final deductionEntries = await db.query('deduction_entries', orderBy: 'date DESC', limit: 200);

      final items = await db.query('items');
      final itemMap = {for (var i in items) i['id'] as String: i};

      List<Map<String, dynamic>> history = [];
      for (var entry in stockEntries) {
        final item = itemMap[entry['itemId']];
        history.add({'type': 'stock', 'date': entry['date'], 'itemName': item?['name'] ?? 'Unknown', 'quantity': entry['quantity'], 'rate': entry['unitPrice'], 'supplier': entry['supplier'], 'id': entry['id']});
      }
      for (var entry in deductionEntries) {
        final item = itemMap[entry['itemId']];
        history.add({'type': 'deduction', 'date': entry['date'], 'itemName': item?['name'] ?? 'Unknown', 'quantity': entry['quantity'], 'reason': entry['reason'], 'id': entry['id']});
      }
      history.sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));

      if (mounted) setState(() { _history = history; _isLoading = false; });
    } catch (e) {
      AppLogger.e('HistoryScreen', 'Failed to load history', e);
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : _history.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.history, size: 64, color: AppColors.textSecondary.withOpacity(0.4)), const SizedBox(height: 16), Text('No history yet', style: Theme.of(context).textTheme.titleLarge)]))
          : RefreshIndicator(
              onRefresh: _loadHistory,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _history.length,
                itemBuilder: (context, index) => _buildHistoryItem(_history[index]),
              ),
            ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> entry) {
    final isStock = entry['type'] == 'stock';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isStock ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
          child: Icon(isStock ? Icons.add : Icons.remove, color: isStock ? AppColors.success : AppColors.error, size: 18),
        ),
        title: Text(entry['itemName'] as String, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text('${entry['reason'] ?? entry['supplier'] ?? ''} • ${DateFormat('dd MMM yyyy').format(DateTime.parse(entry['date'] as String))}'),
        trailing: Text(
          '${isStock ? "+" : "-"}${entry['quantity']} ${isStock ? "Rs. ${entry['rate']}" : ""}',
          style: TextStyle(color: isStock ? AppColors.success : AppColors.error, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
