import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MyDatabase {
  static Future<void>? _recoverInFlightOrders;
  Database? _database;

  Future<Database> get db async {
    if(_database != null ) return _database!;
    _database = await _initDB();

    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'orders_database.db');

    return await openDatabase(
      path,
      version: 2,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY,
            title TEXT NOT NULL,
            price REAL NOT NULL,
            thumbnail TEXT
          )''');
        await db.execute('''
          CREATE TABLE orders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            total REAL NOT NULL,
            synced INTEGER NOT NULL DEFAULT 0,
            status TEXT NOT NULL DEFAULT 'pending',
            remote_id INTEGER,
            error_message TEXT,
            retryable INTEGER NOT NULL DEFAULT 1
          )''');
        await db.execute('''
          CREATE TABLE order_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            order_id INTEGER NOT NULL,
            product_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            unit_price REAL NOT NULL,
            quantity INTEGER NOT NULL,
            thumbnail TEXT,
            FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
          )''');
        await db.execute('CREATE INDEX idx_items_order ON order_items(order_id)');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            "ALTER TABLE orders ADD COLUMN status TEXT NOT NULL DEFAULT 'pending'",
          );
          await db.execute('ALTER TABLE orders ADD COLUMN remote_id INTEGER');
          await db.execute('ALTER TABLE orders ADD COLUMN error_message TEXT');
          await db.execute(
            'ALTER TABLE orders ADD COLUMN retryable INTEGER NOT NULL DEFAULT 1',
          );
          await db.execute(
            "UPDATE orders SET status = 'confirmedSimulated' WHERE synced = 1",
          );
          await db.execute(
            'ALTER TABLE order_items ADD COLUMN thumbnail TEXT',
          );
        }
      },
      onOpen: (db) async {
        _recoverInFlightOrders ??= db.update(
          'orders',
          {
            'status': 'unknown',
            'error_message':
                'La aplicación se cerró durante el envío; verifica el pedido antes de volver a intentarlo.',
            'retryable': 0,
          },
          where: 'status = ?',
          whereArgs: ['sending'],
        );
        await _recoverInFlightOrders;
      },
    );
  }
}