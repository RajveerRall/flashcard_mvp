import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/flashcard.dart'; // Assuming your Flashcard model is in this path
import '../services/tts_service.dart'; // Assuming your TTS service is in this path
import 'package:flashcard_mvp/flashcard_audio_player.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:audioplayers/audioplayers.dart' as ap;


class FlashcardScreen extends StatefulWidget {
  final Flashcard flashcard;

  FlashcardScreen({required this.flashcard});

  @override
  _FlashcardScreenState createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  bool showAnswer = false;
  double cardScale = 1.0;

  final TTSService _ttsService = TTSService(); // Initialize the TTS service

  void toggleCard() {
    setState(() {
      showAnswer = !showAnswer;
      cardScale = showAnswer ? 1.05 : 1.0; // Scale animation effect
    });
  }

  void _playSpeech(BuildContext context, Flashcard flashcard) async {
    final textToSpeak = "${flashcard.word}. Definition: ${flashcard.definition}. Example: ${flashcard.exampleSentence}";

    final directory = await getApplicationDocumentsDirectory();
    final sanitizedWord = flashcard.word.replaceAll(RegExp(r'[^\w\s]'), '').replaceAll(' ', '_');
    final filePath = path.join(directory.path, '$sanitizedWord.mp3');
    final file = File(filePath);

    if (file.existsSync()) {
      // If the file exists, play the saved audio
      final audioplayerInstance = ap.AudioPlayer(); // Using the alias ap
      await audioplayerInstance.play(ap.DeviceFileSource(filePath));
    } else {
      // If the file doesn't exist, generate the speech and save it
      final generatedFilePath = await _ttsService.generateSpeech(textToSpeak);
      if (generatedFilePath != null) {
        await Future.delayed(const Duration(milliseconds: 500));
        final audioplayerInstance = ap.AudioPlayer(); // Using the alias ap
        await audioplayerInstance.play(ap.DeviceFileSource(generatedFilePath));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate speech')));
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flashcard'),
        actions: [
          IconButton(
            icon: Icon(Icons.volume_up),
            onPressed: () {
              _playSpeech(context, widget.flashcard); // Play speech for the current flashcard
            },
          ),
        ],
      ),
      body: Center(
        child: GestureDetector(
          onTap: toggleCard,
          child: Transform.scale(
            scale: cardScale,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  showAnswer ? "${widget.flashcard.definition}\n\nExample: ${widget.flashcard.exampleSentence}" : widget.flashcard.word,
                  style: TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,
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
              onPressed: () {
                // Handle 'Easy' pressed
              },
              child: Text('Easy'),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle 'Medium' pressed
              },
              child: Text('Medium'),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle 'Hard' pressed
              },
              child: Text('Hard'),
            ),
          ],
        ),
      ),
    );
  }
}
