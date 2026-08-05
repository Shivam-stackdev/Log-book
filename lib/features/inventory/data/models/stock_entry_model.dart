import 'package:army_mess_inventory/features/inventory/domain/entities/stock_entry_entity.dart';

class StockEntryModel extends StockEntryEntity {
  const StockEntryModel({
    required super.id,
    required super.itemId,
    required super.date,
    required super.quantity,
    required super.unitPrice,
    required super.supplier,
  });

  factory StockEntryModel.fromMap(Map<String, dynamic> map) {
    return StockEntryModel(
      id: map['id'] as String,
      itemId: map['itemId'] as String,
      date: DateTime.parse(map['date'] as String),
      quantity: (map['quantity'] as num).toDouble(),
      unitPrice: (map['unitPrice'] as num).toDouble(),
      supplier: map['supplier'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemId': itemId,
      'date': date.toIso8601String(),
      'quantity': quantity,
      'unitPrice': unitPrice,
      'supplier': supplier,
    };
  }

  factory StockEntryModel.fromEntity(StockEntryEntity entity) {
    return StockEntryModel(
      id: entity.id,
      itemId: entity.itemId,
      date: entity.date,
      quantity: entity.quantity,
      unitPrice: entity.unitPrice,
      supplier: entity.supplier,
    );
  }
}
