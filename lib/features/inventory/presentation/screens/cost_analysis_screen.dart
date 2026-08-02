import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:army_mess_inventory/features/inventory/domain/usecases/calculate_cost_per_officer.dart';
import 'package:army_mess_inventory/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:army_mess_inventory/features/inventory/presentation/widgets/glass_widgets.dart';
import 'package:intl/intl.dart';

class CostAnalysisScreen extends ConsumerStatefulWidget {
  const CostAnalysisScreen({super.key});

  @override
  ConsumerState<CostAnalysisScreen> createState() => _CostAnalysisScreenState();
}

class _CostAnalysisScreenState extends ConsumerState<CostAnalysisScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final params = CostParams(startDate: _startDate, endDate: _endDate);
    final costAsync = ref.watch(costPerOfficerProvider(params));

    return Scaffold(
      appBar: const GlassAppBar(title: 'Cost Analysis'),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDateRangePicker(),
            const SizedBox(height: 30),
            costAsync.when(
              data: (cost) => _buildCostCard(cost),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
            const SizedBox(height: 30),
            const Text(
              'Cost Trends',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GlassContainer(
                child: Center(
                  child: Text(
                    'Chart Visualization Placeholder\n(Use Syncfusion or FlChart in production)',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangePicker() {
    return GlassContainer(
      padding: const EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Period', style: TextStyle(fontSize: 12, color: Colors.black54)),
              Text(
                '${DateFormat('dd MMM').format(_startDate)} - ${DateFormat('dd MMM').format(_endDate)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.date_range, color: Colors.green),
            onPressed: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
              );
              if (range != null) {
                setState(() {
                  _startDate = range.start;
                  _endDate = range.end;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCostCard(double cost) {
    return GlassContainer(
      padding: const EdgeInsets.all(25),
      opacity: 0.2,
      child: Column(
        children: [
          const Text(
            'Estimated Cost Per Officer',
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          Text(
            '₹ ${cost.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Based on total party expenses and active strength',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
