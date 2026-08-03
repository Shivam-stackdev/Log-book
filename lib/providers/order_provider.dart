import 'package:flutter/foundation.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/stock_order_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/repositories/inventory_repository.dart';

class OrderProvider extends ChangeNotifier {
  final InventoryRepository repository;

  OrderProvider(this.repository) {
    loadOrders();
  }

  List<StockOrderEntity> _allOrders = [];
  bool _isLoading = false;
  String? _error;

  List<StockOrderEntity> get allOrders => _allOrders;
  List<StockOrderEntity> get pendingOrders => _allOrders.where((o) => !o.isFulfilled).toList();
  List<StockOrderEntity> get fulfilledOrders => _allOrders.where((o) => o.isFulfilled).toList();
  List<StockOrderEntity> get partyOrders => _allOrders.where((o) => o.type == 'party').toList();
  List<StockOrderEntity> get regularOrders => _allOrders.where((o) => o.type == 'regular').toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadOrders() async {
    _isLoading = true;
    notifyListeners();

    final result = await repository.getStockOrders();
    result.fold(
      (failure) => _error = 'Failed to load orders',
      (orders) => _allOrders = orders,
    );
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addOrder(StockOrderEntity order) async {
    final result = await repository.addStockOrder(order);
    return result.fold(
      (failure) => false,
      (_) {
        loadOrders();
        return true;
      },
    );
  }

  Future<bool> fulfillOrder(String orderId) async {
    final result = await repository.fulfillOrder(orderId);
    return result.fold(
      (failure) => false,
      (_) {
        loadOrders();
        return true;
      },
    );
  }
}
