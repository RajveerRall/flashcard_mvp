class Flashcard {
  int? id;
  String word;
  String definition;
  String exampleSentence;
  int intervalDays;
  DateTime dueDate;
  double easeFactor;
  int repetitions;
  String? imageUrl;

  Flashcard({
    this.id,
    required this.word,
    required this.definition,
    required this.exampleSentence,
    this.intervalDays = 1,
    DateTime? dueDate,
    this.easeFactor = 2.5,
    this.repetitions = 0,
    this.imageUrl,
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
      'imageUrl': imageUrl,
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
        repetitions = map['repetitions'] ?? 0,
        imageUrl = map['imageUrl'];
}



class Deck {
  int? id;
  final String name;
  final List<Flashcard> flashcards;

  Deck({ this.id, required this.name, required this.flashcards});

  Deck.fromMap(Map<String, dynamic> deckMap, this.flashcards)
      : id = deckMap['id'],
        name = deckMap['name'];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}

