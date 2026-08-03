import 'package:equatable/equatable.dart';

class StockOrderEntity extends Equatable {
  final String id;
  final DateTime orderDate;
  final String itemName;
  final double quantity;
  final String unit;
  final double estimatedCost;
  final String type; // 'regular' or 'party'
  final bool isFulfilled;

  const StockOrderEntity({
    required this.id,
    required this.orderDate,
    required this.itemName,
    required this.quantity,
    required this.unit,
    this.estimatedCost = 0,
    this.type = 'regular',
    this.isFulfilled = false,
  });

  StockOrderEntity copyWith({
    String? id,
    DateTime? orderDate,
    String? itemName,
    double? quantity,
    String? unit,
    double? estimatedCost,
    String? type,
    bool? isFulfilled,
  }) {
    return StockOrderEntity(
      id: id ?? this.id,
      orderDate: orderDate ?? this.orderDate,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      type: type ?? this.type,
      isFulfilled: isFulfilled ?? this.isFulfilled,
    );
  }

  @override
  List<Object?> get props => [id, orderDate, itemName, quantity, unit, estimatedCost, type, isFulfilled];
}
