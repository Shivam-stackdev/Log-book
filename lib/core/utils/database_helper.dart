import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('army_mess.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const doubleType = 'REAL NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE items (
        id $idType,
        name $textType,
        unit $textType,
        currentStock $doubleType,
        reorderLevel $doubleType,
        category $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE stock_entries (
        id $idType,
        itemId $textType,
        date $textType,
        quantity $doubleType,
        unitPrice $doubleType,
        supplier $textType,
        FOREIGN KEY (itemId) REFERENCES items (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE deduction_entries (
        id $idType,
        itemId $textType,
        date $textType,
        quantity $doubleType,
        reason $textType,
        FOREIGN KEY (itemId) REFERENCES items (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE officers (
        id $idType,
        name $textType,
        rank $textType,
        personalNumber $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE party_entries (
        id $idType,
        officerId $textType,
        date $textType,
        amount $doubleType,
        description $textType,
        FOREIGN KEY (officerId) REFERENCES officers (id)
      )
    ''');
    
    await db.execute('''
      CREATE TABLE purchase_records (
        id $idType,
        date $textType,
        totalAmount $doubleType,
        billImagePath $textType,
        ocrText $textType
      )
    ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
