import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:army_mess_inventory/core/theme/app_theme.dart';
import 'package:army_mess_inventory/core/utils/database_helper.dart';
import 'package:army_mess_inventory/core/logging/logger.dart';

class CostAnalysisScreen extends ConsumerStatefulWidget {
  const CostAnalysisScreen({super.key});
  @override
  ConsumerState<CostAnalysisScreen> createState() => _CostAnalysisScreenState();
}

class _CostAnalysisScreenState extends ConsumerState<CostAnalysisScreen> {
  Map<String, double> _categoryCosts = {};
  double _totalCost = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCosts();
  }

  Future<void> _loadCosts() async {
    setState(() => _isLoading = true);
    try {
      final dbHelper = DatabaseHelper.instance;
      final db = await dbHelper.database;
      final items = await db.query('items');
      final itemMap = {for (var i in items) i['id'] as String: i};
      final deductions = await db.query('deduction_entries');

      Map<String, double> costs = {};
      double total = 0;
      for (var d in deductions) {
        final item = itemMap[d['itemId']];
        if (item != null) {
          final category = item['category'] as String;
          final rate = (item['rate'] as num? ?? 0).toDouble();
          final qty = (d['quantity'] as num).toDouble();
          final cost = rate * qty;
          costs[category] = (costs[category] ?? 0) + cost;
          total += cost;
        }
      }

      if (mounted) setState(() { _categoryCosts = costs; _totalCost = total; _isLoading = false; });
    } catch (e) {
      AppLogger.e('CostAnalysis', 'Failed to load costs', e);
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = [AppColors.primary, AppColors.secondary, AppColors.accent, AppColors.error, AppColors.warning];
    return Scaffold(
      appBar: AppBar(title: const Text('Cost Analysis')),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : _categoryCosts.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.analytics, size: 64, color: AppColors.textSecondary.withOpacity(0.4)), const SizedBox(height: 16), Text('No cost data available', style: Theme.of(context).textTheme.titleLarge)]))
          : RefreshIndicator(onRefresh: _loadCosts, child: ListView(padding: const EdgeInsets.all(16), children: [
              Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
                Text('Total Cost', style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Text('Rs. ${_totalCost.toStringAsFixed(0)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ]))),
              const SizedBox(height: 16),
              const Text('By Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ..._categoryCosts.entries.toList().asMap().entries.map((e) {
                final idx = e.key;
                final color = colors[idx % colors.length];
                final percentage = _totalCost > 0 ? (e.value.value / _totalCost * 100) : 0;
                return Card(margin: const EdgeInsets.only(bottom: 8), child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(e.value.key, style: const TextStyle(fontWeight: FontWeight.w500)),
                    Text('Rs. ${e.value.value.toStringAsFixed(0)} (${percentage.toStringAsFixed(1)}%)', style: TextStyle(color: color, fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(height: 6),
                  ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: percentage / 100, backgroundColor: color.withOpacity(0.1), valueColor: AlwaysStoppedAnimation(color), minHeight: 8)),
                ])));
              }),
            ])),
    );
  }
}
