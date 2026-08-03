import 'package:equatable/equatable.dart';

/// Unified transaction entity for all stock movements:
/// - 'addition' : stock added
/// - 'deduction' : daily deduction
/// - 'party' : party deduction
class TransactionEntity extends Equatable {
  final String id;
  final String itemId;
  final String itemName;
  final double quantity;
  final String type; // 'addition', 'deduction', 'party'
  final String? reason;
  final DateTime date;
  final double cost;
  final double unitPrice;

  const TransactionEntity({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.type,
    this.reason,
    required this.date,
    this.cost = 0,
    this.unitPrice = 0,
  });

  TransactionEntity copyWith({
    String? id,
    String? itemId,
    String? itemName,
    double? quantity,
    String? type,
    String? reason,
    DateTime? date,
    double? cost,
    double? unitPrice,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      type: type ?? this.type,
      reason: reason ?? this.reason,
      date: date ?? this.date,
      cost: cost ?? this.cost,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }

  @override
  List<Object?> get props => [id, itemId, itemName, quantity, type, reason, date, cost, unitPrice];
}
