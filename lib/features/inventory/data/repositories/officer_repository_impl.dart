import 'package:dartz/dartz.dart';
import 'package:army_mess_inventory/core/error/failures.dart';
import 'package:army_mess_inventory/core/utils/database_helper.dart';
import 'package:army_mess_inventory/features/inventory/data/models/officer_model.dart';
import 'package:army_mess_inventory/features/inventory/data/models/party_entry_model.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/officer_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/party_entry_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/party_items_entity.dart';
import 'package:army_mess_inventory/features/inventory/domain/repositories/officer_repository.dart';

class OfficerRepositoryImpl implements OfficerRepository {
  final DatabaseHelper dbHelper;

  OfficerRepositoryImpl(this.dbHelper);

  @override
  Future<Either<Failure, List<OfficerEntity>>> getOfficers() async {
    try {
      final db = await dbHelper.database;
      final result = await db.query('officers');
      return Right(result.map((json) => OfficerModel.fromMap(json)).toList());
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, void>> addOfficer(OfficerEntity officer) async {
    try {
      final db = await dbHelper.database;
      final model = OfficerModel.fromEntity(officer);
      await db.insert('officers', model.toMap());
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateOfficer(OfficerEntity officer) async {
    try {
      final db = await dbHelper.database;
      final model = OfficerModel.fromEntity(officer);
      await db.update(
        'officers',
        model.toMap(),
        where: 'id = ?',
        whereArgs: [officer.id],
      );
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteOfficer(String id) async {
    try {
      final db = await dbHelper.database;
      await db.delete(
        'officers',
        where: 'id = ?',
        whereArgs: [id],
      );
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, void>> addPartyEntry(PartyEntryEntity entry) async {
    try {
      final db = await dbHelper.database;
      final model = PartyEntryModel.fromEntity(entry);
      await db.insert('party_entries', model.toMap());
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, List<PartyEntryEntity>>> getPartyEntries(String officerId) async {
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
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, double>> getTotalPartyCost(DateTime start, DateTime end) async {
    try {
      final db = await dbHelper.database;
      final result = await db.rawQuery(
        'SELECT SUM(amount) as total FROM party_entries WHERE date BETWEEN ? AND ?',
        [start.toIso8601String(), end.toIso8601String()],
      );
      return Right(result.first['total'] as double? ?? 0.0);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, List<PartyItemEntity>>> getPartyItems(String partyEntryId) async {
    try {
      final db = await dbHelper.database;
      final result = await db.query(
        'party_items',
        where: 'partyEntryId = ?',
        whereArgs: [partyEntryId],
      );
      return Right(result.map((json) => PartyItemEntity.fromMap(json)).toList());
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }
}
