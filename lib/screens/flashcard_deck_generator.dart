import 'dart:io';

import 'package:flashcard_mvp/models/flashcard.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:audioplayers/audioplayers.dart';
import '../services/flashcard_manager.dart';
import '../services/database_helper.dart';
import '../services/tts_service.dart';
import 'deckscreen.dart';

class FlashcardDeckGenerator extends StatefulWidget {
  @override
  _FlashcardDeckGeneratorState createState() => _FlashcardDeckGeneratorState();
}

class _FlashcardDeckGeneratorState extends State<FlashcardDeckGenerator> {
  final FlashcardManager _flashcardManager = FlashcardManager();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final TTSService _ttsService = TTSService();
  final TextEditingController _wordController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Deck> _savedDecks = [];
  bool _isGenerating = false; // To track if the deck generation is in progress

  @override
  void initState() {
    super.initState();
    _loadSavedDecks();
  }

  Future<void> _loadSavedDecks() async {
    final decks = await _databaseHelper.getAllDecks();
    setState(() {
      _savedDecks = decks;
    });
  }

  Future<void> _generateAndSaveDeck() async {
    final word = _wordController.text.trim();
    if (word.isEmpty || _isGenerating) {
      print('Please enter a word or wait for the current generation to complete.');
      return;
    }

    setState(() {
      _isGenerating = true; // Set flag to true when generation starts
    });

    final generatedFlashcards = await _flashcardManager.generateDeck(word);

    if (generatedFlashcards != null && generatedFlashcards.flashcards.isNotEmpty) {
      // Create a new Deck without specifying the ID (it will be set by the database)
      final newDeck = Deck(id: 0, name: word, flashcards: generatedFlashcards.flashcards);

      // Save the new deck and get the auto-generated ID from the database
      final deckId = await _databaseHelper.insertDeck(newDeck);

      // Now update the deck object with the correct ID
      final updatedDeck = Deck(
        id: deckId,
        name: newDeck.name,
        flashcards: newDeck.flashcards,
      );

      // Save flashcards with the correct deckId
      for (Flashcard flashcard in updatedDeck.flashcards) {
        await _databaseHelper.insertFlashcardWithDeck(flashcard, deckId);
      }

      setState(() {
        _savedDecks.add(updatedDeck); // Save the deck with its correct ID
      });

      print('Deck generated and saved with ${newDeck.flashcards.length} flashcards.');
    } else {
      print('Failed to generate flashcards.');
    }

    setState(() {
      _isGenerating = false; // Reset the flag when generation is complete
    });
  }

  Future<void> _playSpeech(String word) async {
    final directory = await getApplicationDocumentsDirectory();
    final sanitizedWord = word.replaceAll(RegExp(r'[^\w\s]'), '').replaceAll(' ', '_');
    final filePath = path.join(directory.path, '$sanitizedWord.mp3');
    final file = File(filePath);

    if (file.existsSync()) {
      await _audioPlayer.play(DeviceFileSource(filePath));
    } else {
      final generatedFilePath = await _ttsService.generateSpeech(word);
      if (generatedFilePath != null) {
        await Future.delayed(const Duration(milliseconds: 500));
        await _audioPlayer.play(DeviceFileSource(generatedFilePath));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate speech')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flashcard Deck Generator'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _wordController,
              decoration: InputDecoration(
                labelText: 'Enter a word or query to generate flashcards',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isGenerating ? null : _generateAndSaveDeck, // Disable button if generating
              child: _isGenerating ? CircularProgressIndicator() : Text('Generate Flashcard Deck'),
            ),
            SizedBox(height: 20),
            _savedDecks.isEmpty
                ? Text('No saved decks available')
                : Expanded(
              child: ListView.builder(
                itemCount: _savedDecks.length,
                itemBuilder: (context, index) {
                  final deck = _savedDecks[index];
                  return Card(
                    child: ListTile(
                      title: Text(deck.name),
                      subtitle: Text('Flashcards: ${deck.flashcards.length}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DeckScreen(deck: deck),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
