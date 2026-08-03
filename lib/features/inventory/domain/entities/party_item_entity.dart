import 'package:equatable/equatable.dart';

class PartyItemEntity extends Equatable {
  final String id;
  final String partyId;
  final String itemId;
  final String itemName;
  final double quantity;
  final double rate;
  final double amount;

  const PartyItemEntity({
    required this.id,
    required this.partyId,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.rate,
    required this.amount,
  });

  PartyItemEntity copyWith({
    String? id,
    String? partyId,
    String? itemId,
    String? itemName,
    double? quantity,
    double? rate,
    double? amount,
  }) {
    return PartyItemEntity(
      id: id ?? this.id,
      partyId: partyId ?? this.partyId,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      rate: rate ?? this.rate,
      amount: amount ?? this.amount,
    );
  }

  @override
  List<Object?> get props => [id, partyId, itemId, itemName, quantity, rate, amount];
}
