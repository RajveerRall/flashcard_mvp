import 'package:flashcard_mvp/models/flashcard.dart';
import 'package:flashcard_mvp/services/llm_service.dart';
import 'package:flashcard_mvp/services/database_helper.dart'; // Assuming this is where your DB helper is
import 'package:flashcard_mvp/services/image_service.dart'; // Import the ImageService for generating images

import 'package:flashcard_mvp/models/flashcard.dart';
import 'package:flashcard_mvp/services/llm_service.dart';
import 'package:flashcard_mvp/services/database_helper.dart';
import 'package:flashcard_mvp/services/image_service.dart'; // Import the ImageService

class FlashcardManager {
  final LLMService _llmService = LLMService();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final ImageService _imageService = ImageService(); // Initialize the ImageService

  // Method to generate a deck of flashcards based on user input
  Future<Deck?> generateDeck(String input) async {
    try {
      // Check if a deck with this name already exists
      Deck? existingDeck = await _databaseHelper.getDeckByName(input);

      if (existingDeck != null) {
        print('Deck with name "$input" already exists. Returning existing deck.');
        return existingDeck;
      }

      // Parallelize flashcard generation and image generation
      final List<Flashcard> flashcards = await _llmService.suggestWords(input);

      if (flashcards.isEmpty) {
        print('No flashcards were generated');
        return null;
      }

      // Parallel image generation
      await Future.wait(flashcards.map((flashcard) async {
        flashcard.imageUrl = await _imageService.generateImage(
          flashcard.word, flashcard.definition
        );
      }));

      // Create a deck with the generated flashcards
      Deck newDeck = Deck(
        name: input,
        flashcards: flashcards,
      );

      // Save the new deck and its flashcards to the database
      int deckId = await _databaseHelper.insertDeck(newDeck);
      await _databaseHelper.insertFlashcards(flashcards, deckId); // Use batch insert

      return newDeck;

    } catch (e) {
      print('Failed to generate deck: $e');
      return null;
    }
  }
}
