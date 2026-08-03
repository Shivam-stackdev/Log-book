import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:army_mess_inventory/main.dart';
import 'package:army_mess_inventory/features/inventory/presentation/widgets/glass_widgets.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/transaction_entity.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _filterType = 'all'; // all, addition, deduction, party

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionChangeProvider).loadAllTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final txProvider = ref.watch(transactionChangeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredTxns = _filterType == 'all'
        ? txProvider.transactions
        : txProvider.transactions.where((t) => t.type == _filterType).toList();

    return Scaffold(
      appBar: const GlassAppBar(title: 'Transaction History'),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all', isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip('Additions', 'addition', isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip('Deductions', 'deduction', isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip('Party', 'party', isDark),
                ],
              ),
            ),
          ),

          // Transaction count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredTxns.length} transactions',
                  style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                ),
                Text(
                  'Total: Rs ${filteredTxns.fold<double>(0, (s, t) => s + t.cost).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.green.shade300 : Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Transaction list
          Expanded(
            child: txProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredTxns.isEmpty
                    ? Center(
                        child: Text(
                          'No transactions found',
                          style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredTxns.length,
                        itemExtent: 72,
                        itemBuilder: (context, index) {
                          final txn = filteredTxns[index];
                          return _buildTransactionTile(txn, isDark);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String type, bool isDark) {
    final selected = _filterType == type;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filterType = type),
      selectedColor: Colors.green.withValues(alpha: 0.25),
      checkmarkColor: Colors.green,
      labelStyle: TextStyle(
        color: selected ? Colors.green : (isDark ? Colors.white70 : Colors.black54),
      ),
    );
  }

  Widget _buildTransactionTile(TransactionEntity txn, bool isDark) {
    final isAddition = txn.type == 'addition';
    final icon = isAddition
        ? Icons.add_circle_outline
        : txn.type == 'party'
            ? Icons.celebration
            : Icons.remove_circle_outline;
    final color = isAddition ? Colors.green : (txn.type == 'party' ? Colors.purple : Colors.red);

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: color),
        title: Text(
          '${txn.itemName} ${isAddition ? '+' : '-'}${txn.quantity.toStringAsFixed(1)}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${txn.type.toUpperCase()} | ${txn.reason ?? ''} | ${DateFormat('dd MMM yyyy, HH:mm').format(txn.date)}',
          style: const TextStyle(fontSize: 11),
        ),
        trailing: Text(
          'Rs ${txn.cost.toStringAsFixed(0)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
      ),
    );
  }
}
