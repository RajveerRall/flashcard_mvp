import 'package:flutter/material.dart';
import 'package:flashcard_mvp/models/flashcard.dart';
import 'package:flashcard_mvp/services/database_helper.dart';

class FlashcardScreen extends StatefulWidget {
  final Flashcard flashcard;

  FlashcardScreen({required this.flashcard});

  @override
  _FlashcardScreenState createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  bool _showAnswer = false;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  void _toggleCard() {
    setState(() {
      _showAnswer = !_showAnswer;
    });
  }

  void _rateFlashcard(String rating) async {
    int intervalDays = widget.flashcard.intervalDays;
    double easeFactor = widget.flashcard.easeFactor;
    int repetitions = widget.flashcard.repetitions;

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

    DateTime newDueDate = DateTime.now().add(Duration(days: intervalDays));

    // Update the flashcard with new values
    final updatedFlashcard = Flashcard(
      id: widget.flashcard.id,
      word: widget.flashcard.word,
      definition: widget.flashcard.definition,
      exampleSentence: widget.flashcard.exampleSentence,
      intervalDays: intervalDays,
      easeFactor: easeFactor,
      repetitions: repetitions,
      dueDate: newDueDate,
    );

    // Save the updated flashcard back to the database
    await _databaseHelper.updateFlashcard(updatedFlashcard);

    // Navigate back to the review session or deck screen
    Navigator.pop(context, updatedFlashcard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review Flashcard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _toggleCard,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _showAnswer
                        ? '${widget.flashcard.word}\n\n${widget.flashcard.definition}\n\nExample: ${widget.flashcard.exampleSentence}'
                        : widget.flashcard.word,
                    style: TextStyle(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
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
          ],
        ),
      ),
    );
  }
}
