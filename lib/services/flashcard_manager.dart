import 'package:flashcard_mvp/models/flashcard.dart';
import 'package:flashcard_mvp/services/llm_service.dart';
import 'package:flashcard_mvp/services/database_helper.dart';
import 'package:flashcard_mvp/services/image_service.dart';

class FlashcardManager {
  final LLMService _llmService = LLMService();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final ImageService _imageService = ImageService();

  // // Method to generate a deck of flashcards based on user input
  // Future<Deck?> generateDeck(String input) async {
  //   try {
  //     // Check if a deck with this name already exists
  //     Deck? existingDeck = await _databaseHelper.getDeckByName(input);
  //
  //     if (existingDeck != null) {
  //       print('Deck with name "$input" already exists. Returning existing deck.');
  //       return existingDeck;
  //     }
  //
  //     // Generate flashcards using LLM service
  //     final List<Flashcard> flashcards = await _llmService.suggestWords(input);
  //
  //     if (flashcards.isEmpty) {
  //       print('No flashcards were generated');
  //       return null;
  //     }
  //
  //     // Parallel image generation
  //     await Future.wait(flashcards.map((flashcard) async {
  //       flashcard.dueDate = DateTime.now(); // Set dueDate to current date and time
  //       flashcard.imageUrl = await _imageService.generateImage(
  //           flashcard.word, flashcard.definition
  //       );
  //     }));
  //
  //     // Create a deck with the generated flashcards
  //     Deck newDeck = Deck(
  //       name: input,
  //       flashcards: flashcards,
  //     );
  //
  //     // Save the new deck and its flashcards to the database
  //     int deckId = await _databaseHelper.insertDeck(newDeck);
  //     await _databaseHelper.insertFlashcards(flashcards, deckId); // Batch insert flashcards
  //
  //     return newDeck;
  //
  //   } catch (e) {
  //     print('Failed to generate deck: $e');
  //     return null;
  //   }
  // }

  Future<Deck?> generateDeck(String input) async {
    try {
      // Check if a deck with this name already exists
      Deck? existingDeck = await _databaseHelper.getDeckByName(input);

      if (existingDeck != null && existingDeck.flashcards.isNotEmpty) {
        print('Deck with name "$input" already exists. Returning existing deck.');
        return existingDeck;
      }

      // Generate flashcards using LLM service
      final List<Flashcard> flashcards = await _llmService.suggestWords(input);

      if (flashcards.isEmpty) {
        print('No flashcards were generated');
        return null;
      }

      // Parallel image generation with error handling
      await Future.forEach(flashcards, (Flashcard flashcard) async {
        flashcard.dueDate = DateTime.now(); // Set dueDate to current date and time
        await Future.delayed(Duration(milliseconds: 100)); // Add a small delay
        flashcard.imageUrl = await _imageService.generateImage(
            flashcard.word, flashcard.definition
        );
      });

      // Create and save the deck only if flashcards were generated successfully
      if (flashcards.isNotEmpty) {
        Deck newDeck = Deck(
          name: input,
          flashcards: flashcards,
        );

        int deckId = await _databaseHelper.insertDeck(newDeck);
        await _databaseHelper.insertFlashcards(flashcards, deckId);

        return newDeck;
      } else {
        print('No valid flashcards to save, skipping deck creation.');
        return null;
      }
    } catch (e) {
      print('Failed to generate deck: $e');
      return null;
    }
  }


  // Method to retrieve flashcards that are due for review for a specific deck
  Future<List<Flashcard>> getDueFlashcards(int deckId) async {
    final now = DateTime.now(); // Keep it as a DateTime object
    final List<Flashcard> dueFlashcards = await _databaseHelper.getDueFlashcards(deckId, now); // Pass the deckId and now as DateTime
    return dueFlashcards;
  }

  // Method to update flashcard status after review
  Future<void> updateFlashcardAfterReview(Flashcard flashcard, String rating) async {
    int repetitions = flashcard.repetitions;
    double easeFactor = flashcard.easeFactor;
    int intervalDays = flashcard.intervalDays;

    if (rating == 'Easy') {
      repetitions += 1;
      easeFactor += 0.1;
      intervalDays = (intervalDays * easeFactor).round();
    } else if (rating == 'Medium') {
      repetitions += 1;
      intervalDays = (intervalDays * easeFactor).round();
    } else if (rating == 'Hard') {
      easeFactor = (easeFactor - 0.2).clamp(1.3, 2.5);
      intervalDays = 1;
    }

    final newDueDate = DateTime.now().add(Duration(days: intervalDays));

    final updatedFlashcard = Flashcard(
      id: flashcard.id,
      word: flashcard.word ?? '',
      definition: flashcard.definition ?? '',
      exampleSentence: flashcard.exampleSentence ?? '',
      intervalDays: intervalDays,
      easeFactor: easeFactor,
      repetitions: repetitions,
      dueDate: newDueDate,
      imageUrl: flashcard.imageUrl,
    );

    await _databaseHelper.updateFlashcard(updatedFlashcard);
  }
}
