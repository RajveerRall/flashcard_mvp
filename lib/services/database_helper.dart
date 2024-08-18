import 'package:flashcard_mvp/models/flashcard.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


class DatabaseHelper {
  // Singleton pattern for DatabaseHelper
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
      version: 3, // Increment the version if you add new columns like imageUrl
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE decks(id INTEGER PRIMARY KEY, name TEXT)',
        );

        return db.execute(
          'CREATE TABLE flashcards('
              'id INTEGER PRIMARY KEY, '
              'word TEXT, '
              'definition TEXT, '
              'exampleSentence TEXT, '
              'intervalDays INTEGER, '
              'dueDate TEXT, '
              'easeFactor REAL, '
              'repetitions INTEGER, '
              'imageUrl TEXT, ' // Add imageUrl field
              'deck_id INTEGER, '
              'FOREIGN KEY(deck_id) REFERENCES decks(id) ON DELETE CASCADE)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 3) {
          db.execute('ALTER TABLE flashcards ADD COLUMN imageUrl TEXT');
        }
      },
    );
  }

  // Method to insert flashcards in a batch
  Future<void> insertFlashcards(List<Flashcard> flashcards, int deckId) async {
    final db = await database;
    final batch = db.batch();
    for (var flashcard in flashcards) {
      batch.insert(
        'flashcards',
        flashcard.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  // Deck-related methods
  Future<int> insertDeck(Deck deck) async {
    final db = await database;
    // Insert and return the auto-generated ID
    return await db.insert(
      'decks',
      deck.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


  Future<Deck?> getDeckById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> deckMaps = await db.query(
      'decks',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (deckMaps.isNotEmpty) {
      final deckMap = deckMaps.first;
      final List<Flashcard> flashcards = await getFlashcardsByDeckId(deckMap['id']);
      return Deck.fromMap(deckMap, flashcards);
    } else {
      return null;
    }
  }

  Future<Deck?> getDeckByName(String name) async {
    final db = await database;
    final List<Map<String, dynamic>> deckMaps = await db.query(
      'decks',
      where: 'name = ?',
      whereArgs: [name],
    );

    if (deckMaps.isNotEmpty) {
      final deckMap = deckMaps.first;
      final List<Flashcard> flashcards = await getFlashcardsByDeckId(deckMap['id']);
      return Deck.fromMap(deckMap, flashcards);
    } else {
      return null;
    }
  }

  Future<List<Deck>> getAllDecks() async {
    final db = await database;
    final List<Map<String, dynamic>> deckMaps = await db.query('decks');

    List<Deck> decks = [];
    for (var deckMap in deckMaps) {
      final flashcards = await getFlashcardsByDeckId(deckMap['id']);
      decks.add(Deck.fromMap(deckMap, flashcards));
    }
    return decks;
  }

  // Flashcard-related methods
  Future<void> insertFlashcard(Flashcard flashcard) async {
    final db = await database;
    await db.insert('flashcards', flashcard.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertFlashcardWithDeck(Flashcard flashcard, int deckId) async {
    final db = await database;
    await db.insert(
      'flashcards',
      {
        'word': flashcard.word,
        'definition': flashcard.definition,
        'exampleSentence': flashcard.exampleSentence,
        'intervalDays': flashcard.intervalDays,
        'dueDate': flashcard.dueDate.toIso8601String(),
        'easeFactor': flashcard.easeFactor,
        'repetitions': flashcard.repetitions,
        'deck_id': deckId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Flashcard>> getDueFlashcards(int deckId, DateTime now) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'flashcards',
      where: 'deck_id = ? AND dueDate <= ?',
      whereArgs: [deckId, now.toIso8601String()],
    );

    return List.generate(maps.length, (i) {
      return Flashcard.fromMap(maps[i]);
    });
  }


  Future<List<Flashcard>> getFlashcardsByDeckId(int deckId) async {
    final db = await database;
    final List<Map<String, dynamic>> flashcardMaps = await db.query(
      'flashcards',
      where: 'deck_id = ?',
      whereArgs: [deckId],
    );
    return List.generate(flashcardMaps.length, (i) {
      return Flashcard.fromMap(flashcardMaps[i]);
    });
  }

  Future<void> updateFlashcard(Flashcard flashcard) async {
    final db = await database;
    await db.update(
      'flashcards',
      flashcard.toMap(),
      where: 'id = ?',
      whereArgs: [flashcard.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteDeck(int deckId) async {
    final db = await database;
    await db.delete(
      'decks',
      where: 'id = ?',
      whereArgs: [deckId],
    );
  }
}
