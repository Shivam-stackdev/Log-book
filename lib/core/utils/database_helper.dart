import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('army_mess_v2.db');
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
    // Items table
    await db.execute('''
      CREATE TABLE items (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        unit TEXT NOT NULL,
        category TEXT NOT NULL,
        reorderLevel REAL NOT NULL,
        currentStock REAL DEFAULT 0,
        unitCost REAL DEFAULT 0
      )
    ''');

    // Unified transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        itemId TEXT NOT NULL,
        itemName TEXT NOT NULL,
        quantity REAL NOT NULL,
        type TEXT NOT NULL,
        reason TEXT,
        date TEXT NOT NULL,
        cost REAL DEFAULT 0,
        unitPrice REAL DEFAULT 0,
        FOREIGN KEY (itemId) REFERENCES items(id)
      )
    ''');

    // Officer parties table
    await db.execute('''
      CREATE TABLE officer_parties (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        officerCount INTEGER NOT NULL,
        perOfficerCost REAL NOT NULL,
        totalCost REAL NOT NULL,
        notes TEXT
      )
    ''');

    // Party items table
    await db.execute('''
      CREATE TABLE party_items (
        id TEXT PRIMARY KEY,
        partyId TEXT NOT NULL,
        itemId TEXT NOT NULL,
        itemName TEXT NOT NULL,
        quantity REAL NOT NULL,
        rate REAL NOT NULL,
        amount REAL NOT NULL,
        FOREIGN KEY (partyId) REFERENCES officer_parties(id),
        FOREIGN KEY (itemId) REFERENCES items(id)
      )
    ''');

    // Stock orders table
    await db.execute('''
      CREATE TABLE stock_orders (
        id TEXT PRIMARY KEY,
        orderDate TEXT NOT NULL,
        itemName TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit TEXT NOT NULL,
        estimatedCost REAL DEFAULT 0,
        type TEXT NOT NULL DEFAULT 'regular',
        isFulfilled INTEGER DEFAULT 0
      )
    ''');

    // Purchase records (OCR)
    await db.execute('''
      CREATE TABLE purchase_records (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        billImagePath TEXT,
        ocrText TEXT
      )
    ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
