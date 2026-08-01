import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:army_mess_inventory/core/error/failures.dart';
import 'package:army_mess_inventory/core/usecases/usecase.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/stock_entry_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/repositories/inventory_repository.dart';

class AddStockEntry extends UseCase<void, AddStockEntryParams> {
  final InventoryRepository repository;

  AddStockEntry(this.repository);

  @override
  Future<Either<Failure, void>> call(AddStockEntryParams params) async {
    return await repository.addStockEntry(params.entry);
  }
}

class AddStockEntryParams extends Equatable {
  final StockEntryEntity entry;

  const AddStockEntryParams({required this.entry});

  @override
  List<Object?> get props => [entry];
}
