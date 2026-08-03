import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:army_mess_inventory/main.dart';
import 'package:army_mess_inventory/features/reports/data/pdf_report_service.dart';
import 'package:army_mess_inventory/features/inventory/presentation/widgets/glass_widgets.dart';
import 'package:go_router/go_router.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pdfService = PdfReportService();

    return Scaffold(
      appBar: const GlassAppBar(title: 'Reports & Analytics'),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildReportTile(
              context,
              isDark,
              'Current Stock Report',
              'Generate a PDF of all items currently in stock.',
              Icons.inventory,
              Colors.blue,
              () {
                final items = ref.read(inventoryChangeProvider).items;
                if (items.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No items in inventory')),
                  );
                  return;
                }
                pdfService.generateInventoryReport(items);
              },
            ),
            const SizedBox(height: 12),
            _buildReportTile(
              context,
              isDark,
              'Daily Bill PDF',
              "Generate today's deduction bill as PDF.",
              Icons.receipt_long,
              Colors.orange,
              () {
                final items = ref.read(inventoryChangeProvider).items;
                final todayTxns = ref.read(transactionChangeProvider).todayTransactions
                    .where((t) => t.type == 'deduction')
                    .toList();
                if (todayTxns.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No deductions today')),
                  );
                  return;
                }
                pdfService.generateDailyBillPdf(todayTxns, items);
              },
            ),
            const SizedBox(height: 12),
            _buildReportTile(
              context,
              isDark,
              'Monthly History',
              'View consumption patterns month by month.',
              Icons.calendar_month,
              Colors.purple,
              () => context.push('/monthly-history'),
            ),
            const SizedBox(height: 12),
            _buildReportTile(
              context,
              isDark,
              'Purchase Suggestions',
              'View items that need to be reordered.',
              Icons.shopping_cart_checkout,
              Colors.green,
              () => context.push('/purchase-suggestions'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTile(
    BuildContext context,
    bool isDark,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
