import 'package:equatable/equatable.dart';

class BillItem extends Equatable {
  final String name;
  final double quantity;
  final String unit;
  final double rate;
  final double amount;
  final String? matchedItemId;

  const BillItem({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.rate,
    required this.amount,
    this.matchedItemId,
  });

  BillItem copyWith({
    String? name,
    double? quantity,
    String? unit,
    double? rate,
    double? amount,
    String? matchedItemId,
  }) {
    return BillItem(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      rate: rate ?? this.rate,
      amount: amount ?? this.amount,
      matchedItemId: matchedItemId ?? this.matchedItemId,
    );
  }

  @override
  List<Object?> get props => [name, quantity, unit, rate, amount, matchedItemId];
}
