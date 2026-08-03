import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

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

  String get dateFormatted => DateFormat('dd MMM yyyy').format(date);

  @override
  List<Object?> get props => [id, officerId, date, amount, description];
}

class PartyItemEntity extends Equatable {
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

  @override
  List<Object?> get props => [id, partyEntryId, itemName, quantity, rate, amount, unit];
}
