import 'package:equatable/equatable.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/item_entity.dart';

class PurchaseSuggestionEntity extends Equatable {
  final ItemEntity item;
  final double suggestedQuantity;
  final String priority; // Low, Medium, High

  const PurchaseSuggestionEntity({
    required this.item,
    required this.suggestedQuantity,
    required this.priority,
  });

  @override
  List<Object?> get props => [item, suggestedQuantity, priority];
}
