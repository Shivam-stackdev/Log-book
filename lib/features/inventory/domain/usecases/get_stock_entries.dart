import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:army_mess_inventory/core/error/failures.dart';
import 'package:army_mess_inventory/core/usecases/usecase.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/stock_entry_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/repositories/inventory_repository.dart';

class GetStockEntries extends UseCase<List<StockEntryEntity>, GetStockEntriesParams> {
  final InventoryRepository repository;

  GetStockEntries(this.repository);

  @override
  Future<Either<Failure, List<StockEntryEntity>>> call(GetStockEntriesParams params) async {
    return await repository.getStockEntries(params.itemId);
  }
}

class GetStockEntriesParams extends Equatable {
  final String itemId;

  const GetStockEntriesParams({required this.itemId});

  @override
  List<Object?> get props => [itemId];
}
