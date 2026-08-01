import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:army_mess_inventory/core/error/failures.dart';
import 'package:army_mess_inventory/core/usecases/usecase.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/deduction_entry_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/repositories/inventory_repository.dart';

class AddDeductionEntry extends UseCase<void, AddDeductionEntryParams> {
  final InventoryRepository repository;

  AddDeductionEntry(this.repository);

  @override
  Future<Either<Failure, void>> call(AddDeductionEntryParams params) async {
    return await repository.addDeductionEntry(params.entry);
  }
}

class AddDeductionEntryParams extends Equatable {
  final DeductionEntryEntity entry;

  const AddDeductionEntryParams({required this.entry});

  @override
  List<Object?> get props => [entry];
}
