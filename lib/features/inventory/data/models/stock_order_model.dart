import 'package:army_mess_inventory/features/inventory/domain/entities/stock_order_entity.dart';

class StockOrderModel extends StockOrderEntity {
  const StockOrderModel({
    required super.id,
    required super.orderDate,
    required super.itemName,
    required super.quantity,
    required super.unit,
    super.estimatedCost = 0,
    super.type = 'regular',
    super.isFulfilled = false,
  });

  factory StockOrderModel.fromMap(Map<String, dynamic> map) {
    return StockOrderModel(
      id: map['id'],
      orderDate: DateTime.parse(map['orderDate']),
      itemName: map['itemName'] ?? '',
      quantity: (map['quantity'] ?? 0).toDouble(),
      unit: map['unit'] ?? '',
      estimatedCost: (map['estimatedCost'] ?? 0).toDouble(),
      type: map['type'] ?? 'regular',
      isFulfilled: (map['isFulfilled'] ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderDate': orderDate.toIso8601String(),
      'itemName': itemName,
      'quantity': quantity,
      'unit': unit,
      'estimatedCost': estimatedCost,
      'type': type,
      'isFulfilled': isFulfilled ? 1 : 0,
    };
  }

  factory StockOrderModel.fromEntity(StockOrderEntity entity) {
    return StockOrderModel(
      id: entity.id,
      orderDate: entity.orderDate,
      itemName: entity.itemName,
      quantity: entity.quantity,
      unit: entity.unit,
      estimatedCost: entity.estimatedCost,
      type: entity.type,
      isFulfilled: entity.isFulfilled,
    );
  }
}
