import 'package:equatable/equatable.dart';

class OfficerEntity extends Equatable {
  final String id;
  final String name;
  final String rank;
  final String personalNumber;

  const OfficerEntity({
    required this.id,
    required this.name,
    required this.rank,
    required this.personalNumber,
  });

  String get displayName => '$rank $name';

  @override
  List<Object?> get props => [id, name, rank, personalNumber];
}
