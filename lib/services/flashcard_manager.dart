

// import 'package:flashcard_mvp/services/llm_service.dart';

// import '../models/flashcard.dart';

// class FlashcardManager {
//   final LLMService _llmService = LLMService();

//   // Method to generate a deck of flashcards
//   Future<Deck?> generateDeck() async {
//     // Step 1: Get the list of 20 words from LLMService
//     final words = await _llmService.suggestWords();

//     if (words.isEmpty) {
//       print('No words were suggested');
//       return null;
//     }

//     // Step 2: Generate flashcards for the suggested words
//     final flashcards = await _llmService.generateFlashcards(words);

//     if (flashcards.isEmpty) {
//       print('Failed to generate flashcards');
//       return null;
//     }

//     // Step 3: Create a Deck from the generated flashcards
//     final deck = Deck(
//       name: 'Generated Deck',
//       flashcards: flashcards,
//     );

//     return deck;
//   }
// }


// import 'package:flashcard_mvp/models/flashcard.dart';
// import 'package:flashcard_mvp/services/llm_service.dart';
//
// class FlashcardManager {
//   final LLMService _llmService = LLMService();
//
//   Future<Deck?> generateDeck(String input) async {
//     // Pass the user input to suggestWords
//     final words = await _llmService.suggestWords(input);
//
//     if (words.isEmpty) {
//       print('No words were suggested');
//       return null;
//     }
//
//     final flashcards = await _llmService.generateFlashcards(words);
//
//     if (flashcards.isEmpty) {
//       print('Failed to generate flashcards');
//       return null;
//     }
//
//     return Deck(
//       name: 'Generated Deck',
//       flashcards: flashcards,
//     );
//   }
//
// }


import 'package:flashcard_mvp/models/flashcard.dart';
import 'package:flashcard_mvp/services/llm_service.dart';
import 'package:flashcard_mvp/services/database_helper.dart';

class FlashcardManager {
  final LLMService _llmService = LLMService();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Method to generate a deck of flashcards based on user input
  Future<Deck?> generateDeck(String input) async {
    try {
      // Call the suggestWords method to get a list of words and their corresponding flashcards
      final List<Flashcard> flashcards = await _llmService.suggestWords(input);

      if (flashcards.isEmpty) {
        print('No flashcards were generated');
        return null;
      }

      // Save the new deck to the database to get the generated ID
      final newDeck = Deck(
        id: 0, // Temporary ID, will be replaced after insertion into DB
        name: 'Generated Deck',
        flashcards: flashcards,
      );

      final deckId = await _databaseHelper.insertDeck(newDeck);
      if (deckId == null) {
        print('Failed to save the deck to the database');
        return null;
      }

      // Return the deck with the correct ID
      return Deck(
        id: deckId,
        name: 'Generated Deck',
        flashcards: flashcards,
      );
    } catch (e) {
      print('Failed to generate deck: $e');
      return null;
    }
  }
}



