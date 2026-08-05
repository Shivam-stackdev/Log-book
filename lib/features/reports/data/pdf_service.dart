import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:army_mess_inventory/core/logging/logger.dart';
import 'package:army_mess_inventory/core/utils/database_helper.dart';

class PdfReportService {
  final DatabaseHelper dbHelper;

  PdfReportService(this.dbHelper);

  /// Generate and save inventory report to Documents/Mesh Reports
  Future<String> generateInventoryReport() async {
    final db = await dbHelper.database;
    final items = await db.query('items', orderBy: 'name ASC');
    final deductions = await db.query('deduction_entries', orderBy: 'date DESC', limit: 100);

    final pdf = pw.Document();
    final dateStr = DateFormat('dd MMM yyyy').format(DateTime.now());
    final fileName = 'Mesh_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(20),
      header: (context) => pw.Header(
        level: 0,
        child: pw.Row(children: [
          pw.Text('MESH MANAGEMENT', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Spacer(),
          pw.Text(dateStr, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
        ]),
      ),
      build: (context) => [
        pw.Text('Inventory Report', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.TableHelper.fromTextArray(
          headers: ['Item', 'Category', 'Stock', 'Unit', 'Rate (Rs)', 'Status'],
          data: items.map((item) {
            final stock = (item['currentStock'] as num).toDouble();
            final reorder = (item['reorderLevel'] as num).toDouble();
            final status = stock == 0 ? 'Out of Stock' : stock <= reorder ? 'Low' : 'OK';
            return [
              item['name'],
              item['category'],
              stock.toStringAsFixed(1),
              item['unit'],
              (item['rate'] as num? ?? 0).toStringAsFixed(0),
              status,
            ];
          }).toList(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey),
          cellAlignment: pw.Alignment.centerLeft,
          cellStyle: const pw.TextStyle(fontSize: 10),
          cellPadding: const pw.EdgeInsets.all(4),
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
        ),
        pw.SizedBox(height: 20),
        pw.Text('Recent Deductions', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        ...deductions.map((d) => pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Row(children: [
            pw.Text(DateFormat('dd/MM').format(DateTime.parse(d['date'] as String)), style: const pw.TextStyle(fontSize: 9)),
            pw.SizedBox(width: 8),
            pw.Text(d['reason'] as String, style: const pw.TextStyle(fontSize: 10)),
            pw.Spacer(),
            pw.Text('${d['quantity']} ${d['unit']}', style: const pw.TextStyle(fontSize: 10)),
          ]),
        )),
      ],
    ));

    return await _savePdf(pdf, fileName);
  }

  /// Generate monthly cost report
  Future<String> generateMonthlyCostReport() async {
    final db = await dbHelper.database;
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);

    final entries = await db.query(
      'deduction_entries',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [monthStart.toIso8601String(), monthEnd.toIso8601String()],
      orderBy: 'date DESC',
    );

    // Join with items to get names and rates
    final items = await db.query('items');
    final itemMap = {for (var item in items) item['id'] as String: item};

    final pdf = pw.Document();
    final fileName = 'Monthly_Cost_${DateFormat('yyyyMM').format(now)}.pdf';

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(20),
      build: (context) {
        double totalCost = 0;
        return [
          pw.Text('Monthly Cost Report', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Text(DateFormat('MMMM yyyy').format(now), style: pw.TextStyle(fontSize: 12, color: PdfColors.grey)),
          pw.SizedBox(height: 12),
          pw.TableHelper.fromTextArray(
            headers: ['Date', 'Item', 'Qty', 'Unit', 'Reason', 'Cost'],
            data: entries.map((e) {
              final item = itemMap[e['itemId']] as Map<String, dynamic>?;
              final itemName = item?['name'] as String? ?? 'Unknown';
              final rate = (item?['rate'] as num? ?? 0).toDouble();
              final qty = (e['quantity'] as num).toDouble();
              final cost = rate * qty;
              totalCost += cost;
            return [
              DateFormat('dd/MM').format(DateTime.parse(e['date'] as String)),
              itemName,
              qty.toStringAsFixed(1),
              item?['unit'] as String? ?? '',
              (e['reason'] as String?) ?? '',
              'Rs. ${cost.toStringAsFixed(0)}',
            ];
            }).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey),
            cellPadding: const pw.EdgeInsets.all(4),
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          ),
          pw.SizedBox(height: 12),
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            pw.Text('Total Monthly Cost:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.Text('Rs. ${totalCost.toStringAsFixed(0)}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          ]),
        ];
      },
    ));

    return await _savePdf(pdf, fileName);
  }

  Future<String> _savePdf(pw.Document pdf, String fileName) async {
    try {
      // Save to Documents/Mesh Reports
      final directory = await getApplicationDocumentsDirectory();
      final meshDir = Directory('${directory.path}/Mesh Reports');
      if (!await meshDir.exists()) {
        await meshDir.create(recursive: true);
      }
      final filePath = '${meshDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());
      AppLogger.i('PDF', 'Report saved: $filePath');
      return filePath;
    } catch (e) {
      AppLogger.e('PDF', 'Failed to save PDF', e);
      rethrow;
    }
  }
}
