import 'package:flutter/foundation.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/item_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/repositories/inventory_repository.dart';

class InventoryProvider extends ChangeNotifier {
  final InventoryRepository repository;

  InventoryProvider(this.repository) {
    loadItems();
  }

  List<ItemEntity> _items = [];
  bool _isLoading = false;
  String? _error;

  List<ItemEntity> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<String> get categories {
    final values = _items.map((item) => item.category).where((category) => category.trim().isNotEmpty).toSet().toList();
    values.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return values;
  }

  int get totalItems => _items.length;
  int get lowStockCount => _items.where((i) => i.reorderLevel > 0 && i.currentStock <= i.reorderLevel).length;

  Future<void> loadItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await repository.getItems();
    result.fold(
      (failure) {
        _error = 'Failed to load items';
        _isLoading = false;
      },
      (items) {
        _items = items;
        _isLoading = false;
      },
    );
    notifyListeners();
  }

  Future<bool> addItem(ItemEntity item) async {
    final result = await repository.addItem(item);
    return result.fold(
      (failure) => false,
      (_) {
        loadItems();
        return true;
      },
    );
  }

  Future<bool> updateItem(ItemEntity item) async {
    final result = await repository.updateItem(item);
    return result.fold(
      (failure) => false,
      (_) {
        loadItems();
        return true;
      },
    );
  }

  Future<bool> deleteItem(String id) async {
    final result = await repository.deleteItem(id);
    return result.fold(
      (failure) => false,
      (_) {
        loadItems();
        return true;
      },
    );
  }

  ItemEntity? getItemById(String id) {
    try {
      return _items.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }
}
