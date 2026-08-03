import 'package:army_mess_inventory/features/inventory/domain/entities/party_entry_entity.dart';

class PartyItemModel extends PartyItemEntity {
  const PartyItemModel({
    required super.id,
    required super.partyEntryId,
    required super.itemName,
    required super.quantity,
    required super.rate,
    required super.amount,
    required super.unit,
  });

  factory PartyItemModel.fromMap(Map<String, dynamic> map) {
    return PartyItemModel(
      id: map['id'] as String,
      partyEntryId: map['partyEntryId'] as String,
      itemName: map['itemName'] as String,
      quantity: (map['quantity'] as num).toDouble(),
      rate: (map['rate'] as num).toDouble(),
      amount: (map['amount'] as num).toDouble(),
      unit: map['unit'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'partyEntryId': partyEntryId,
      'itemName': itemName,
      'quantity': quantity,
      'rate': rate,
      'amount': amount,
      'unit': unit,
    };
  }
}
