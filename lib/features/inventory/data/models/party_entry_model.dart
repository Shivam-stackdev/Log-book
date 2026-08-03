import 'package:army_mess_inventory/features/inventory/domain/entities/party_entry_entity.dart';

class PartyEntryModel extends PartyEntryEntity {
  const PartyEntryModel({
    required super.id,
    required super.officerId,
    required super.date,
    required super.amount,
    required super.description,
  });

  factory PartyEntryModel.fromMap(Map<String, dynamic> map) {
    return PartyEntryModel(
      id: map['id'] as String,
      officerId: map['officerId'] as String,
      date: DateTime.parse(map['date'] as String),
      amount: (map['amount'] as num).toDouble(),
      description: map['description'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'officerId': officerId,
      'date': date.toIso8601String(),
      'amount': amount,
      'description': description,
    };
  }
}
