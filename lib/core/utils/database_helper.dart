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
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const doubleType = 'REAL NOT NULL';
    const intType = 'INTEGER NOT NULL';

    // Items table
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

    // Stock entries table
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

    // Deduction entries table
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

    // Officers table
    await db.execute('''
      CREATE TABLE officers (
        id $idType,
        name $textType,
        rank $textType,
        personalNumber $textType
      )
    ''');

    // Party entries table
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

    // Party items table - stores individual items for each party entry
    await db.execute('''
      CREATE TABLE party_items (
        id $idType,
        partyEntryId $textType,
        itemName $textType,
        quantity $doubleType,
        rate $doubleType,
        amount $doubleType,
        unit $textType,
        FOREIGN KEY (partyEntryId) REFERENCES party_entries (id)
      )
    ''');

    // Purchase records table
    await db.execute('''
      CREATE TABLE purchase_records (
        id $idType,
        date $textType,
        totalAmount $doubleType,
        billImagePath $textType,
        ocrText $textType
      )
    ''');

    // Settings table for app configuration
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Insert default settings
    await db.insert('settings', {'key': 'language', 'value': 'en'});
    await db.insert('settings', {'key': 'ai_api_key', 'value': ''});
    await db.insert('settings', {'key': 'ai_enabled', 'value': 'false'});
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add party_items table
      await db.execute('''
        CREATE TABLE party_items (
          id TEXT PRIMARY KEY,
          partyEntryId TEXT NOT NULL,
          itemName TEXT NOT NULL,
          quantity REAL NOT NULL,
          rate REAL NOT NULL,
          amount REAL NOT NULL,
          unit TEXT NOT NULL,
          FOREIGN KEY (partyEntryId) REFERENCES party_entries (id)
        )
      ''');

      // Add settings table
      await db.execute('''
        CREATE TABLE settings (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        )
      ''');

      // Insert default settings
      await db.insert('settings', {'key': 'language', 'value': 'en'});
      await db.insert('settings', {'key': 'ai_api_key', 'value': ''});
      await db.insert('settings', {'key': 'ai_enabled', 'value': 'false'});
    }
  }

  Future<Map<String, String>> getAllSettings() async {
    final db = await database;
    final result = await db.query('settings');
    return {for (var row in result) row['key'] as String: row['value'] as String};
  }

  Future<void> updateSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
