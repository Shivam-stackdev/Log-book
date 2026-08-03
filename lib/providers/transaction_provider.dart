import 'package:flutter/foundation.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/transaction_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/repositories/inventory_repository.dart';

class TransactionProvider extends ChangeNotifier {
  final InventoryRepository repository;

  TransactionProvider(this.repository);

  List<TransactionEntity> _transactions = [];
  List<TransactionEntity> _todayTransactions = [];
  List<TransactionEntity> _monthTransactions = [];
  bool _isLoading = false;
  String? _error;

  List<TransactionEntity> get transactions => _transactions;
  List<TransactionEntity> get todayTransactions => _todayTransactions;
  List<TransactionEntity> get monthTransactions => _monthTransactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get dailyDeductionCost {
    return _todayTransactions
        .where((t) => t.type == 'deduction' || t.type == 'party')
        .fold(0.0, (sum, t) => sum + t.cost);
  }

  double get monthlyCost {
    return _monthTransactions.fold(0.0, (sum, t) => sum + t.cost);
  }

  Future<void> loadAllTransactions() async {
    _isLoading = true;
    notifyListeners();

    final result = await repository.getTransactions();
    result.fold(
      (failure) => _error = 'Failed to load transactions',
      (txns) => _transactions = txns,
    );
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadTodayTransactions() async {
    final result = await repository.getTodayTransactions();
    result.fold(
      (failure) => _error = 'Failed to load today transactions',
      (txns) => _todayTransactions = txns,
    );
    notifyListeners();
  }

  Future<void> loadMonthTransactions({int? year, int? month}) async {
    final now = DateTime.now();
    final y = year ?? now.year;
    final m = month ?? now.month;

    final result = await repository.getMonthTransactions(y, m);
    result.fold(
      (failure) => _error = 'Failed to load month transactions',
      (txns) => _monthTransactions = txns,
    );
    notifyListeners();
  }

  Future<bool> addTransaction(TransactionEntity transaction) async {
    final result = await repository.addTransaction(transaction);
    return result.fold(
      (failure) => false,
      (_) {
        loadTodayTransactions();
        loadMonthTransactions();
        loadAllTransactions();
        return true;
      },
    );
  }

  Future<List<TransactionEntity>> getTransactionsForItem(String itemId) async {
    final result = await repository.getTransactions(itemId: itemId);
    return result.fold(
      (failure) => [],
      (txns) => txns,
    );
  }

  Future<List<TransactionEntity>> getTransactionsForMonth(int year, int month) async {
    final result = await repository.getMonthTransactions(year, month);
    return result.fold(
      (failure) => [],
      (txns) => txns,
    );
  }
}
