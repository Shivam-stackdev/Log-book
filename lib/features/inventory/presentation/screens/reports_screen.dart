import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import 'package:army_mess_inventory/core/theme/app_theme.dart';
import 'package:army_mess_inventory/core/utils/database_helper.dart';
import 'package:army_mess_inventory/features/reports/data/pdf_service.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});
  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  bool _isGenerating = false;

  Future<void> _generateReport(bool isMonthly) async {
    setState(() => _isGenerating = true);
    try {
      final dbHelper = DatabaseHelper.instance;
      final pdfService = PdfReportService(dbHelper);
      final filePath = isMonthly
          ? await pdfService.generateMonthlyCostReport()
          : await pdfService.generateInventoryReport();

      setState(() => _isGenerating = false);

      await Share.shareXFiles([XFile(filePath)]);
      if (mounted) {
        final fileName = filePath.split('/').last;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Report saved and shared: $fileName')));
      }
    } catch (e) {
      setState(() => _isGenerating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _buildReportCard(
            title: 'Inventory Report',
            subtitle: 'Full stock list with current levels, rates, and status',
            icon: Icons.inventory_2,
            color: AppColors.primary,
            onTap: () => _generateReport(false),
          ),
          const SizedBox(height: 16),
          _buildReportCard(
            title: 'Monthly Cost Report',
            subtitle: 'All deductions for current month with total cost',
            icon: Icons.account_balance_wallet,
            color: AppColors.secondary,
            onTap: () => _generateReport(true),
          ),
          if (_isGenerating) ...[
            const SizedBox(height: 24),
            const Center(child: CircularProgressIndicator()),
          ],
        ]),
      ),
    );
  }

  Widget _buildReportCard({required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Padding(padding: const EdgeInsets.only(top: 4), child: Text(subtitle, style: TextStyle(color: AppColors.textSecondary))),
        trailing: _isGenerating ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.download),
        onTap: _isGenerating ? null : onTap,
      ),
    );
  }
}
