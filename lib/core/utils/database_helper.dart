import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:army_mess_inventory/core/logging/logger.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mesh_management.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: _onOpen,
    );
  }

  Future<void> _onOpen(Database db) async {
    await db.execute('PRAGMA journal_mode=WAL');
    await db.execute('PRAGMA foreign_keys=ON');
    AppLogger.d('Database', 'Opened with WAL mode');
  }

  Future<void> _onCreate(Database db, int version) async {
    AppLogger.i('Database', 'Creating database v$version');
    await _createAllTables(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    AppLogger.i('Database', 'Upgrading from v$oldVersion to v$newVersion');
    if (oldVersion < 2) {
      await _addPartyAndSettingsTables(db);
    }
    if (oldVersion < 3) {
      await _addDeductionDateUniqueness(db);
    }
  }

  Future<void> _createAllTables(Database db) async {
    // Items table
    await db.execute('''
      CREATE TABLE items (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        unit TEXT NOT NULL,
        currentStock REAL NOT NULL DEFAULT 0,
        reorderLevel REAL NOT NULL DEFAULT 0,
        category TEXT NOT NULL,
        rate REAL DEFAULT 0
      )
    ''');
    await db.execute('CREATE INDEX idx_items_category ON items(category)');
    await db.execute('CREATE INDEX idx_items_name ON items(name)');

    // Stock entries (purchases)
    await db.execute('''
      CREATE TABLE stock_entries (
        id TEXT PRIMARY KEY,
        itemId TEXT NOT NULL,
        date TEXT NOT NULL,
        quantity REAL NOT NULL,
        unitPrice REAL NOT NULL,
        supplier TEXT NOT NULL,
        FOREIGN KEY (itemId) REFERENCES items(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX idx_stock_itemId ON stock_entries(itemId)');
    await db.execute('CREATE INDEX idx_stock_date ON stock_entries(date)');

    // Deduction entries
    await db.execute('''
      CREATE TABLE deduction_entries (
        id TEXT PRIMARY KEY,
        itemId TEXT NOT NULL,
        date TEXT NOT NULL,
        quantity REAL NOT NULL,
        reason TEXT NOT NULL,
        FOREIGN KEY (itemId) REFERENCES items(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX idx_deduction_itemId ON deduction_entries(itemId)');
    await db.execute('CREATE INDEX idx_deduction_date ON deduction_entries(date)');
    // Unique constraint: one deduction per item per day
    await db.execute('''
      CREATE UNIQUE INDEX idx_deduction_item_date 
      ON deduction_entries(itemId, date(date))
    ''');

    // Officers
    await db.execute('''
      CREATE TABLE officers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        rank TEXT NOT NULL,
        personalNumber TEXT NOT NULL
      )
    ''');

    // Party entries
    await db.execute('''
      CREATE TABLE party_entries (
        id TEXT PRIMARY KEY,
        officerId TEXT NOT NULL,
        date TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        FOREIGN KEY (officerId) REFERENCES officers(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX idx_party_officerId ON party_entries(officerId)');
    await db.execute('CREATE INDEX idx_party_date ON party_entries(date)');

    // Party items (bar items per entry)
    await db.execute('''
      CREATE TABLE party_items (
        id TEXT PRIMARY KEY,
        partyEntryId TEXT NOT NULL,
        itemName TEXT NOT NULL,
        quantity REAL NOT NULL,
        rate REAL NOT NULL,
        amount REAL NOT NULL,
        unit TEXT NOT NULL,
        FOREIGN KEY (partyEntryId) REFERENCES party_entries(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX idx_party_items_entryId ON party_items(partyEntryId)');

    // Settings
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  Future<void> _addPartyAndSettingsTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS party_entries (
        id TEXT PRIMARY KEY,
        officerId TEXT NOT NULL,
        date TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS party_items (
        id TEXT PRIMARY KEY,
        partyEntryId TEXT NOT NULL,
        itemName TEXT NOT NULL,
        quantity REAL NOT NULL,
        rate REAL NOT NULL,
        amount REAL NOT NULL,
        unit TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  Future<void> _addDeductionDateUniqueness(Database db) async {
    try {
      await db.execute('''
        CREATE UNIQUE INDEX IF NOT EXISTS idx_deduction_item_date 
        ON deduction_entries(itemId, date(date))
      ''');
    } catch (e) {
      AppLogger.w('Database', 'Index already exists or migration not needed');
    }
  }

  // ─── Settings ──────────────────────────────────────────────────────────

  Future<void> updateSetting(String key, String value) async {
    final db = await database;
    await db.insert('settings', {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, String>> getAllSettings() async {
    final db = await database;
    final rows = await db.query('settings');
    return {for (var row in rows) row['key'] as String: row['value'] as String};
  }

  Future<String?> getSetting(String key) async {
    final settings = await getAllSettings();
    return settings[key];
  }

  // ─── Transaction Helper ────────────────────────────────────────────────

  Future<T> runTransaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return await db.transaction((txn) => action(txn));
  }
}
