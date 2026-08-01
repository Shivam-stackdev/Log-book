import 'package:dartz/dartz.dart';
import 'package:army_mess_inventory/core/error/failures.dart';
import 'package:army_mess_inventory/core/usecases/usecase.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/purchase_suggestion_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/repositories/inventory_repository.dart';

class GetPurchaseSuggestions extends UseCase<List<PurchaseSuggestionEntity>, NoParams> {
  final InventoryRepository repository;

  GetPurchaseSuggestions(this.repository);

  @override
  Future<Either<Failure, List<PurchaseSuggestionEntity>>> call(NoParams params) async {
    final result = await repository.getItems();
    
    return result.fold(
      (failure) => Left(failure),
      (items) {
        final suggestions = items
            .where((item) => item.currentStock <= item.reorderLevel)
            .map((item) {
              final deficit = item.reorderLevel - item.currentStock;
              // Suggest double the reorder level or at least a reasonable buffer
              final suggestedQty = deficit + (item.reorderLevel * 0.5);
              
              String priority = 'Low';
              if (item.currentStock == 0) {
                priority = 'High';
              } else if (item.currentStock <= item.reorderLevel * 0.5) {
                priority = 'Medium';
              }

              return PurchaseSuggestionEntity(
                item: item,
                suggestedQuantity: suggestedQty,
                priority: priority,
              );
            }).toList();
        
        return Right(suggestions);
      },
    );
  }
}
