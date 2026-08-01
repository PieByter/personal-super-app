import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._internal();
  factory LocalDatabase() => _instance;
  LocalDatabase._internal();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'personal_super_app.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Offline transactions
        await db.execute('''
          CREATE TABLE offline_transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount REAL NOT NULL,
            type TEXT NOT NULL,
            description TEXT,
            transaction_date TEXT NOT NULL,
            category_id TEXT,
            payment_method TEXT,
            synced INTEGER DEFAULT 0,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
          )
        ''');

        // Offline habit logs
        await db.execute('''
          CREATE TABLE offline_habit_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            habit_id TEXT NOT NULL,
            log_date TEXT NOT NULL,
            value REAL DEFAULT 1,
            notes TEXT,
            synced INTEGER DEFAULT 0,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
          )
        ''');

        // Daily metrics offline
        await db.execute('''
          CREATE TABLE offline_daily_metrics (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            metric_date TEXT NOT NULL UNIQUE,
            sleep_hours REAL,
            study_hours REAL,
            coding_hours REAL,
            exercise_minutes INTEGER,
            reading_minutes INTEGER,
            screen_time_minutes INTEGER,
            deep_work_hours REAL,
            mood INTEGER,
            energy_level INTEGER,
            notes TEXT,
            synced INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<int> insertOfflineTransaction(Map<String, dynamic> data) async {
    final db = await database;
    return db.insert('offline_transactions', data);
  }

  Future<List<Map<String, dynamic>>> getUnsyncedTransactions() async {
    final db = await database;
    return db.query('offline_transactions', where: 'synced = 0');
  }

  Future<void> markTransactionsSynced(List<int> ids) async {
    final db = await database;
    for (final id in ids) {
      await db.update(
        'offline_transactions',
        {'synced': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<int> insertOfflineHabitLog(Map<String, dynamic> data) async {
    final db = await database;
    return db.insert('offline_habit_logs', data);
  }

  Future<int> insertOfflineDailyMetric(Map<String, dynamic> data) async {
    final db = await database;
    return db.insert(
      'offline_daily_metrics',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
