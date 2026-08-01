import 'package:dartz/dartz.dart';
import 'package:army_mess_inventory/core/error/failures.dart';
import 'package:army_mess_inventory/core/usecases/usecase.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/item_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/repositories/inventory_repository.dart';

class GetItems extends UseCase<List<ItemEntity>, NoParams> {
  final InventoryRepository repository;

  GetItems(this.repository);

  @override
  Future<Either<Failure, List<ItemEntity>>> call(NoParams params) async {
    return await repository.getItems();
  }
}
