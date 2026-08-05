import 'package:dartz/dartz.dart';
import 'package:army_mess_inventory/core/error/app_exceptions.dart';
import 'package:army_mess_inventory/core/logging/logger.dart';
import 'package:army_mess_inventory/core/utils/database_helper.dart';
import 'package:army_mess_inventory/features/inventory/data/models/item_model.dart';
import 'package:army_mess_inventory/features/inventory/data/models/deduction_entry_model.dart';
import 'package:army_mess_inventory/features/inventory/data/models/stock_entry_model.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/item_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/deduction_entry_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/stock_entry_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:army_mess_inventory/features/inventory/data/services/inventory_validator.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final DatabaseHelper dbHelper;

  InventoryRepositoryImpl(this.dbHelper);

  // ─── Items ─────────────────────────────────────────────────────────────

  @override
  Future<Either<AppException, List<ItemEntity>>> getItems() async {
    try {
      final db = await dbHelper.database;
      final result = await db.query('items', orderBy: 'name ASC');
      return Right(result.map((json) => ItemModel.fromMap(json)).toList());
    } catch (e) {
      AppLogger.e('InventoryRepo', 'Failed to get items', e);
      return Left(DatabaseException(message: 'Failed to load items'));
    }
  }

  @override
  Future<Either<AppException, ItemEntity>> getItem(String id) async {
    try {
      final db = await dbHelper.database;
      final result = await db.query('items', where: 'id = ?', whereArgs: [id]);
      if (result.isEmpty) {
        return Left(ValidationException(message: 'Item not found'));
      }
      return Right(ItemModel.fromMap(result.first));
    } catch (e) {
      AppLogger.e('InventoryRepo', 'Failed to get item', e);
      return Left(DatabaseException(message: 'Failed to load item'));
    }
  }

  @override
  Future<Either<AppException, void>> addItem(ItemEntity item) async {
    try {
      InventoryValidator.validateName(item.name);
      InventoryValidator.validateUnit(item.unit);
      InventoryValidator.validateCategory(item.category);
      InventoryValidator.validateReorderLevel(item.reorderLevel);

      final db = await dbHelper.database;
      final existing = await db.query('items',
          where: 'LOWER(name) = ?', whereArgs: [item.name.toLowerCase()]);
      if (existing.isNotEmpty) {
        return Left(const DuplicateException(
            message: 'An item with this name already exists'));
      }

      await db.insert('items', ItemModel.fromEntity(item).toMap());
      AppLogger.i('InventoryRepo', 'Added item: ${item.name}');
      return const Right(null);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      AppLogger.e('InventoryRepo', 'Failed to add item', e);
      return Left(DatabaseException(message: 'Failed to add item'));
    }
  }

  @override
  Future<Either<AppException, void>> updateItem(ItemEntity item) async {
    try {
      InventoryValidator.validateName(item.name);
      InventoryValidator.validateUnit(item.unit);
      InventoryValidator.validateCategory(item.category);

      final db = await dbHelper.database;
      final count = await db.update('items', ItemModel.fromEntity(item).toMap(),
          where: 'id = ?', whereArgs: [item.id]);
      if (count == 0) {
        return Left(ValidationException(message: 'Item not found or no changes'));
      }
      AppLogger.i('InventoryRepo', 'Updated item: ${item.name}');
      return const Right(null);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      AppLogger.e('InventoryRepo', 'Failed to update item', e);
      return Left(DatabaseException(message: 'Failed to update item'));
    }
  }

  @override
  Future<Either<AppException, void>> deleteItem(String id) async {
    try {
      final db = await dbHelper.database;
      await db.delete('items', where: 'id = ?', whereArgs: [id]);
      AppLogger.i('InventoryRepo', 'Deleted item: $id');
      return const Right(null);
    } catch (e) {
      AppLogger.e('InventoryRepo', 'Failed to delete item', e);
      return Left(DatabaseException(message: 'Failed to delete item'));
    }
  }

  // ─── Stock Entries ─────────────────────────────────────────────────────

  @override
  Future<Either<AppException, List<StockEntryEntity>>> getStockEntries(String itemId) async {
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
      AppLogger.e('InventoryRepo', 'Failed to get stock entries', e);
      return Left(DatabaseException(message: 'Failed to load stock entries'));
    }
  }

  @override
  Future<Either<AppException, void>> addStockEntry(StockEntryEntity entry) async {
    try {
      final db = await dbHelper.database;
      await db.transaction((txn) async {
        await txn.insert('stock_entries', StockEntryModel.fromEntity(entry).toMap());
        final item = await txn.query('items', where: 'id = ?', whereArgs: [entry.itemId]);
        if (item.isNotEmpty) {
          final currentStock = (item.first['currentStock'] as num).toDouble();
          await txn.update(
            'items',
            {'currentStock': currentStock + entry.quantity},
            where: 'id = ?',
            whereArgs: [entry.itemId],
          );
        }
      });
      AppLogger.i('InventoryRepo', 'Stock entry added: +${entry.quantity}');
      return const Right(null);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      AppLogger.e('InventoryRepo', 'Failed to add stock entry', e);
      return Left(DatabaseException(message: 'Failed to add stock entry'));
    }
  }

  // ─── Deductions ────────────────────────────────────────────────────────

  @override
  Future<Either<AppException, List<DeductionEntryEntity>>> getDeductionEntries(String itemId) async {
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
      AppLogger.e('InventoryRepo', 'Failed to get deduction entries', e);
      return Left(DatabaseException(message: 'Failed to load deduction entries'));
    }
  }

  @override
  Future<Either<AppException, void>> addDeductionEntry(DeductionEntryEntity entry) async {
    try {
      final db = await dbHelper.database;
      await db.transaction((txn) async {
        // Check for duplicate deduction on same date for same item
        final existing = await txn.rawQuery(
          'SELECT id FROM deduction_entries WHERE itemId = ? AND date(date) = date(?)',
          [entry.itemId, entry.date.toIso8601String()],
        );
        if (existing.isNotEmpty) {
          throw const DeductionException(
            message: 'Daily deduction for this date has already been completed.',
            details: 'Use Undo to modify the existing deduction.',
          );
        }

        // Get current stock
        final item = await txn.query('items', where: 'id = ?', whereArgs: [entry.itemId]);
        if (item.isEmpty) {
          throw const ValidationException(message: 'Item not found');
        }
        final currentStock = (item.first['currentStock'] as num).toDouble();

        // Validate sufficient stock
        InventoryValidator.validateSufficientStock(
          currentStock, entry.quantity, item.first['name'] as String,
        );

        // Insert deduction and update stock atomically
        await txn.insert('deduction_entries', DeductionEntryModel.fromEntity(entry).toMap());
        await txn.update(
          'items',
          {'currentStock': currentStock - entry.quantity},
          where: 'id = ?',
          whereArgs: [entry.itemId],
        );
      });
      AppLogger.i('InventoryRepo', 'Deduction recorded: -${entry.quantity}');
      return const Right(null);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      AppLogger.e('InventoryRepo', 'Failed to add deduction entry', e);
      return Left(DatabaseException(message: 'Failed to record deduction'));
    }
  }

  @override
  Future<Either<AppException, void>> deleteDeductionEntry(String id) async {
    try {
      final db = await dbHelper.database;
      await db.transaction((txn) async {
        final deduction = await txn.query('deduction_entries',
            where: 'id = ?', whereArgs: [id]);
        if (deduction.isEmpty) {
          throw const ValidationException(message: 'Deduction entry not found');
        }
        final itemId = deduction.first['itemId'] as String;
        final quantity = (deduction.first['quantity'] as num).toDouble();
        final item = await txn.query('items', where: 'id = ?', whereArgs: [itemId]);
        if (item.isNotEmpty) {
          final currentStock = (item.first['currentStock'] as num).toDouble();
          await txn.update(
            'items',
            {'currentStock': currentStock + quantity},
            where: 'id = ?',
            whereArgs: [itemId],
          );
        }
        await txn.delete('deduction_entries', where: 'id = ?', whereArgs: [id]);
      });
      AppLogger.i('InventoryRepo', 'Deduction undone: $id');
      return const Right(null);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      AppLogger.e('InventoryRepo', 'Failed to undo deduction', e);
      return Left(DatabaseException(message: 'Failed to undo deduction'));
    }
  }
}
