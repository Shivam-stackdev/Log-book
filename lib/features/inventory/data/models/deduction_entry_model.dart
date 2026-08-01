import 'package:army_mess_inventory/features/inventory/domain/entities/deduction_entry_entity.dart';

class DeductionEntryModel extends DeductionEntryEntity {
  const DeductionEntryModel({
    required super.id,
    required super.itemId,
    required super.date,
    required super.quantity,
    required super.reason,
  });

  factory DeductionEntryModel.fromMap(Map<String, dynamic> map) {
    return DeductionEntryModel(
      id: map['id'],
      itemId: map['itemId'],
      date: DateTime.parse(map['date']),
      quantity: map['quantity'].toDouble(),
      reason: map['reason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemId': itemId,
      'date': date.toIso8601String(),
      'quantity': quantity,
      'reason': reason,
    };
  }

  factory DeductionEntryModel.fromEntity(DeductionEntryEntity entity) {
    return DeductionEntryModel(
      id: entity.id,
      itemId: entity.itemId,
      date: entity.date,
      quantity: entity.quantity,
      reason: entity.reason,
    );
  }
}
