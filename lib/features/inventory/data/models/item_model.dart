import 'package:army_mess_inventory/features/inventory/domain/entities/item_entity.dart';

class ItemModel extends ItemEntity {
  const ItemModel({
    required super.id,
    required super.name,
    required super.unit,
    required super.currentStock,
    required super.reorderLevel,
    required super.category,
    super.rate = 0,
  });

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'] as String,
      name: map['name'] as String,
      unit: map['unit'] as String,
      currentStock: (map['currentStock'] as num).toDouble(),
      reorderLevel: (map['reorderLevel'] as num).toDouble(),
      category: map['category'] as String,
      rate: (map['rate'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'unit': unit,
      'currentStock': currentStock,
      'reorderLevel': reorderLevel,
      'category': category,
      'rate': rate,
    };
  }

  factory ItemModel.fromEntity(ItemEntity entity) {
    return ItemModel(
      id: entity.id,
      name: entity.name,
      unit: entity.unit,
      currentStock: entity.currentStock,
      reorderLevel: entity.reorderLevel,
      category: entity.category,
      rate: entity.rate,
    );
  }
}
