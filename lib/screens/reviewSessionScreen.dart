import 'dart:io';
import 'package:flashcard_mvp/services/image_service.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flashcard_mvp/models/flashcard.dart';
import 'package:flashcard_mvp/services/tts_service.dart';
import 'package:flashcard_mvp/services/database_helper.dart';
import 'package:spaced_repetition/SmResponse.dart';
import 'package:spaced_repetition/main.dart';

class ReviewSessionScreen extends StatefulWidget {
  final Deck deck;
  final List<Flashcard> flashcards; // Add this parameter

  ReviewSessionScreen({required this.deck, required this.flashcards}); // Update constructor

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
    for (var flashcard in widget.flashcards) {
      if (flashcard.imageUrl == null || flashcard.imageUrl!.isEmpty) {
        _loadImageForFlashcard(flashcard);
      }
    }
  }

  Future<void> _toggleCard() async {
    if (!_showAnswer) {
      final flashcard = widget.flashcards[_currentIndex];
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

      if (mounted) {
        setState(() {
          _isLoadingImage = false;
        });
      }

      // Update the flashcard with the new local image path in the database
      if (mounted) {
        await _databaseHelper.updateFlashcard(flashcard);
      }
    }
  }


  void _rateFlashcard(String rating) {
    final flashcard = widget.flashcards[_currentIndex];
    final sm = Sm();

    // Determine the quality rating based on the user's input
    int quality = _getQualityFromRating(rating);

    // Calculate the new SM-2 values
    SmResponse smResponse = sm.calc(
      quality: quality,
      repetitions: flashcard.repetitions,
      previousInterval: flashcard.intervalDays,
      previousEaseFactor: flashcard.easeFactor,
    );

    // Update the flashcard with the new values
    flashcard.repetitions = smResponse.repetitions;
    flashcard.easeFactor = smResponse.easeFactor;
    flashcard.intervalDays = smResponse.interval;
    flashcard.dueDate = DateTime.now().add(Duration(days: smResponse.interval));

    // Save the updated flashcard back to the database
    _databaseHelper.updateFlashcard(flashcard);

    // Move to the next flashcard or end the session
    _showNextFlashcard();
  }

  int _getQualityFromRating(String rating) {
    switch (rating) {
      case 'Easy':
        return 5; // perfect response
      case 'Medium':
        return 3; // correct response recalled with serious difficulty
      case 'Hard':
        return 1; // incorrect response; the correct one remembered
      default:
        return 0; // complete blackout
    }
  }

  void _showNextFlashcard() {
    if (_currentIndex < widget.flashcards.length - 1) {
      setState(() {
        _currentIndex += 1;
        _showAnswer = false; // Reset to show the word for the next flashcard
      });
    } else {
      _showCompletionMessage(); // Show completion message
    }
  }

  void _showCompletionMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Review Completed"),
          content: Text("You have reviewed all the flashcards for today. Great job!"),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Navigate back to the DeckScreen or home screen
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _playFlashcardAudio(Flashcard flashcard) async {
    try {
      await _audioPlayer.stop();

      final audioFilePath = await _ttsService.generateSpeech(
        '${flashcard.word}. Definition: ${flashcard.definition}. Example: ${flashcard.exampleSentence}',
      );

      if (audioFilePath != null) {
        await Future.delayed(Duration(milliseconds: 200));
        await _audioPlayer.play(DeviceFileSource(audioFilePath));
      } else {
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
    final flashcard = widget.flashcards[_currentIndex];
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: Text('Review Session')),
      body: SingleChildScrollView(
        child: Center(
          child: GestureDetector(
            onTap: _toggleCard,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (_showAnswer && flashcard.imageUrl != null && flashcard.imageUrl!.isNotEmpty)
                      Image.file(
                        File(flashcard.imageUrl!),
                        width: double.infinity,
                        height: screenHeight * 0.4,
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
                          : flashcard.word,
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
          _playFlashcardAudio(flashcard);
        },
        child: Icon(Icons.volume_up),
      )
          : null,
    );
  }
}
