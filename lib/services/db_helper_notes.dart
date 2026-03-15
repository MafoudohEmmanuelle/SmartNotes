import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('smart_notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // On passe à la version 2 pour inclure la nouvelle table
    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _onUpgrade);
  }

  Future _createDB(Database db, int version) async {
    // Table Dossiers
    await db.execute('''
      CREATE TABLE dossiers (
        id_dossier TEXT PRIMARY KEY,
        nom TEXT NOT NULL
      )
    ''');

    // Table Notes (Ajout de id_dossier)
    await db.execute('''
      CREATE TABLE notes (
        id_note TEXT PRIMARY KEY,
        titre TEXT NOT NULL,
        contenu TEXT,
        id_dossier TEXT,
        date_creation TEXT,
        statut_synchro INTEGER DEFAULT 0
      )
    ''');
  }

  // Si l'utilisateur a déjà la V1, on ajoute la table dossier sans supprimer ses notes
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('CREATE TABLE dossiers (id_dossier TEXT PRIMARY KEY, nom TEXT NOT NULL)');
      await db.execute('ALTER TABLE notes ADD COLUMN id_dossier TEXT');
    }
  }

  // --- FONCTIONS DOSSIERS ---
  Future<void> insertDossier(Map<String, dynamic> row) async {
    final db = await instance.database;
    // conflictAlgorithm ignore évite de planter si le dossier existe déjà
    await db.insert('dossiers', row, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  // --- FONCTIONS NOTES ---
  Future<void> insertNote(Map<String, dynamic> row) async {
    final db = await instance.database;
    await db.insert('notes', row);
  }

  Future<int> updateNote(Map<String, dynamic> row) async {
    final db = await instance.database;
    String id = row['id_note'];
    return await db.update(
      'notes',
      row,
      where: 'id_note = ?',
      whereArgs: [id],
    );
  }

  /*Future<List<Map<String, dynamic>>> queryAllNotes() async {
    final db = await instance.database;
    return await db.query('notes', orderBy: 'date_creation DESC');
  }*/

  // RÉCUPÉRER LES NOTES AVEC LE NOM DU DOSSIER
  Future<List<Map<String, dynamic>>> queryNotesWithFolderName() async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT notes.*, dossiers.nom AS nom_du_dossier
      FROM notes
      LEFT JOIN dossiers ON notes.id_dossier = dossiers.id_dossier
      ORDER BY notes.date_creation DESC
    ''');
  }
}