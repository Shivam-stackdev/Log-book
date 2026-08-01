import 'package:equatable/equatable.dart';

class PartyEntryEntity extends Equatable {
  final String id;
  final String officerId;
  final DateTime date;
  final double amount;
  final String description;

  const PartyEntryEntity({
    required this.id,
    required this.officerId,
    required this.date,
    required this.amount,
    required this.description,
  });

  @override
  List<Object?> get props => [id, officerId, date, amount, description];
}
