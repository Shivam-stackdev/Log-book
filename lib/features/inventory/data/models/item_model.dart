import 'package:army_mess_inventory/features/inventory/domain/entities/item_entity.dart';

class ItemModel extends ItemEntity {
  const ItemModel({
    required super.id,
    required super.name,
    required super.unit,
    required super.currentStock,
    required super.reorderLevel,
    required super.category,
  });

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'],
      name: map['name'],
      unit: map['unit'],
      currentStock: map['currentStock'].toDouble(),
      reorderLevel: map['reorderLevel'].toDouble(),
      category: map['category'],
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
    );
  }
}
