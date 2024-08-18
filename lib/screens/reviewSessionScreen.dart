import 'dart:io';

import 'package:flashcard_mvp/services/image_service.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flashcard_mvp/models/flashcard.dart';
import 'package:flashcard_mvp/services/tts_service.dart';
import 'package:flashcard_mvp/services/database_helper.dart';

class ReviewSessionScreen extends StatefulWidget {
  final Deck deck;

  ReviewSessionScreen({required this.deck});

  @override
  _ReviewSessionScreenState createState() => _ReviewSessionScreenState();
}

class _ReviewSessionScreenState extends State<ReviewSessionScreen> {
  int _currentIndex = 0;
  bool _showAnswer = false; // To toggle between showing word and answer
  final DatabaseHelper _databaseHelper = DatabaseHelper(); // Initialize DatabaseHelper
  final TTSService _ttsService = TTSService(); // Initialize TTSService
  final AudioPlayer _audioPlayer = AudioPlayer(); // Initialize AudioPlayer
  final ImageService _imageService = ImageService();
  bool _isLoadingImage = false; // Flag to indicate if the image is loading

  @override
  void initState() {
    super.initState();
    _preloadImages(); // Preload images when the screen is initialized
  }

  void _preloadImages() {
    for (var flashcard in widget.deck.flashcards) {
      if (flashcard.imageUrl == null || flashcard.imageUrl!.isEmpty) {
        _loadImageForFlashcard(flashcard);
      }
    }
  }

  Future<void> _toggleCard() async {
    if (!_showAnswer) {
      final flashcard = widget.deck.flashcards[_currentIndex];
      await _loadImageForFlashcard(flashcard);
    }

    setState(() {
      _showAnswer = !_showAnswer;
    });
  }

  Future<void> _loadImageForFlashcard(Flashcard flashcard) async {
    if (flashcard.imageUrl == null || flashcard.imageUrl!.isEmpty) {
      setState(() {
        _isLoadingImage = true;
      });

      // Download and save the image locally, then update the flashcard with the file path
      flashcard.imageUrl = await _imageService.generateImage(
          flashcard.word, flashcard.definition
      );

      setState(() {
        _isLoadingImage = false;
      });

      // Update the flashcard with the new local image path in the database
      await _databaseHelper.updateFlashcard(flashcard);
    }
  }

  void _rateFlashcard(String rating) {
    final flashcard = widget.deck.flashcards[_currentIndex];

    int repetitions = flashcard.repetitions;
    double easeFactor = flashcard.easeFactor;
    int intervalDays = flashcard.intervalDays;

    if (rating == 'Easy') {
      repetitions += 1;
      easeFactor += 0.1; // Increase ease factor slightly
      intervalDays = (intervalDays * easeFactor).round(); // Increase interval based on ease factor
    } else if (rating == 'Medium') {
      repetitions += 1;
      intervalDays = (intervalDays * easeFactor).round();
    } else if (rating == 'Hard') {
      easeFactor = (easeFactor - 0.2).clamp(1.3, 2.5); // Decrease ease factor, min is 1.3
      intervalDays = 1; // Reset interval to 1 day
    }

    final newDueDate = DateTime.now().add(Duration(days: intervalDays));

    final updatedFlashcard = Flashcard(
      id: flashcard.id ?? 0, // Ensure that id is not null, provide a default value if needed
      word: flashcard.word ?? '', // Ensure word is not null
      definition: flashcard.definition ?? '', // Ensure definition is not null
      exampleSentence: flashcard.exampleSentence ?? '', // Ensure exampleSentence is not null
      intervalDays: flashcard.intervalDays ?? 1, // Ensure intervalDays is not null
      easeFactor: flashcard.easeFactor ?? 2.5, // Ensure easeFactor is not null
      repetitions: flashcard.repetitions ?? 0, // Ensure repetitions is not null
      dueDate: flashcard.dueDate ?? DateTime.now(), // Ensure dueDate is not null
      imageUrl: flashcard.imageUrl, // Keep imageUrl as it is, may be null
    );

    // Save the updated flashcard back to the database
    _databaseHelper.updateFlashcard(updatedFlashcard);

    // Move to the next flashcard or end the session
    _showNextFlashcard();
  }

  void _showNextFlashcard() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.deck.flashcards.length;
      _showAnswer = false; // Reset to show the word for the next flashcard
    });
  }

  Future<void> _playFlashcardAudio(Flashcard flashcard) async {
    try {
      // Stop any currently playing audio before playing the new one
      await _audioPlayer.stop();

      final audioFilePath = await _ttsService.generateSpeech(
        '${flashcard.word}. Definition: ${flashcard.definition}. Example: ${flashcard.exampleSentence}',
      );

      if (audioFilePath != null) {
        // Wait for a short duration to ensure the file is not in use
        await Future.delayed(Duration(milliseconds: 200));

        // Play the audio file using the audio player
        await _audioPlayer.play(DeviceFileSource(audioFilePath));
      } else {
        // Handle the case where audio generation failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate or play speech')),
        );
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final flashcard = widget.deck.flashcards[_currentIndex];
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: Text('Review Session')),
      body: SingleChildScrollView(
        child: Center(
          child: GestureDetector(
            onTap: _toggleCard, // Toggle between showing the word and the definition
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (_showAnswer && flashcard.imageUrl != null && flashcard.imageUrl!.isNotEmpty)
                      Image.file(
                        File(flashcard.imageUrl!),
                        width: double.infinity,
                        height: screenHeight * 0.4, // Adjust the height to fit the screen
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Text(
                            'Failed to load image',
                            style: TextStyle(color: Colors.red),
                          );
                        },
                      ),
                    SizedBox(height: 10),
                    Text(
                      _showAnswer
                          ? '${flashcard.word}\n\nDefinition: ${flashcard.definition}\n\nExample: ${flashcard.exampleSentence}'
                          : flashcard.word, // Show word by default
                      style: TextStyle(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => _rateFlashcard('Easy'),
              child: Text('Easy'),
            ),
            ElevatedButton(
              onPressed: () => _rateFlashcard('Medium'),
              child: Text('Medium'),
            ),
            ElevatedButton(
              onPressed: () => _rateFlashcard('Hard'),
              child: Text('Hard'),
            ),
          ],
        ),
      ),
      floatingActionButton: _showAnswer
          ? FloatingActionButton(
        onPressed: () {
          _playFlashcardAudio(flashcard); // Play the audio for the current flashcard
        },
        child: Icon(Icons.volume_up),
      )
          : null, // Show the button only when the answer is displayed
    );
  }
}
