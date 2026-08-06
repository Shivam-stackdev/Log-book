import 'package:army_mess_inventory/features/inventory/domain/entities/item_entity.dart';

class ItemModel extends ItemEntity {
  const ItemModel({
    required super.id,
    required super.name,
    required super.unit,
    required super.currentStock,
    required super.reorderLevel,
    required super.category,
    super.unitCost = 0,
    super.isPreloaded = false,
    super.usageCount = 0,
    super.assetKey,
  });

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'],
      name: map['name'],
      unit: map['unit'],
      currentStock: (map['currentStock'] ?? 0).toDouble(),
      reorderLevel: (map['reorderLevel'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      unitCost: (map['unitCost'] ?? 0).toDouble(),
      isPreloaded: (map['isPreloaded'] ?? 0) == 1,
      usageCount: (map['usageCount'] ?? 0) as int,
      assetKey: map['assetKey'],
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
      'unitCost': unitCost,
      'isPreloaded': isPreloaded ? 1 : 0,
      'usageCount': usageCount,
      'assetKey': assetKey,
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
      unitCost: entity.unitCost,
      isPreloaded: entity.isPreloaded,
      usageCount: entity.usageCount,
      assetKey: entity.assetKey,
    );
  }
}
