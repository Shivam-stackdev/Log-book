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
      id: map['id'],
      officerId: map['officerId'],
      date: DateTime.parse(map['date']),
      amount: map['amount'].toDouble(),
      description: map['description'],
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

  factory PartyEntryModel.fromEntity(PartyEntryEntity entity) {
    return PartyEntryModel(
      id: entity.id,
      officerId: entity.officerId,
      date: entity.date,
      amount: entity.amount,
      description: entity.description,
    );
  }
}
