class Flashcard {
  int? id;
  String word;
  String definition;
  String exampleSentence;
  int intervalDays;
  DateTime dueDate;
  double easeFactor;
  int repetitions;

  Flashcard({
    this.id,  // Ensure id is included
    required this.word,
    required this.definition,
    required this.exampleSentence,
    this.intervalDays = 1,
    DateTime? dueDate,
    this.easeFactor = 2.5,
    this.repetitions = 0,
  }) : dueDate = dueDate ?? DateTime.now().add(Duration(days: 1));

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'definition': definition,
      'exampleSentence': exampleSentence,
      'intervalDays': intervalDays,
      'dueDate': dueDate.toIso8601String(),
      'easeFactor': easeFactor,
      'repetitions': repetitions,
    };
  }

  Flashcard.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        word = map['word'],
        definition = map['definition'],
        exampleSentence = map['exampleSentence'],
        intervalDays = map['intervalDays'] ?? 1,
        dueDate = DateTime.parse(map['dueDate'] ?? DateTime.now().toIso8601String()),
        easeFactor = map['easeFactor'] ?? 2.5,
        repetitions = map['repetitions'] ?? 0;
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


