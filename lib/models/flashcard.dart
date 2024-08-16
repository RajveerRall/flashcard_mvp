class Flashcard {
  int? id;
  String word;
  String definition;
  String exampleSentence;
  int intervalDays;
  DateTime dueDate;
  int repetitions; // Number of times the flashcard has been reviewed

  Flashcard({
    this.id,
    required this.word,
    required this.definition,
    required this.exampleSentence,
    this.intervalDays = 1, // Default interval is 1 day
    DateTime? dueDate,     // Default due date is today
    this.repetitions = 0,  // Initialize repetitions to 0
  }) : dueDate = dueDate ?? DateTime.now().add(Duration(days: 1));

  // Convert a Flashcard into a Map.
  Map<String, dynamic> toMap() {
    return {
      'word': word,
      'definition': definition,
      'exampleSentence': exampleSentence,
      'intervalDays': intervalDays,
      'dueDate': dueDate.toIso8601String(),
      'repetitions': repetitions,
    };
  }

  // Convert a Map into a Flashcard.
  Flashcard.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        word = map['word'],
        definition = map['definition'],
        exampleSentence = map['exampleSentence'],
        intervalDays = map['intervalDays'] ?? 1, // Default to 1 if not present
        dueDate = DateTime.parse(map['dueDate'] ?? DateTime.now().toIso8601String()),
        repetitions = map['repetitions'] ?? 0; // Default to 0 if not present
}



class Deck {
  final int id;
  final String name;
  final List<Flashcard> flashcards;

  Deck({required this.id, required this.name, required this.flashcards});

  // Modify the fromMap constructor to accept both deckMap and flashcards
  Deck.fromMap(Map<String, dynamic> deckMap, this.flashcards)
      : id = deckMap['id'],
        name = deckMap['name'];

  // toMap method for saving to the database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}


