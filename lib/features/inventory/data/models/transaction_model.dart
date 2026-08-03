import 'package:army_mess_inventory/features/inventory/domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.itemId,
    required super.itemName,
    required super.quantity,
    required super.type,
    super.reason,
    required super.date,
    super.cost = 0,
    super.unitPrice = 0,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      itemId: map['itemId'],
      itemName: map['itemName'] ?? '',
      quantity: (map['quantity'] ?? 0).toDouble(),
      type: map['type'] ?? 'deduction',
      reason: map['reason'],
      date: DateTime.parse(map['date']),
      cost: (map['cost'] ?? 0).toDouble(),
      unitPrice: (map['unitPrice'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemId': itemId,
      'itemName': itemName,
      'quantity': quantity,
      'type': type,
      'reason': reason,
      'date': date.toIso8601String(),
      'cost': cost,
      'unitPrice': unitPrice,
    };
  }

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      itemId: entity.itemId,
      itemName: entity.itemName,
      quantity: entity.quantity,
      type: entity.type,
      reason: entity.reason,
      date: entity.date,
      cost: entity.cost,
      unitPrice: entity.unitPrice,
    );
  }
}
