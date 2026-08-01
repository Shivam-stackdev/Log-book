import 'package:equatable/equatable.dart';

class DeductionEntryEntity extends Equatable {
  final String id;
  final String itemId;
  final DateTime date;
  final double quantity;
  final String reason;

  const DeductionEntryEntity({
    required this.id,
    required this.itemId,
    required this.date,
    required this.quantity,
    required this.reason,
  });

  @override
  List<Object?> get props => [id, itemId, date, quantity, reason];
}
