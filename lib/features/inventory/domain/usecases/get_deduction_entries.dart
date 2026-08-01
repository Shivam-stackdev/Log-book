import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:army_mess_inventory/core/error/failures.dart';
import 'package:army_mess_inventory/core/usecases/usecase.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/deduction_entry_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/repositories/inventory_repository.dart';

class GetDeductionEntries extends UseCase<List<DeductionEntryEntity>, GetDeductionEntriesParams> {
  final InventoryRepository repository;

  GetDeductionEntries(this.repository);

  @override
  Future<Either<Failure, List<DeductionEntryEntity>>> call(GetDeductionEntriesParams params) async {
    return await repository.getDeductionEntries(params.itemId);
  }
}

class GetDeductionEntriesParams extends Equatable {
  final String itemId;

  const GetDeductionEntriesParams({required this.itemId});

  @override
  List<Object?> get props => [itemId];
}
