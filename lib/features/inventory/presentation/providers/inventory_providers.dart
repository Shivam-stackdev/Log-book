import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:army_mess_inventory/core/utils/database_helper.dart';
import 'package:army_mess_inventory/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:army_mess_inventory/features/inventory/data/repositories/officer_repository_impl.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/item_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/officer_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/party_entry_entity.dart';
// PartyItemEntity is in party_entry_entity.dart
import 'package:army_mess_inventory/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:army_mess_inventory/features/inventory/domain/repositories/officer_repository.dart';
import 'package:army_mess_inventory/core/error/app_exceptions.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/purchase_suggestion_entity.dart';
import 'package:army_mess_inventory/core/logging/logger.dart';

// ─── Core Providers ──────────────────────────────────────────────────────

final databaseHelperProvider = Provider<DatabaseHelper>((ref) => DatabaseHelper.instance);

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return InventoryRepositoryImpl(dbHelper);
});

final officerRepositoryProvider = Provider<OfficerRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return OfficerRepositoryImpl(dbHelper);
});

// ─── Inventory Provider ──────────────────────────────────────────────────

final inventoryListProvider =
    StateNotifierProvider<InventoryNotifier, AsyncValue<List<ItemEntity>>>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return InventoryNotifier(repository);
});

class InventoryNotifier extends StateNotifier<AsyncValue<List<ItemEntity>>> {
  final InventoryRepository _repository;

  InventoryNotifier(this._repository) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final result = await _repository.getItems();
      result.fold(
        (error) {
          AppLogger.e('InventoryProvider', 'Load failed', error);
          state = AsyncValue.error(error, StackTrace.current);
        },
        (items) => state = AsyncValue.data(items),
      );
    } catch (e, st) {
      AppLogger.e('InventoryProvider', 'Unexpected error', e);
      state = AsyncValue.error(
        AppException(code: 'UNKNOWN', message: 'Failed to load inventory: $e'),
        st,
      );
    }
  }

  Future<void> refresh() => _load();

  Future<bool> addItem(ItemEntity item) async {
    final result = await _repository.addItem(item);
    return result.fold(
      (error) {
        AppLogger.e('InventoryProvider', 'Add item failed', error);
        _showError(error);
        return false;
      },
      (_) {
        _load();
        return true;
      },
    );
  }

  Future<bool> updateItem(ItemEntity item) async {
    final result = await _repository.updateItem(item);
    return result.fold(
      (error) {
        AppLogger.e('InventoryProvider', 'Update item failed', error);
        _showError(error);
        return false;
      },
      (_) {
        _load();
        return true;
      },
    );
  }

  Future<bool> deleteItem(String id) async {
    final result = await _repository.deleteItem(id);
    return result.fold(
      (error) {
        AppLogger.e('InventoryProvider', 'Delete item failed', error);
        _showError(error);
        return false;
      },
      (_) {
        _load();
        return true;
      },
    );
  }

  void _showError(AppException error) {
    // Error is handled by the calling screen via returned bool
  }

  @override
  void dispose() {
    AppLogger.d('InventoryProvider', 'Disposed');
    super.dispose();
  }
}

// ─── Officer Provider ────────────────────────────────────────────────────

final officerListProvider =
    StateNotifierProvider<OfficerNotifier, AsyncValue<List<OfficerEntity>>>((ref) {
  final repository = ref.watch(officerRepositoryProvider);
  return OfficerNotifier(repository);
});

class OfficerNotifier extends StateNotifier<AsyncValue<List<OfficerEntity>>> {
  final OfficerRepository _repository;

  OfficerNotifier(this._repository) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final result = await _repository.getOfficers();
      result.fold(
        (error) {
          AppLogger.e('OfficerProvider', 'Load failed', error);
          state = AsyncValue.error(error, StackTrace.current);
        },
        (officers) => state = AsyncValue.data(officers),
      );
    } catch (e, st) {
      state = AsyncValue.error(
        AppException(code: 'UNKNOWN', message: 'Failed to load officers: $e'),
        st,
      );
    }
  }

  Future<void> refresh() => _load();

  Future<bool> addOfficer(OfficerEntity officer) async {
    final result = await _repository.addOfficer(officer);
    return result.fold(
      (error) {
        AppLogger.e('OfficerProvider', 'Add officer failed', error);
        return false;
      },
      (_) {
        _load();
        return true;
      },
    );
  }

  @override
  void dispose() {
    AppLogger.d('OfficerProvider', 'Disposed');
    super.dispose();
  }
}

// ─── Purchase Suggestions Provider ───────────────────────────────────────

final purchaseSuggestionsProvider = FutureProvider<List<PurchaseSuggestionEntity>>((ref) async {
  final repository = ref.watch(inventoryRepositoryProvider);
  final result = await repository.getItems();
  return result.fold(
    (error) => throw error,
    (items) {
      final suggestions = items
          .where((item) => item.currentStock <= item.reorderLevel)
          .map((item) {
            final deficit = item.reorderLevel - item.currentStock;
            final suggestedQty = deficit + (item.reorderLevel * 0.5);
            final priority = switch (item.currentStock) {
              0 => 'High',
              _ when item.currentStock <= item.reorderLevel * 0.5 => 'Medium',
              _ => 'Low',
            };
            return PurchaseSuggestionEntity(
              item: item,
              suggestedQuantity: suggestedQty,
              priority: priority,
            );
          })
          .toList();
      return suggestions;
    },
  );
});

// ─── Item History Provider ───────────────────────────────────────────────

final itemHistoryProvider = FutureProvider.family<List<dynamic>, String>((ref, itemId) async {
  final repository = ref.watch(inventoryRepositoryProvider);
  final stockResult = await repository.getStockEntries(itemId);
  final deductionResult = await repository.getDeductionEntries(itemId);

  List<dynamic> history = [];
  stockResult.fold((_) => null, (entries) => history.addAll(entries));
  deductionResult.fold((_) => null, (entries) => history.addAll(entries));
  history.sort((a, b) => b.date.compareTo(a.date));
  return history;
});

// ─── Party Data Provider ─────────────────────────────────────────────────

final officerPartyDataProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, officerId) async {
  final repository = ref.watch(officerRepositoryProvider);
  final dbHelper = ref.watch(databaseHelperProvider);
  final db = await dbHelper.database;

  final entriesResult = await repository.getPartyEntries(officerId);
  return entriesResult.fold(
    (error) => throw error,
    (entries) async {
      List<Map<String, dynamic>> allData = [];
      for (var entry in entries) {
        final items = await repository.getPartyItems(entry.id);
        items.fold((_) => null, (itemList) {
          allData.add({'entry': entry, 'items': itemList});
        });
      }
      return allData;
    },
  );
});
