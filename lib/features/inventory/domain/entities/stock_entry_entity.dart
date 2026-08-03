import 'package:equatable/equatable.dart';

class StockEntryEntity extends Equatable {
  final String id;
  final String itemId;
  final DateTime date;
  final double quantity;
  final double unitPrice;
  final String supplier;

  const StockEntryEntity({
    required this.id,
    required this.itemId,
    required this.date,
    required this.quantity,
    required this.unitPrice,
    required this.supplier,
  });

  double get totalAmount => quantity * unitPrice;

  @override
  List<Object?> get props => [id, itemId, date, quantity, unitPrice, supplier];
}
