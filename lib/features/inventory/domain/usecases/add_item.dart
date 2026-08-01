import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:army_mess_inventory/core/error/failures.dart';
import 'package:army_mess_inventory/core/usecases/usecase.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/item_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/repositories/inventory_repository.dart';

class AddItem extends UseCase<void, AddItemParams> {
  final InventoryRepository repository;

  AddItem(this.repository);

  @override
  Future<Either<Failure, void>> call(AddItemParams params) async {
    return await repository.addItem(params.item);
  }
}

class AddItemParams extends Equatable {
  final ItemEntity item;

  const AddItemParams({required this.item});

  @override
  List<Object?> get props => [item];
}
