import 'package:army_mess_inventory/features/inventory/domain/entities/officer_party_entity.dart';

class OfficerPartyModel extends OfficerPartyEntity {
  const OfficerPartyModel({
    required super.id,
    required super.date,
    required super.officerCount,
    required super.perOfficerCost,
    required super.totalCost,
    super.notes,
  });

  factory OfficerPartyModel.fromMap(Map<String, dynamic> map) {
    return OfficerPartyModel(
      id: map['id'],
      date: DateTime.parse(map['date']),
      officerCount: map['officerCount'] ?? 0,
      perOfficerCost: (map['perOfficerCost'] ?? 0).toDouble(),
      totalCost: (map['totalCost'] ?? 0).toDouble(),
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'officerCount': officerCount,
      'perOfficerCost': perOfficerCost,
      'totalCost': totalCost,
      'notes': notes,
    };
  }

  factory OfficerPartyModel.fromEntity(OfficerPartyEntity entity) {
    return OfficerPartyModel(
      id: entity.id,
      date: entity.date,
      officerCount: entity.officerCount,
      perOfficerCost: entity.perOfficerCost,
      totalCost: entity.totalCost,
      notes: entity.notes,
    );
  }
}
