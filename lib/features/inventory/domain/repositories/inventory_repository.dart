import 'package:dartz/dartz.dart';
import 'package:army_mess_inventory/core/error/failures.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/item_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/stock_entry_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/deduction_entry_entity.dart';

abstract class InventoryRepository {
  Future<Either<Failure, List<ItemEntity>>> getItems();
  Future<Either<Failure, ItemEntity>> getItem(String id);
  Future<Either<Failure, void>> addItem(ItemEntity item);
  Future<Either<Failure, void>> updateItem(ItemEntity item);
  Future<Either<Failure, void>> deleteItem(String id);
  Future<Either<Failure, void>> addStockEntry(StockEntryEntity entry);
  Future<Either<Failure, List<StockEntryEntity>>> getStockEntries(String itemId);
  Future<Either<Failure, void>> addDeductionEntry(DeductionEntryEntity entry);
  Future<Either<Failure, List<DeductionEntryEntity>>> getDeductionEntries(String itemId);
  Future<Either<Failure, void>> updateStock(String itemId, double quantity);
}
