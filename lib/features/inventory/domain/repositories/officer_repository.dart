import 'package:dartz/dartz.dart';
import 'package:army_mess_inventory/core/error/failures.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/officer_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/party_entry_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/party_items_entity.dart';

abstract class OfficerRepository {
  Future<Either<Failure, List<OfficerEntity>>> getOfficers();
  Future<Either<Failure, void>> addOfficer(OfficerEntity officer);
  Future<Either<Failure, void>> updateOfficer(OfficerEntity officer);
  Future<Either<Failure, void>> deleteOfficer(String id);
  Future<Either<Failure, void>> addPartyEntry(PartyEntryEntity entry);
  Future<Either<Failure, List<PartyEntryEntity>>> getPartyEntries(String officerId);
  Future<Either<Failure, double>> getTotalPartyCost(DateTime start, DateTime end);
  Future<Either<Failure, List<PartyItemEntity>>> getPartyItems(String partyEntryId);
}
