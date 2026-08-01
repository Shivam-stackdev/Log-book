import 'package:flutter_riverpod/riverpod.dart';
import 'package:army_mess_inventory/core/utils/database_helper.dart';
import 'package:army_mess_inventory/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:army_mess_inventory/features/inventory/data/repositories/officer_repository_impl.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/item_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/officer_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:army_mess_inventory/features/inventory/domain/repositories/officer_repository.dart';
import 'package:army_mess_inventory/features/inventory/domain/usecases/get_items.dart';
import 'package:army_mess_inventory/features/inventory/domain/usecases/add_item.dart';
import 'package:army_mess_inventory/features/inventory/domain/usecases/get_purchase_suggestions.dart';
import 'package:army_mess_inventory/features/inventory/domain/usecases/calculate_cost_per_officer.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/purchase_suggestion_entity.dart';
import 'package:army_mess_inventory/core/usecases/usecase.dart';

final databaseHelperProvider = Provider((ref) => DatabaseHelper.instance);

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return InventoryRepositoryImpl(dbHelper);
});

final officerRepositoryProvider = Provider<OfficerRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return OfficerRepositoryImpl(dbHelper);
});

final inventoryListProvider = StateNotifierProvider<InventoryNotifier, AsyncValue<List<ItemEntity>>>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return InventoryNotifier(repository);
});

class InventoryNotifier extends StateNotifier<AsyncValue<List<ItemEntity>>> {
  final InventoryRepository repository;

  InventoryNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadItems();
  }

  Future<void> loadItems() async {
    state = const AsyncValue.loading();
    final result = await repository.getItems();
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (items) => state = AsyncValue.data(items),
    );
  }

  Future<void> addItem(ItemEntity item) async {
    final result = await repository.addItem(item);
    result.fold(
      (failure) => null, // Handle error
      (_) => loadItems(),
    );
  }
}

final officerListProvider = StateNotifierProvider<OfficerNotifier, AsyncValue<List<OfficerEntity>>>((ref) {
  final repository = ref.watch(officerRepositoryProvider);
  return OfficerNotifier(repository);
});

final purchaseSuggestionsProvider = FutureProvider<List<PurchaseSuggestionEntity>>((ref) async {
  final repository = ref.watch(inventoryRepositoryProvider);
  final useCase = GetPurchaseSuggestions(repository);
  final result = await useCase.call(NoParams());
  return result.fold(
    (failure) => throw failure,
    (suggestions) => suggestions,
  );
});

final costPerOfficerProvider = FutureProvider.family<double, CostParams>((ref, params) async {
  final repository = ref.watch(officerRepositoryProvider);
  final useCase = CalculateCostPerOfficer(repository);
  final result = await useCase.call(params);
  return result.fold(
    (failure) => throw failure,
    (cost) => cost,
  );
});

final itemHistoryProvider = FutureProvider.family<List<dynamic>, String>((ref, itemId) async {
  final repository = ref.watch(inventoryRepositoryProvider);
  final stockEntries = await repository.getStockEntries(itemId);
  final deductionEntries = await repository.getDeductionEntries(itemId);
  
  List<dynamic> history = [];
  stockEntries.fold((_) => null, (entries) => history.addAll(entries));
  deductionEntries.fold((_) => null, (entries) => history.addAll(entries));
  
  history.sort((a, b) => b.date.compareTo(a.date));
  return history;
});

class OfficerNotifier extends StateNotifier<AsyncValue<List<OfficerEntity>>> {
  final OfficerRepository repository;

  OfficerNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadOfficers();
  }

  Future<void> loadOfficers() async {
    state = const AsyncValue.loading();
    final result = await repository.getOfficers();
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (officers) => state = AsyncValue.data(officers),
    );
  }

  Future<void> addOfficer(OfficerEntity officer) async {
    final result = await repository.addOfficer(officer);
    result.fold(
      (failure) => null,
      (_) => loadOfficers(),
    );
  }
}
