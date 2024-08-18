import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flashcard_mvp/models/flashcard.dart';
import 'package:flashcard_mvp/services/flashcard_manager.dart';
import 'package:flashcard_mvp/services/tts_service.dart';
import 'package:flashcard_mvp/screens/reviewSessionScreen.dart';
import 'dart:async';

class DeckScreen extends StatefulWidget {
  final Deck deck;

  DeckScreen({required this.deck});

  @override
  _DeckScreenState createState() => _DeckScreenState();
}

class _DeckScreenState extends State<DeckScreen> {
  final TTSService _ttsService = TTSService();
  final FlashcardManager _flashcardManager = FlashcardManager(); // Initialize FlashcardManager
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSpeech(String text) async {
    if (_isPlaying) {
      await _audioPlayer.stop();
    }

    setState(() {
      _isPlaying = true;
    });

    final audioFilePath = await _ttsService.generateSpeech(text);

    if (audioFilePath != null) {
      try {
        await Future.delayed(const Duration(milliseconds: 500));
        await _audioPlayer.play(DeviceFileSource(audioFilePath));
      } catch (e) {
        print('An error occurred: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to play speech.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate speech.')),
      );
    }

    setState(() {
      _isPlaying = false;
    });
  }

  void _startReview() async {
    final dueFlashcards = await _flashcardManager.getDueFlashcards(widget.deck.id!);

    if (dueFlashcards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No flashcards are due for review today.')),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReviewSessionScreen(deck: widget.deck, flashcards: dueFlashcards),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.deck.name)),
      body: ListView.builder(
        itemCount: widget.deck.flashcards.length,
        itemBuilder: (context, index) {
          final flashcard = widget.deck.flashcards[index];
          return ListTile(
            title: Text(flashcard.word),
            subtitle: Text('Definition: ${flashcard.definition}'),
            trailing: IconButton(
              icon: Icon(Icons.volume_up),
              onPressed: () {
                _playSpeech(
                  '${flashcard.word}. Definition: ${flashcard.definition}. Example: ${flashcard.exampleSentence}',
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.play_arrow),
        label: Text('Start Review'),
        onPressed: () async {
          if (_isPlaying) {
            await _audioPlayer.stop();
          }
          _startReview();
        },
      ),
    );
  }
}
