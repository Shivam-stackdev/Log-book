import 'package:flutter/foundation.dart';
import 'package:army_mess_inventory/providers/inventory_provider.dart';
import 'package:army_mess_inventory/providers/transaction_provider.dart';

/// DashboardProvider computes live stats for the home screen.
/// It listens to InventoryProvider and TransactionProvider changes.
class DashboardProvider extends ChangeNotifier {
  final InventoryProvider inventoryProvider;
  final TransactionProvider transactionProvider;

  DashboardProvider({
    required this.inventoryProvider,
    required this.transactionProvider,
  }) {
    inventoryProvider.addListener(_onDataChanged);
    transactionProvider.addListener(_onDataChanged);
    refresh();
  }

  int _totalItems = 0;
  int _lowStockCount = 0;
  double _dailyDeduction = 0;
  double _monthlyCost = 0;

  int get totalItems => _totalItems;
  int get lowStockCount => _lowStockCount;
  double get dailyDeduction => _dailyDeduction;
  double get monthlyCost => _monthlyCost;

  void _onDataChanged() {
    _recalculate();
  }

  void _recalculate() {
    _totalItems = inventoryProvider.totalItems;
    _lowStockCount = inventoryProvider.lowStockCount;
    _dailyDeduction = transactionProvider.dailyDeductionCost;
    _monthlyCost = transactionProvider.monthlyCost;
    notifyListeners();
  }

  Future<void> refresh() async {
    await Future.wait([
      inventoryProvider.loadItems(),
      transactionProvider.loadTodayTransactions(),
      transactionProvider.loadMonthTransactions(),
    ]);
    _recalculate();
  }

  @override
  void dispose() {
    inventoryProvider.removeListener(_onDataChanged);
    transactionProvider.removeListener(_onDataChanged);
    super.dispose();
  }
}
