class PartyItemEntity {
  final String id;
  final String partyEntryId;
  final String itemName;
  final double quantity;
  final double rate;
  final double amount;
  final String unit;

  const PartyItemEntity({
    required this.id,
    required this.partyEntryId,
    required this.itemName,
    required this.quantity,
    required this.rate,
    required this.amount,
    required this.unit,
  });

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

  factory PartyItemEntity.fromMap(Map<String, dynamic> map) {
    return PartyItemEntity(
      id: map['id'] as String,
      partyEntryId: map['partyEntryId'] as String,
      itemName: map['itemName'] as String,
      quantity: map['quantity'] as double,
      rate: map['rate'] as double,
      amount: map['amount'] as double,
      unit: map['unit'] as String,
    );
  }
}
