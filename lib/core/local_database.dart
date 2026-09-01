import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  LocalDatabase._();

  static final LocalDatabase instance = LocalDatabase._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final basePath = await getDatabasesPath();
    final path = p.join(basePath, 'coutelya.db');
    _database = await openDatabase(
      path,
      version: 3,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return _database!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE clients (
        id TEXT PRIMARY KEY,
        workshop_id TEXT,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        phone TEXT,
        whatsapp TEXT,
        email TEXT,
        gender TEXT,
        address TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT,
        sync_status TEXT NOT NULL DEFAULT 'pending'
      )
    ''');

    await db.execute('''
      CREATE TABLE measurements (
        id TEXT PRIMARY KEY,
        client_id TEXT NOT NULL,
        workshop_id TEXT,
        category TEXT NOT NULL,
        values_json TEXT NOT NULL,
        taken_at TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT,
        sync_status TEXT NOT NULL DEFAULT 'pending',
        FOREIGN KEY(client_id) REFERENCES clients(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        client_id TEXT NOT NULL,
        workshop_id TEXT,
        reference TEXT NOT NULL,
        garment_type TEXT NOT NULL,
        description TEXT,
        fabric TEXT,
        color TEXT,
        total_amount REAL NOT NULL DEFAULT 0,
        order_date TEXT,
        delivery_date TEXT,
        fitting_date TEXT,
        status TEXT NOT NULL DEFAULT 'registered',
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT,
        sync_status TEXT NOT NULL DEFAULT 'pending',
        FOREIGN KEY(client_id) REFERENCES clients(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE payments (
        id TEXT PRIMARY KEY,
        order_id TEXT NOT NULL,
        workshop_id TEXT,
        amount REAL NOT NULL,
        payment_method TEXT NOT NULL,
        paid_at TEXT NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT,
        sync_status TEXT NOT NULL DEFAULT 'pending',
        FOREIGN KEY(order_id) REFERENCES orders(id)
      )
    ''');

    await db.execute('CREATE INDEX idx_clients_name ON clients(last_name, first_name)');
    await db.execute('CREATE INDEX idx_orders_delivery ON orders(delivery_date)');
    await db.execute('CREATE INDEX idx_orders_status ON orders(status)');
    await db.execute('CREATE INDEX idx_payments_order ON payments(order_id)');
    await db.execute('CREATE TABLE workshop_settings (key TEXT PRIMARY KEY, value TEXT NOT NULL, updated_at TEXT NOT NULL)');
    await db.insert('workshop_settings', {'key': 'name', 'value': 'Atelier Élégance', 'updated_at': DateTime.now().toIso8601String()});
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _try(db, 'ALTER TABLE clients ADD COLUMN email TEXT');
      await _try(db, 'ALTER TABLE orders ADD COLUMN fabric TEXT');
      await _try(db, 'ALTER TABLE orders ADD COLUMN color TEXT');
      await _try(db, 'ALTER TABLE orders ADD COLUMN order_date TEXT');
      await _try(db, 'ALTER TABLE orders ADD COLUMN notes TEXT');
      await _try(db, 'CREATE INDEX idx_payments_order ON payments(order_id)');
    }
    if (oldVersion < 3) {
      await _try(db, "CREATE TABLE workshop_settings (key TEXT PRIMARY KEY, value TEXT NOT NULL, updated_at TEXT NOT NULL)");
      await _try(db, "INSERT INTO workshop_settings (key, value, updated_at) VALUES ('name', 'Atelier Élégance', '${DateTime.now().toIso8601String()}')");
    }
  }

  Future<void> _try(Database db, String sql) async {
    try {
      await db.execute(sql);
    } catch (_) {
      // Migration idempotente : la colonne ou l'index existe déjà.
    }
  }
}
