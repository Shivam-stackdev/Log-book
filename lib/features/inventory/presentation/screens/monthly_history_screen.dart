import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:army_mess_inventory/main.dart';
import 'package:army_mess_inventory/features/inventory/presentation/widgets/glass_widgets.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/transaction_entity.dart';
import 'package:army_mess_inventory/features/reports/data/pdf_report_service.dart';
import 'package:intl/intl.dart';

class MonthlyHistoryScreen extends ConsumerStatefulWidget {
  const MonthlyHistoryScreen({super.key});

  @override
  ConsumerState<MonthlyHistoryScreen> createState() => _MonthlyHistoryScreenState();
}

class _MonthlyHistoryScreenState extends ConsumerState<MonthlyHistoryScreen> {
  final List<_MonthData> _monthsData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMonthlyData();
  }

  Future<void> _loadMonthlyData() async {
    setState(() => _isLoading = true);
    final txProvider = ref.read(transactionChangeProvider);

    final now = DateTime.now();
    final months = <_MonthData>[];

    // Check last 12 months
    for (int i = 0; i < 12; i++) {
      final dt = DateTime(now.year, now.month - i, 1);
      final txns = await txProvider.getTransactionsForMonth(dt.year, dt.month);
      if (txns.isNotEmpty) {
        months.add(_MonthData(year: dt.year, month: dt.month, transactions: txns));
      }
    }

    setState(() {
      _monthsData
        ..clear()
        ..addAll(months);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const GlassAppBar(title: 'Monthly History'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _monthsData.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today, size: 64, color: isDark ? Colors.white38 : Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No transaction history found',
                        style: TextStyle(fontSize: 16, color: isDark ? Colors.white54 : Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadMonthlyData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _monthsData.length,
                    itemBuilder: (context, index) => _buildMonthCard(_monthsData[index], isDark),
                  ),
                ),
    );
  }

  Widget _buildMonthCard(_MonthData data, bool isDark) {
    final monthName = DateFormat('MMMM yyyy').format(DateTime(data.year, data.month));
    final daysInMonth = DateTime(data.year, data.month + 1, 0).day;

    final deductionTxns = data.transactions.where((t) => t.type == 'deduction' || t.type == 'party');
    final additionTxns = data.transactions.where((t) => t.type == 'addition');

    final totalDeductionQty = deductionTxns.fold<double>(0, (s, t) => s + t.quantity);
    final totalAdditionQty = additionTxns.fold<double>(0, (s, t) => s + t.quantity);
    final totalCost = data.transactions.fold<double>(0, (s, t) => s + t.cost);
    final avgPerDay = totalDeductionQty / daysInMonth;
    final perDayCost = totalCost / daysInMonth;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              monthName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.green.shade300 : Colors.green.shade800,
              ),
            ),
            const Divider(),
            _buildStatRow('Total Transactions', '${data.transactions.length}', isDark),
            _buildStatRow('Total Deduction', '${totalDeductionQty.toStringAsFixed(1)} units', isDark),
            _buildStatRow('Total Addition', '${totalAdditionQty.toStringAsFixed(1)} units', isDark),
            _buildStatRow('Total Cost', 'Rs ${NumberFormat('#,##0.00', 'en_IN').format(totalCost)}', isDark),
            _buildStatRow('Avg/Day Deduction', '${avgPerDay.toStringAsFixed(1)} units', isDark),
            _buildStatRow('Per Day Cost', 'Rs ${NumberFormat('#,##0.00', 'en_IN').format(perDayCost)}', isDark),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('View Details'),
                    onPressed: () => _showMonthDetails(data, monthName),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Download PDF'),
                    onPressed: () => _downloadMonthlyPdf(data, monthName),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showMonthDetails(_MonthData data, String monthName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (ctx, scrollCtrl) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(monthName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  controller: scrollCtrl,
                  itemCount: data.transactions.length,
                  itemBuilder: (ctx, index) {
                    final txn = data.transactions[index];
                    final isAdd = txn.type == 'addition';
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        isAdd ? Icons.add_circle : Icons.remove_circle,
                        color: isAdd ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      title: Text('${txn.itemName} - ${txn.quantity.toStringAsFixed(1)}'),
                      subtitle: Text('${txn.type.toUpperCase()} | ${txn.reason ?? ''} | ${DateFormat('dd MMM HH:mm').format(txn.date)}'),
                      trailing: Text('Rs ${txn.cost.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _downloadMonthlyPdf(_MonthData data, String monthName) async {
    final pdfService = PdfReportService();
    final items = ref.read(inventoryChangeProvider).items;
    await pdfService.generateMonthlyReportPdf(data.transactions, items, monthName);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$monthName report generated')),
      );
    }
  }
}

class _MonthData {
  final int year;
  final int month;
  final List<TransactionEntity> transactions;
  _MonthData({required this.year, required this.month, required this.transactions});
}
