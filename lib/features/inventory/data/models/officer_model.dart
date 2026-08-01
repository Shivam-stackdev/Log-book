import 'package:army_mess_inventory/features/inventory/domain/entities/officer_entity.dart';

class OfficerModel extends OfficerEntity {
  const OfficerModel({
    required super.id,
    required super.name,
    required super.rank,
    required super.personalNumber,
  });

  factory OfficerModel.fromMap(Map<String, dynamic> map) {
    return OfficerModel(
      id: map['id'],
      name: map['name'],
      rank: map['rank'],
      personalNumber: map['personalNumber'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'rank': rank,
      'personalNumber': personalNumber,
    };
  }

  factory OfficerModel.fromEntity(OfficerEntity entity) {
    return OfficerModel(
      id: entity.id,
      name: entity.name,
      rank: entity.rank,
      personalNumber: entity.personalNumber,
    );
  }
}
