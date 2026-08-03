import 'package:army_mess_inventory/features/inventory/domain/entities/party_item_entity.dart';

class PartyItemModel extends PartyItemEntity {
  const PartyItemModel({
    required super.id,
    required super.partyId,
    required super.itemId,
    required super.itemName,
    required super.quantity,
    required super.rate,
    required super.amount,
  });

  factory PartyItemModel.fromMap(Map<String, dynamic> map) {
    return PartyItemModel(
      id: map['id'],
      partyId: map['partyId'],
      itemId: map['itemId'],
      itemName: map['itemName'] ?? '',
      quantity: (map['quantity'] ?? 0).toDouble(),
      rate: (map['rate'] ?? 0).toDouble(),
      amount: (map['amount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'partyId': partyId,
      'itemId': itemId,
      'itemName': itemName,
      'quantity': quantity,
      'rate': rate,
      'amount': amount,
    };
  }

  factory PartyItemModel.fromEntity(PartyItemEntity entity) {
    return PartyItemModel(
      id: entity.id,
      partyId: entity.partyId,
      itemId: entity.itemId,
      itemName: entity.itemName,
      quantity: entity.quantity,
      rate: entity.rate,
      amount: entity.amount,
    );
  }
}
