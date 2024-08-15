class Flashcard {
  int? id;
  String word;
  String definition;
  String exampleSentence;

  Flashcard({
    this.id,
    required this.word,
    required this.definition,
    required this.exampleSentence,
  });

  // Convert a Flashcard into a Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'definition': definition,
      'exampleSentence': exampleSentence,
    };
  }

  // Convert a Map into a Flashcard.
  Flashcard.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        word = map['word'],
        definition = map['definition'],
        exampleSentence = map['exampleSentence'];

  
}

class Deck {
  final String name;
  final List<Flashcard> flashcards;

  Deck({required this.name, required this.flashcards});

  void addFlashcard(Flashcard flashcard) {
    flashcards.add(flashcard);
  }

}
