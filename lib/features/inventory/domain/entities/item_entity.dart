import 'package:equatable/equatable.dart';

class ItemEntity extends Equatable {
  final String id;
  final String name;
  final String unit;
  final double currentStock;
  final double reorderLevel;
  final String category;

  const ItemEntity({
    required this.id,
    required this.name,
    required this.unit,
    required this.currentStock,
    required this.reorderLevel,
    required this.category,
  });

  @override
  List<Object?> get props => [id, name, unit, currentStock, reorderLevel, category];
}
