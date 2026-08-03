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
      id: map['id'] as String,
      name: map['name'] as String,
      rank: map['rank'] as String,
      personalNumber: map['personalNumber'] as String,
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
}
