import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:army_mess_inventory/core/error/failures.dart';
import 'package:army_mess_inventory/core/usecases/usecase.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/item_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/repositories/inventory_repository.dart';

class UpdateItem extends UseCase<void, UpdateItemParams> {
  final InventoryRepository repository;

  UpdateItem(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateItemParams params) async {
    return await repository.updateItem(params.item);
  }
}

class UpdateItemParams extends Equatable {
  final ItemEntity item;

  const UpdateItemParams({required this.item});

  @override
  List<Object?> get props => [item];
}
