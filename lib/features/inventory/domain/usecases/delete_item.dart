import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:army_mess_inventory/core/error/failures.dart';
import 'package:army_mess_inventory/core/usecases/usecase.dart';
import 'package:army_mess_inventory/features/inventory/domain/repositories/inventory_repository.dart';

class DeleteItem extends UseCase<void, DeleteItemParams> {
  final InventoryRepository repository;

  DeleteItem(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteItemParams params) async {
    return await repository.deleteItem(params.id);
  }
}

class DeleteItemParams extends Equatable {
  final String id;

  const DeleteItemParams({required this.id});

  @override
  List<Object?> get props => [id];
}
