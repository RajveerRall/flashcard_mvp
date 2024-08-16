import 'package:flashcard_mvp/screens/flashcard_screen.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

import '../models/flashcard.dart';
import '../services/tts_service.dart';

class DeckScreen extends StatelessWidget {
  final Deck deck;
  final TTSService _ttsService = TTSService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  DeckScreen({required this.deck});

  Future<void> _playSpeech(BuildContext context, Flashcard flashcard) async {
    final textToSpeak = "${flashcard.word}. Definition: ${flashcard.definition}. Example: ${flashcard.exampleSentence}";

    final directory = await getApplicationDocumentsDirectory();
    final sanitizedWord = flashcard.word.replaceAll(RegExp(r'[^\w\s]'), '').replaceAll(' ', '_'); // Remove invalid filename characters
    final filePath = path.join(directory.path, '$sanitizedWord.mp3');
    final file = File(filePath);

    if (file.existsSync()) {
      // If the file exists, play the saved audio
      await _audioPlayer.play(DeviceFileSource(filePath)); // Play using audioplayers
    } else {
      // If the file doesn't exist, generate the speech and save it
      final generatedFilePath = await _ttsService.generateSpeech(textToSpeak);
      if (generatedFilePath != null) {
        // Add a small delay to ensure the file is completely written and available
        await Future.delayed(const Duration(milliseconds: 500));

        // Now, attempt to play the file
        await _audioPlayer.play(DeviceFileSource(generatedFilePath)); // Play using audioplayers
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate speech')));
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(deck.name)),
      body: ListView.builder(
        itemCount: deck.flashcards.length,
        itemBuilder: (context, index) {
          final flashcard = deck.flashcards[index];
          return Card(
            child: ListTile(
              title: Text(flashcard.word),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Definition: ${flashcard.definition}'),
                  Text('Example: ${flashcard.exampleSentence}'),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FlashcardScreen(flashcard: flashcard),
                  ),
                );
              },
              trailing: IconButton(
                icon: Icon(Icons.volume_up),
                onPressed: () {
                  // _playSpeech(context, flashcard.word); // Pass context to the _playSpeech method
                  _playSpeech(context, flashcard); // Pass the entire flashcard object
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // Handle adding a new flashcard (if you need this functionality)
        },
      ),
    );
  }
}
