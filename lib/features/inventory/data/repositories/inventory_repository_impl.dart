import 'package:dartz/dartz.dart';
import 'package:army_mess_inventory/core/error/failures.dart';
import 'package:army_mess_inventory/core/utils/database_helper.dart';
import 'package:army_mess_inventory/features/inventory/data/models/item_model.dart';
import 'package:army_mess_inventory/features/inventory/data/models/transaction_model.dart';
import 'package:army_mess_inventory/features/inventory/data/models/officer_party_model.dart';
import 'package:army_mess_inventory/features/inventory/data/models/party_item_model.dart';
import 'package:army_mess_inventory/features/inventory/data/models/stock_order_model.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/item_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/transaction_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/officer_party_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/party_item_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/stock_order_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/repositories/inventory_repository.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final DatabaseHelper dbHelper;

  InventoryRepositoryImpl(this.dbHelper);

  // ─── Items ───────────────────────────────────────────

  @override
  Future<Either<Failure, List<ItemEntity>>> getItems() async {
    try {
      final db = await dbHelper.database;
      final result = await db.query('items', orderBy: 'usageCount DESC, name COLLATE NOCASE ASC');
      return Right(result.map((json) => ItemModel.fromMap(json)).toList());
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, ItemEntity>> getItem(String id) async {
    try {
      final db = await dbHelper.database;
      final result = await db.query('items', where: 'id = ?', whereArgs: [id]);
      if (result.isNotEmpty) {
        return Right(ItemModel.fromMap(result.first));
      }
      return Left(DatabaseFailure());
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
      await db.update('items', model.toMap(), where: 'id = ?', whereArgs: [item.id]);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteItem(String id) async {
    try {
      final db = await dbHelper.database;
      final deletedRows = await db.delete('items', where: 'id = ? AND isPreloaded = 0', whereArgs: [id]);
      if (deletedRows != 1) {
        throw StateError('Preloaded inventory assets cannot be deleted');
      }
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  // ─── Transactions ────────────────────────────────────

  Future<void> _insertAndApplyTransaction(dynamic txn, TransactionEntity transaction) async {
    final model = TransactionModel.fromEntity(transaction);
    await txn.insert('transactions', model.toMap());

    int updatedRows;
    if (transaction.type == 'addition') {
      updatedRows = await txn.rawUpdate(
        'UPDATE items SET currentStock = currentStock + ?, unitCost = ?, usageCount = usageCount + 1 WHERE id = ?',
        [transaction.quantity, transaction.unitPrice, transaction.itemId],
      );
    } else {
      // Deduction/party transactions must update the stock row atomically.
      // If no row is affected, rollback the transaction instead of showing
      // success while the inventory quantity stays unchanged.
      updatedRows = await txn.rawUpdate(
        'UPDATE items SET currentStock = currentStock - ?, usageCount = usageCount + 1 WHERE id = ? AND currentStock >= ?',
        [transaction.quantity, transaction.itemId, transaction.quantity],
      );
    }

    if (updatedRows != 1) {
      throw StateError('Stock update failed for item ${transaction.itemId}');
    }
  }

  @override
  Future<Either<Failure, void>> addTransaction(TransactionEntity transaction) async {
    try {
      final db = await dbHelper.database;
      await db.transaction((txn) async {
        await _insertAndApplyTransaction(txn, transaction);
      });
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, void>> addTransactions(List<TransactionEntity> transactions) async {
    if (transactions.isEmpty) return const Right(null);

    try {
      final db = await dbHelper.database;
      await db.transaction((txn) async {
        for (final transaction in transactions) {
          await _insertAndApplyTransaction(txn, transaction);
        }
      });
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions({
    String? itemId,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final db = await dbHelper.database;
      String where = '1=1';
      List<dynamic> args = [];

      if (itemId != null) {
        where += ' AND itemId = ?';
        args.add(itemId);
      }
      if (type != null) {
        where += ' AND type = ?';
        args.add(type);
      }
      if (startDate != null) {
        where += ' AND date >= ?';
        args.add(startDate.toIso8601String());
      }
      if (endDate != null) {
        where += ' AND date <= ?';
        args.add(endDate.toIso8601String());
      }

      final result = await db.query(
        'transactions',
        where: where,
        whereArgs: args,
        orderBy: 'date DESC',
      );
      return Right(result.map((json) => TransactionModel.fromMap(json)).toList());
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTodayTransactions() async {
    try {
      final db = await dbHelper.database;
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      final result = await db.query(
        'transactions',
        where: 'date >= ? AND date < ?',
        whereArgs: [todayStart.toIso8601String(), todayEnd.toIso8601String()],
        orderBy: 'date DESC',
      );
      return Right(result.map((json) => TransactionModel.fromMap(json)).toList());
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getMonthTransactions(int year, int month) async {
    try {
      final db = await dbHelper.database;
      final monthStart = DateTime(year, month, 1);
      final monthEnd = DateTime(year, month + 1, 1);

      final result = await db.query(
        'transactions',
        where: 'date >= ? AND date < ?',
        whereArgs: [monthStart.toIso8601String(), monthEnd.toIso8601String()],
        orderBy: 'date DESC',
      );
      return Right(result.map((json) => TransactionModel.fromMap(json)).toList());
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  // ─── Officer Parties ─────────────────────────────────

  @override
  Future<Either<Failure, void>> addOfficerParty(
    OfficerPartyEntity party,
    List<PartyItemEntity> items,
  ) async {
    try {
      final db = await dbHelper.database;
      final partyModel = OfficerPartyModel.fromEntity(party);

      await db.transaction((txn) async {
        await txn.insert('officer_parties', partyModel.toMap());

        for (final item in items) {
          final itemModel = PartyItemModel.fromEntity(item);
          await txn.insert('party_items', itemModel.toMap());

          // Auto-deduct stock and record transaction
          final updatedRows = await txn.rawUpdate(
            'UPDATE items SET currentStock = currentStock - ?, usageCount = usageCount + 1 WHERE id = ? AND currentStock >= ?',
            [item.quantity, item.itemId, item.quantity],
          );
          if (updatedRows != 1) {
            throw StateError('Stock update failed for item ${item.itemId}');
          }

          // Create a party transaction
          final txModel = TransactionModel(
            id: '${party.id}_${item.itemId}',
            itemId: item.itemId,
            itemName: item.itemName,
            quantity: item.quantity,
            type: 'party',
            reason: 'Officer Party - ${party.officerCount} officers',
            date: party.date,
            cost: item.amount,
            unitPrice: item.rate,
          );
          await txn.insert('transactions', txModel.toMap());
        }
      });

      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, List<OfficerPartyEntity>>> getOfficerParties() async {
    try {
      final db = await dbHelper.database;
      final result = await db.query('officer_parties', orderBy: 'date DESC');
      return Right(result.map((json) => OfficerPartyModel.fromMap(json)).toList());
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, List<PartyItemEntity>>> getPartyItems(String partyId) async {
    try {
      final db = await dbHelper.database;
      final result = await db.query('party_items', where: 'partyId = ?', whereArgs: [partyId]);
      return Right(result.map((json) => PartyItemModel.fromMap(json)).toList());
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  // ─── Stock Orders ────────────────────────────────────

  @override
  Future<Either<Failure, void>> addStockOrder(StockOrderEntity order) async {
    try {
      final db = await dbHelper.database;
      final model = StockOrderModel.fromEntity(order);
      await db.insert('stock_orders', model.toMap());
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, List<StockOrderEntity>>> getStockOrders({
    String? type,
    bool? isFulfilled,
  }) async {
    try {
      final db = await dbHelper.database;
      String where = '1=1';
      List<dynamic> args = [];

      if (type != null) {
        where += ' AND type = ?';
        args.add(type);
      }
      if (isFulfilled != null) {
        where += ' AND isFulfilled = ?';
        args.add(isFulfilled ? 1 : 0);
      }

      final result = await db.query(
        'stock_orders',
        where: where,
        whereArgs: args,
        orderBy: 'orderDate DESC',
      );
      return Right(result.map((json) => StockOrderModel.fromMap(json)).toList());
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, void>> fulfillOrder(String orderId) async {
    try {
      final db = await dbHelper.database;
      await db.update(
        'stock_orders',
        {'isFulfilled': 1},
        where: 'id = ?',
        whereArgs: [orderId],
      );
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }
}
