import 'package:equatable/equatable.dart';

class ItemEntity extends Equatable {
  final String id;
  final String name;
  final String unit;
  final double currentStock;
  final double reorderLevel;
  final String category;
  final double unitCost;
  final bool isPreloaded;
  final int usageCount;
  final String? assetKey;

  const ItemEntity({
    required this.id,
    required this.name,
    required this.unit,
    required this.currentStock,
    required this.reorderLevel,
    required this.category,
    this.unitCost = 0,
    this.isPreloaded = false,
    this.usageCount = 0,
    this.assetKey,
  });

  ItemEntity copyWith({
    String? id,
    String? name,
    String? unit,
    double? currentStock,
    double? reorderLevel,
    String? category,
    double? unitCost,
    bool? isPreloaded,
    int? usageCount,
    String? assetKey,
  }) {
    return ItemEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      currentStock: currentStock ?? this.currentStock,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      category: category ?? this.category,
      unitCost: unitCost ?? this.unitCost,
      isPreloaded: isPreloaded ?? this.isPreloaded,
      usageCount: usageCount ?? this.usageCount,
      assetKey: assetKey ?? this.assetKey,
    );
  }

  @override
  List<Object?> get props => [id, name, unit, currentStock, reorderLevel, category, unitCost, isPreloaded, usageCount, assetKey];
}
