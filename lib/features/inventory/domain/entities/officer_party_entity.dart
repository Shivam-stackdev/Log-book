import 'package:equatable/equatable.dart';

class OfficerPartyEntity extends Equatable {
  final String id;
  final DateTime date;
  final int officerCount;
  final double perOfficerCost;
  final double totalCost;
  final String? notes;

  const OfficerPartyEntity({
    required this.id,
    required this.date,
    required this.officerCount,
    required this.perOfficerCost,
    required this.totalCost,
    this.notes,
  });

  OfficerPartyEntity copyWith({
    String? id,
    DateTime? date,
    int? officerCount,
    double? perOfficerCost,
    double? totalCost,
    String? notes,
  }) {
    return OfficerPartyEntity(
      id: id ?? this.id,
      date: date ?? this.date,
      officerCount: officerCount ?? this.officerCount,
      perOfficerCost: perOfficerCost ?? this.perOfficerCost,
      totalCost: totalCost ?? this.totalCost,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [id, date, officerCount, perOfficerCost, totalCost, notes];
}
