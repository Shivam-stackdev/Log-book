oppoimport 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:army_mess_inventory/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:army_mess_inventory/features/reports/data/pdf_report_service.dart';
import 'package:army_mess_inventory/features/inventory/presentation/widgets/glass_widgets.dart';
import 'package:go_router/go_router.dart';
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryAsync = ref.watch(inventoryListProvider);
    final pdfService = PdfReportService();

    return Scaffold(
      appBar: const GlassAppBar(title: 'Reports & Analytics'),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildReportTile(
              context,
              'Current Stock Report',
              'Generate a PDF of all items currently in stock.',
              Icons.inventory,
              () {
                inventoryAsync.whenData((items) => pdfService.generateInventoryReport(items));
              },
            ),
            const SizedBox(height: 15),
            _buildReportTile(
              context,
              'Monthly Deduction Summary',
              'View consumption patterns for the current month.',
              Icons.summarize,
              () {},
            ),
            const SizedBox(height: 15),
            _buildReportTile(
              context,
              'Officer Cost Analysis',
              'Detailed breakdown of costs per officer.',
              Icons.analytics,
              () => context.push('/cost-analysis'),
            ),
            const SizedBox(height: 15),
            _buildReportTile(
              context,
              'Purchase Suggestions',
              'View items that need to be reordered.',
              Icons.shopping_cart_checkout,
              () => context.push('/purchase-suggestions'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTile(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.download),
        onTap: onTap,
      ),
    );
  }
}
