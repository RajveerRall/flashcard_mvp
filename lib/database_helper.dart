import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'flashcard.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'flashcards.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE flashcards(id INTEGER PRIMARY KEY, word TEXT, definition TEXT, exampleSentence TEXT)',
        );
      },
    );
  }

  Future<void> insertFlashcard(Flashcard flashcard) async {
    final db = await database;
    await db.insert('flashcards', flashcard.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Flashcard>> getFlashcards() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('flashcards');
    return List.generate(maps.length, (i) {
      return Flashcard.fromMap(maps[i]);
    });
  }
}
