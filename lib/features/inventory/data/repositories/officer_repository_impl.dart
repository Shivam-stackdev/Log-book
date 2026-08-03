import 'package:dartz/dartz.dart';
import 'package:army_mess_inventory/core/error/app_exceptions.dart';
import 'package:army_mess_inventory/core/logging/logger.dart';
import 'package:army_mess_inventory/core/utils/database_helper.dart';
import 'package:army_mess_inventory/features/inventory/data/models/officer_model.dart';
import 'package:army_mess_inventory/features/inventory/data/models/party_entry_model.dart';
import 'package:army_mess_inventory/features/inventory/data/models/party_item_model.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/officer_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/party_entry_entity.dart';
// PartyItemEntity is in party_entry_entity.dart
import 'package:army_mess_inventory/features/inventory/domain/repositories/officer_repository.dart';

class OfficerRepositoryImpl implements OfficerRepository {
  final DatabaseHelper dbHelper;

  OfficerRepositoryImpl(this.dbHelper);

  @override
  Future<Either<AppException, List<OfficerEntity>>> getOfficers() async {
    try {
      final db = await dbHelper.database;
      final result = await db.query('officers', orderBy: 'name ASC');
      return Right(result.map((json) => OfficerModel.fromMap(json)).toList());
    } catch (e) {
      AppLogger.e('OfficerRepo', 'Failed to get officers', e);
      return Left(DatabaseException(message: 'Failed to load officers'));
    }
  }

  @override
  Future<Either<AppException, void>> addOfficer(OfficerEntity officer) async {
    try {
      final db = await dbHelper.database;
      await db.insert('officers', OfficerModel.fromMap({
        'id': officer.id,
        'name': officer.name,
        'rank': officer.rank,
        'personalNumber': officer.personalNumber,
      }));
      AppLogger.i('OfficerRepo', 'Added officer: ${officer.name}');
      return const Right(null);
    } catch (e) {
      AppLogger.e('OfficerRepo', 'Failed to add officer', e);
      return Left(DatabaseException(message: 'Failed to add officer'));
    }
  }

  @override
  Future<Either<AppException, void>> updateOfficer(OfficerEntity officer) async {
    try {
      final db = await dbHelper.database;
      await db.update('officers', OfficerModel.fromMap({
        'id': officer.id,
        'name': officer.name,
        'rank': officer.rank,
        'personalNumber': officer.personalNumber,
      }), where: 'id = ?', whereArgs: [officer.id]);
      return const Right(null);
    } catch (e) {
      AppLogger.e('OfficerRepo', 'Failed to update officer', e);
      return Left(DatabaseException(message: 'Failed to update officer'));
    }
  }

  @override
  Future<Either<AppException, void>> deleteOfficer(String id) async {
    try {
      final db = await dbHelper.database;
      await db.delete('officers', where: 'id = ?', whereArgs: [id]);
      return const Right(null);
    } catch (e) {
      AppLogger.e('OfficerRepo', 'Failed to delete officer', e);
      return Left(DatabaseException(message: 'Failed to delete officer'));
    }
  }

  @override
  Future<Either<AppException, void>> addPartyEntry(PartyEntryEntity entry) async {
    try {
      final db = await dbHelper.database;
      await db.insert('party_entries', PartyEntryModel.fromMap({
        'id': entry.id,
        'officerId': entry.officerId,
        'date': entry.date.toIso8601String(),
        'amount': entry.amount,
        'description': entry.description,
      }));
      return const Right(null);
    } catch (e) {
      AppLogger.e('OfficerRepo', 'Failed to add party entry', e);
      return Left(DatabaseException(message: 'Failed to add party entry'));
    }
  }

  @override
  Future<Either<AppException, List<PartyEntryEntity>>> getPartyEntries(String officerId) async {
    try {
      final db = await dbHelper.database;
      final result = await db.query(
        'party_entries',
        where: 'officerId = ?',
        whereArgs: [officerId],
        orderBy: 'date DESC',
      );
      return Right(result.map((json) => PartyEntryModel.fromMap(json)).toList());
    } catch (e) {
      AppLogger.e('OfficerRepo', 'Failed to get party entries', e);
      return Left(DatabaseException(message: 'Failed to load party entries'));
    }
  }

  @override
  Future<Either<AppException, double>> getTotalPartyCost(DateTime start, DateTime end) async {
    try {
      final db = await dbHelper.database;
      final result = await db.rawQuery(
        'SELECT SUM(amount) as total FROM party_entries WHERE date BETWEEN ? AND ?',
        [start.toIso8601String(), end.toIso8601String()],
      );
      return Right(result.first['total'] as double? ?? 0.0);
    } catch (e) {
      AppLogger.e('OfficerRepo', 'Failed to get total party cost', e);
      return Left(DatabaseException(message: 'Failed to calculate party cost'));
    }
  }

  @override
  Future<Either<AppException, List<PartyItemEntity>>> getPartyItems(String partyEntryId) async {
    try {
      final db = await dbHelper.database;
      final result = await db.query(
        'party_items',
        where: 'partyEntryId = ?',
        whereArgs: [partyEntryId],
      );
      return Right(result.map((json) => PartyItemModel.fromMap(json)).toList());
    } catch (e) {
      AppLogger.e('OfficerRepo', 'Failed to get party items', e);
      return Left(DatabaseException(message: 'Failed to load party items'));
    }
  }

  @override
  Future<Either<AppException, void>> addPartyItem(PartyItemEntity item) async {
    try {
      final db = await dbHelper.database;
      await db.insert('party_items', PartyItemModel.fromMap({
        'id': item.id,
        'partyEntryId': item.partyEntryId,
        'itemName': item.itemName,
        'quantity': item.quantity,
        'rate': item.rate,
        'amount': item.amount,
        'unit': item.unit,
      }));
      AppLogger.i('OfficerRepo', 'Added party item: ${item.itemName}');
      return const Right(null);
    } catch (e) {
      AppLogger.e('OfficerRepo', 'Failed to add party item', e);
      return Left(DatabaseException(message: 'Failed to add party item'));
    }
  }
}
