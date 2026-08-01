import 'package:dartz/dartz.dart';
import 'package:army_mess_inventory/core/error/failures.dart';
import 'package:army_mess_inventory/core/utils/database_helper.dart';
import 'package:army_mess_inventory/features/inventory/data/models/item_model.dart';
import 'package:army_mess_inventory/features/inventory/data/models/stock_entry_model.dart';
import 'package:army_mess_inventory/features/inventory/data/models/deduction_entry_model.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/item_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/stock_entry_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/deduction_entry_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:sqflite/sqflite.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final DatabaseHelper dbHelper;

  InventoryRepositoryImpl(this.dbHelper);

  @override
  Future<Either<Failure, List<ItemEntity>>> getItems() async {
    try {
      final db = await dbHelper.database;
      final result = await db.query('items');
      return Right(result.map((json) => ItemModel.fromMap(json)).toList());
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, ItemEntity>> getItem(String id) async {
    try {
      final db = await dbHelper.database;
      final result = await db.query(
        'items',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (result.isNotEmpty) {
        return Right(ItemModel.fromMap(result.first));
      } else {
        return Left(DatabaseFailure());
      }
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, void>> addItem(ItemEntity item) async {
    try {
      final db = await dbHelper.database;
      final model = ItemModel.fromEntity(item);
      await db.insert('items', model.toMap());
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateItem(ItemEntity item) async {
    try {
      final db = await dbHelper.database;
      final model = ItemModel.fromEntity(item);
      await db.update(
        'items',
        model.toMap(),
        where: 'id = ?',
        whereArgs: [item.id],
      );
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteItem(String id) async {
    try {
      final db = await dbHelper.database;
      await db.delete(
        'items',
        where: 'id = ?',
        whereArgs: [id],
      );
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, void>> addStockEntry(StockEntryEntity entry) async {
    try {
      final db = await dbHelper.database;
      final model = StockEntryModel.fromEntity(entry);
      
      await db.transaction((txn) async {
        await txn.insert('stock_entries', model.toMap());
        // Update item stock
        await txn.execute(
          'UPDATE items SET currentStock = currentStock + ? WHERE id = ?',
          [entry.quantity, entry.itemId],
        );
      });
      
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, List<StockEntryEntity>>> getStockEntries(String itemId) async {
    try {
      final db = await dbHelper.database;
      final result = await db.query(
        'stock_entries',
        where: 'itemId = ?',
        whereArgs: [itemId],
        orderBy: 'date DESC',
      );
      return Right(result.map((json) => StockEntryModel.fromMap(json)).toList());
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, void>> addDeductionEntry(DeductionEntryEntity entry) async {
    try {
      final db = await dbHelper.database;
      final model = DeductionEntryModel.fromEntity(entry);
      
      await db.transaction((txn) async {
        await txn.insert('deduction_entries', model.toMap());
        // Update item stock
        await txn.execute(
          'UPDATE items SET currentStock = currentStock - ? WHERE id = ?',
          [entry.quantity, entry.itemId],
        );
      });
      
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, List<DeductionEntryEntity>>> getDeductionEntries(String itemId) async {
    try {
      final db = await dbHelper.database;
      final result = await db.query(
        'deduction_entries',
        where: 'itemId = ?',
        whereArgs: [itemId],
        orderBy: 'date DESC',
      );
      return Right(result.map((json) => DeductionEntryModel.fromMap(json)).toList());
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateStock(String itemId, double quantity) async {
    try {
      final db = await dbHelper.database;
      await db.update(
        'items',
        {'currentStock': quantity},
        where: 'id = ?',
        whereArgs: [itemId],
      );
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }
}
