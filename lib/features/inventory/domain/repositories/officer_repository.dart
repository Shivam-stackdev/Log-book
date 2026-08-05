import 'package:dartz/dartz.dart';
import 'package:army_mess_inventory/core/error/app_exceptions.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/officer_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/party_entry_entity.dart';
// PartyItemEntity is defined in party_entry_entity.dart

abstract class OfficerRepository {
  Future<Either<AppException, List<OfficerEntity>>> getOfficers();
  Future<Either<AppException, void>> addOfficer(OfficerEntity officer);
  Future<Either<AppException, void>> updateOfficer(OfficerEntity officer);
  Future<Either<AppException, void>> deleteOfficer(String id);
  Future<Either<AppException, void>> addPartyEntry(PartyEntryEntity entry);
  Future<Either<AppException, List<PartyEntryEntity>>> getPartyEntries(String officerId);
  Future<Either<AppException, double>> getTotalPartyCost(DateTime start, DateTime end);
  Future<Either<AppException, List<PartyItemEntity>>> getPartyItems(String partyEntryId);
  Future<Either<AppException, void>> addPartyItem(PartyItemEntity item);
}
