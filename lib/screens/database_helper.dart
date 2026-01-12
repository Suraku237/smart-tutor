import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabaseHelper {
  static final LocalDatabaseHelper instance = LocalDatabaseHelper._init();
  static Database? _database;

  LocalDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('user_data.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('CREATE TABLE profile (id INTEGER PRIMARY KEY, path TEXT)');
  }

  Future<void> saveImagePath(String path) async {
    final db = await instance.database;
    // We use id: 1 to always overwrite the same profile slot
    await db.insert('profile', {'id': 1, 'path': path}, 
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getImagePath() async {
    final db = await instance.database;
    final maps = await db.query('profile', where: 'id = ?', whereArgs: [1]);
    if (maps.isNotEmpty) return maps.first['path'] as String;
    return null;
  }
}