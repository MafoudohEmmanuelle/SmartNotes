import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBService {
  static Database? _db;
  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }
  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'smart_notes.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE compte(
            id TEXT PRIMARY KEY,
            name TEXT,
            email TEXT,
            photoUrl TEXT
          )
        ''');
      },
    );
  }
  Future<void> enregistrerCompte(Map<String, dynamic> compte) async {
    final database = await db;
    await database.insert(
      "compte",
      compte,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  Future<Map<String, dynamic>?> getCompte() async {

    final database = await db;

    final result = await database.query(
      "compte",
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  Future<void> supprimerCompte() async {

    final database = await db;

    await database.delete("compte");
  }
}