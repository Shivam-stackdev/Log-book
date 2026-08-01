import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:army_mess_inventory/core/error/failures.dart';
import 'package:army_mess_inventory/core/usecases/usecase.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/item_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/repositories/inventory_repository.dart';

class GetItem extends UseCase<ItemEntity, GetItemParams> {
  final InventoryRepository repository;

  GetItem(this.repository);

  @override
  Future<Either<Failure, ItemEntity>> call(GetItemParams params) async {
    return await repository.getItem(params.id);
  }
}

class GetItemParams extends Equatable {
  final String id;

  const GetItemParams({required this.id});

  @override
  List<Object?> get props => [id];
}
