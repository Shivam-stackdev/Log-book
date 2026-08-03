import 'package:dartz/dartz.dart';
import 'package:army_mess_inventory/core/error/app_exceptions.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/item_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/deduction_entry_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/stock_entry_entity.dart';

abstract class InventoryRepository {
  // Items
  Future<Either<AppException, List<ItemEntity>>> getItems();
  Future<Either<AppException, ItemEntity>> getItem(String id);
  Future<Either<AppException, void>> addItem(ItemEntity item);
  Future<Either<AppException, void>> updateItem(ItemEntity item);
  Future<Either<AppException, void>> deleteItem(String id);

  // Stock entries
  Future<Either<AppException, List<StockEntryEntity>>> getStockEntries(String itemId);
  Future<Either<AppException, void>> addStockEntry(StockEntryEntity entry);

  // Deductions
  Future<Either<AppException, List<DeductionEntryEntity>>> getDeductionEntries(String itemId);
  Future<Either<AppException, void>> addDeductionEntry(DeductionEntryEntity entry);
  Future<Either<AppException, void>> deleteDeductionEntry(String id);
}
