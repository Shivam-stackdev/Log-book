import 'package:flutter/foundation.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/officer_party_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/party_item_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/repositories/inventory_repository.dart';

class PartyProvider extends ChangeNotifier {
  final InventoryRepository repository;

  PartyProvider(this.repository) {
    loadParties();
  }

  List<OfficerPartyEntity> _parties = [];
  bool _isLoading = false;
  String? _error;

  List<OfficerPartyEntity> get parties => _parties;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadParties() async {
    _isLoading = true;
    notifyListeners();

    final result = await repository.getOfficerParties();
    result.fold(
      (failure) => _error = 'Failed to load parties',
      (parties) => _parties = parties,
    );
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addParty(OfficerPartyEntity party, List<PartyItemEntity> items) async {
    final result = await repository.addOfficerParty(party, items);
    return result.fold(
      (failure) => false,
      (_) {
        loadParties();
        return true;
      },
    );
  }

  Future<List<PartyItemEntity>> getPartyItems(String partyId) async {
    final result = await repository.getPartyItems(partyId);
    return result.fold(
      (failure) => [],
      (items) => items,
    );
  }
}
