import 'package:dartz/dartz.dart';
import 'package:army_mess_inventory/core/error/failures.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/item_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/transaction_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/officer_party_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/party_item_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/stock_order_entity.dart';

abstract class InventoryRepository {
  // Items
  Future<Either<Failure, List<ItemEntity>>> getItems();
  Future<Either<Failure, ItemEntity>> getItem(String id);
  Future<Either<Failure, void>> addItem(ItemEntity item);
  Future<Either<Failure, void>> updateItem(ItemEntity item);
  Future<Either<Failure, void>> deleteItem(String id);

  // Transactions (unified)
  Future<Either<Failure, void>> addTransaction(TransactionEntity transaction);
  Future<Either<Failure, List<TransactionEntity>>> getTransactions({String? itemId, String? type, DateTime? startDate, DateTime? endDate});
  Future<Either<Failure, List<TransactionEntity>>> getTodayTransactions();
  Future<Either<Failure, List<TransactionEntity>>> getMonthTransactions(int year, int month);

  // Officer Parties
  Future<Either<Failure, void>> addOfficerParty(OfficerPartyEntity party, List<PartyItemEntity> items);
  Future<Either<Failure, List<OfficerPartyEntity>>> getOfficerParties();
  Future<Either<Failure, List<PartyItemEntity>>> getPartyItems(String partyId);

  // Stock Orders
  Future<Either<Failure, void>> addStockOrder(StockOrderEntity order);
  Future<Either<Failure, List<StockOrderEntity>>> getStockOrders({String? type, bool? isFulfilled});
  Future<Either<Failure, void>> fulfillOrder(String orderId);
}
