// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import '../models/flashcard.dart';
//
// class DatabaseHelper {
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//
//   factory DatabaseHelper() {
//     return _instance;
//   }
//
//   DatabaseHelper._internal();
//
//   static Database? _database;
//
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }
//
//   // Future<Database> _initDatabase() async {
//   //   String path = join(await getDatabasesPath(), 'flashcards.db');
//   //   return await openDatabase(
//   //     path,
//   //     version: 1,
//   //     onCreate: (db, version) {
//   //       return db.execute(
//   //         'CREATE TABLE flashcards(id INTEGER PRIMARY KEY, word TEXT, definition TEXT, exampleSentence TEXT)',
//   //       );
//   //     },
//   //   );
//   // }
//
//   Future<Database> _initDatabase() async {
//     String path = join(await getDatabasesPath(), 'flashcards.db');
//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: (db, version) {
//         // Create the decks table
//         db.execute(
//           'CREATE TABLE decks(id INTEGER PRIMARY KEY, name TEXT)',
//         );
//
//         // Create the flashcards table with a foreign key to the decks table
//         return db.execute(
//           'CREATE TABLE flashcards(id INTEGER PRIMARY KEY, word TEXT, definition TEXT, exampleSentence TEXT, deck_id INTEGER, FOREIGN KEY(deck_id) REFERENCES decks(id) ON DELETE CASCADE)',
//         );
//       },
//     );
//   }
//
//
//
//   Future<void> insertFlashcard(Flashcard flashcard) async {
//     final db = await database;
//     await db.insert('flashcards', flashcard.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
//   }
//
//   Future<List<Flashcard>> getFlashcards() async {
//     final db = await database;
//     final List<Map<String, dynamic>> maps = await db.query('flashcards');
//     return List.generate(maps.length, (i) {
//       return Flashcard.fromMap(maps[i]);
//     });
//   }
// }


import '../models/flashcard.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
      version: 3, // Ensure the version number is correct
      onCreate: (db, version) async {
        // Create the decks table
        await db.execute(
          'CREATE TABLE decks(id INTEGER PRIMARY KEY, name TEXT)',
        );
        // Create the flashcards table
        await db.execute(
          'CREATE TABLE flashcards(id INTEGER PRIMARY KEY, word TEXT, definition TEXT, exampleSentence TEXT, intervalDays INTEGER, dueDate TEXT, easeFactor REAL, repetitions INTEGER, deck_id INTEGER, FOREIGN KEY(deck_id) REFERENCES decks(id) ON DELETE CASCADE)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE flashcards ADD COLUMN intervalDays INTEGER DEFAULT 1');
          await db.execute('ALTER TABLE flashcards ADD COLUMN dueDate TEXT');
        }
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE flashcards ADD COLUMN easeFactor REAL DEFAULT 2.5');
          await db.execute('ALTER TABLE flashcards ADD COLUMN repetitions INTEGER DEFAULT 0');
        }
        if (oldVersion < 4) {
          // If the decks table was missing, create it during the upgrade
          await db.execute(
            'CREATE TABLE IF NOT EXISTS decks(id INTEGER PRIMARY KEY, name TEXT)',
          );
        }
      },
    );
  }



  Future<int> updateFlashcard(Flashcard flashcard) async {
    final db = await database;
    return await db.update(
      'flashcards',
      flashcard.toMap(),
      where: 'id = ?',
      whereArgs: [flashcard.id],
    );
  }



  Future<int> insertDeck(Deck deck) async {
    final db = await database;
    return await db.insert('decks', deck.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
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
        'deck_id': deckId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertFlashcard(Flashcard flashcard) async {
    final db = await database;
    await db.insert('flashcards', flashcard.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Flashcard>> getDueFlashcards() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final List<Map<String, dynamic>> maps = await db.query(
      'flashcards',
      where: 'dueDate <= ?',
      whereArgs: [now],
    );

    return List.generate(maps.length, (i) {
      return Flashcard.fromMap(maps[i]);
    });
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
      return Deck.fromMap(deckMap, flashcards); // Pass both deckMap and flashcards
    } else {
      return null;
    }
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
}

