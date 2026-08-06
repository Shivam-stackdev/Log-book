import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:army_mess_inventory/features/inventory/data/preloaded_inventory_assets.dart';

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
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
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
        unitCost REAL DEFAULT 0,
        assetKey TEXT,
        isPreloaded INTEGER NOT NULL DEFAULT 0,
        usageCount INTEGER NOT NULL DEFAULT 0
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

    await _ensureMetadataAndIndexes(db);
    await _seedPreloadedAssets(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _addColumnIfMissing(db, 'items', 'assetKey', 'TEXT');
      await _addColumnIfMissing(db, 'items', 'isPreloaded', 'INTEGER NOT NULL DEFAULT 0');
      await _addColumnIfMissing(db, 'items', 'usageCount', 'INTEGER NOT NULL DEFAULT 0');
    }

    await _ensureMetadataAndIndexes(db);
    await _seedPreloadedAssets(db);
  }

  Future<void> _ensureMetadataAndIndexes(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_metadata (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_items_category_name ON items(category, name)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_items_usage_name ON items(usageCount DESC, name ASC)');
    await db.execute('CREATE UNIQUE INDEX IF NOT EXISTS idx_items_asset_key ON items(assetKey) WHERE assetKey IS NOT NULL');
  }

  Future<void> _addColumnIfMissing(Database db, String table, String column, String definition) async {
    final columns = await db.rawQuery('PRAGMA table_info($table)');
    final exists = columns.any((row) => row['name'] == column);
    if (!exists) {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $definition');
    }
  }

  Future<void> _seedPreloadedAssets(Database db) async {
    final itemCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM items')) ?? 0;
    final meta = await db.query(
      'app_metadata',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: ['preloaded_assets_initialized'],
      limit: 1,
    );
    final assetsWereInitialized = meta.isNotEmpty && meta.first['value'] == '1';

    // First launch/empty migration receives the complete preloaded catalog.
    // Existing non-empty databases are left untouched unless this device already
    // opted into the seeded catalog, which lets future updates add new assets
    // without duplicating or overwriting user-created inventory.
    if (itemCount > 0 && !assetsWereInitialized) return;

    await db.transaction((txn) async {
      for (final asset in InventoryCatalog.assets) {
        final duplicate = await txn.query(
          'items',
          columns: ['id'],
          where: 'assetKey = ? OR (LOWER(name) = LOWER(?) AND category = ?)',
          whereArgs: [asset.assetKey, asset.name, asset.category],
          limit: 1,
        );
        if (duplicate.isNotEmpty) continue;

        await txn.insert(
          'items',
          {
            'id': 'preloaded_${asset.assetKey}',
            'name': asset.name,
            'unit': asset.unit,
            'category': asset.category,
            'reorderLevel': asset.reorderLevel,
            'currentStock': asset.openingStock,
            'unitCost': 0,
            'assetKey': asset.assetKey,
            'isPreloaded': 1,
            'usageCount': 0,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      await txn.insert(
        'app_metadata',
        {'key': 'preloaded_assets_initialized', 'value': '1'},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
  }
}
