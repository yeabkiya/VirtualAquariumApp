import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'aquarium.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }


  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE aquarium(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fishCount INTEGER,
        fishSpeed REAL,
        fishColor TEXT
      )
    ''');
  }

  // Insert settings into the database
  Future<int> saveAquariumSettings(int fishCount, double fishSpeed, String fishColor) async {
    Database db = await database;
    return await db.insert('aquarium', {
      'fishCount': fishCount,
      'fishSpeed': fishSpeed,
      'fishColor': fishColor,
    });
  }

  // Retrieve settings from the database
  Future<Map<String, dynamic>?> getAquariumSettings() async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query('aquarium');
    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  // Delete all settings
  Future<void> clearAquariumSettings() async {
    Database db = await database;
    await db.delete('aquarium');
  }
}