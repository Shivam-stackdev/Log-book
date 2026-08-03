import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/item_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/transaction_entity.dart';
import 'package:intl/intl.dart';

class PdfReportService {
  /// Generate Current Stock Report PDF
  Future<void> generateInventoryReport(List<ItemEntity> items) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Army Mess Inventory Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text(
            'Generated: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 12),
          ),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ['Item Name', 'Category', 'Current Stock', 'Unit', 'Unit Cost', 'Reorder Level'],
            data: items
                .map((item) => [
                      item.name,
                      item.category,
                      item.currentStock.toStringAsFixed(1),
                      item.unit,
                      'Rs ${item.unitCost.toStringAsFixed(2)}',
                      item.reorderLevel.toStringAsFixed(1),
                    ])
                .toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerLeft,
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  /// Generate Daily Bill PDF per the refactor plan (Phase 2.2 / Phase 9)
  Future<void> generateDailyBillPdf(
    List<TransactionEntity> todayDeductions,
    List<ItemEntity> allItems,
  ) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateStr = DateFormat('dd MMMM yyyy').format(now);
    final timeStr = DateFormat('HH:mm').format(now);

    final totalSpent = todayDeductions.fold<double>(0, (sum, t) => sum + t.cost);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            // Header
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(),
              ),
              child: pw.Column(
                children: [
                  pw.Text(
                    'ARMY MESS - DAILY BILL',
                    style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text('Date: $dateStr', style: const pw.TextStyle(fontSize: 14)),
                  pw.Text('Time: $timeStr', style: const pw.TextStyle(fontSize: 14)),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // Deduction Table
            pw.TableHelper.fromTextArray(
              headers: ['ITEM', 'QTY', 'RATE', 'AMOUNT'],
              data: todayDeductions.map((txn) {
                return [
                  txn.itemName,
                  txn.quantity.toStringAsFixed(1),
                  'Rs ${txn.unitPrice.toStringAsFixed(2)}',
                  'Rs ${txn.cost.toStringAsFixed(2)}',
                ];
              }).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
            ),
            pw.SizedBox(height: 8),

            // Total
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL SPENT:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                  pw.Text('Rs ${totalSpent.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Left Stock
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('LEFT STOCK:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                  pw.SizedBox(height: 8),
                  ...allItems.map((item) => pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 2),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(item.name),
                            pw.Text('${item.currentStock.toStringAsFixed(1)} ${item.unit}'),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  /// Generate Monthly Report PDF (Phase 5 / Phase 9)
  Future<void> generateMonthlyReportPdf(
    List<TransactionEntity> transactions,
    List<ItemEntity> allItems,
    String monthName,
  ) async {
    final pdf = pw.Document();
    final totalCost = transactions.fold<double>(0, (sum, t) => sum + t.cost);
    final deductions = transactions.where((t) => t.type != 'addition');
    final additions = transactions.where((t) => t.type == 'addition');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'ARMY MESS - Monthly Report',
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text(monthName, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Text(
            'Generated: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 12),
          ),
          pw.SizedBox(height: 16),

          // Summary
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(border: pw.Border.all()),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('SUMMARY', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                _pdfRow('Total Transactions', '${transactions.length}'),
                _pdfRow('Deductions', '${deductions.length}'),
                _pdfRow('Additions', '${additions.length}'),
                _pdfRow('Total Cost', 'Rs ${totalCost.toStringAsFixed(2)}'),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // Transactions Table
          pw.Text('ALL TRANSACTIONS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: ['Date', 'Item', 'Type', 'Qty', 'Cost'],
            data: transactions.map((txn) {
              return [
                DateFormat('dd MMM HH:mm').format(txn.date),
                txn.itemName,
                txn.type.toUpperCase(),
                txn.quantity.toStringAsFixed(1),
                'Rs ${txn.cost.toStringAsFixed(2)}',
              ];
            }).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerLeft,
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }
}
