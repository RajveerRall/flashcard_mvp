import 'package:flashcard_mvp/models/flashcard.dart';
import 'package:flutter/material.dart';
import 'package:flashcard_mvp/services/database_helper.dart';

class ReviewSessionScreen extends StatefulWidget {
  final List<Flashcard> flashcards;

  ReviewSessionScreen({required this.flashcards});

  @override
  _ReviewSessionScreenState createState() => _ReviewSessionScreenState();
}

class _ReviewSessionScreenState extends State<ReviewSessionScreen> {
  int _currentIndex = 0;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  void _showNextFlashcard() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.flashcards.length;
    });
  }

  Future<void> _handleRating(String rating) async {
    final flashcard = widget.flashcards[_currentIndex];
    int intervalDays = flashcard.intervalDays;

    if (rating == 'Easy') {
      intervalDays = intervalDays * 4; // Increase the interval significantly
    } else if (rating == 'Medium') {
      intervalDays = intervalDays * 2; // Increase the interval moderately
    } else if (rating == 'Hard') {
      intervalDays = (intervalDays ~/ 2).clamp(1, intervalDays); // Decrease the interval or slightly increase it
    }

    final newDueDate = DateTime.now().add(Duration(days: intervalDays));

    // Update the flashcard with new interval and due date
    final updatedFlashcard = Flashcard(
      id: flashcard.id,
      word: flashcard.word,
      definition: flashcard.definition,
      exampleSentence: flashcard.exampleSentence,
      intervalDays: intervalDays,
      dueDate: newDueDate,
    );

    // Save this updated flashcard back to the database
    await _databaseHelper.updateFlashcard(updatedFlashcard);

    // Show the next flashcard
    _showNextFlashcard();
  }

  @override
  Widget build(BuildContext context) {
    final flashcard = widget.flashcards[_currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text('Review Session')),
      body: Center(
        child: GestureDetector(
          onTap: _showNextFlashcard,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    flashcard.word,
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(height: 20),
                  Text(
                    flashcard.definition,
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 10),
                  Text(
                    flashcard.exampleSentence,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
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
              onPressed: () => _handleRating('Easy'),
              child: Text('Easy'),
            ),
            ElevatedButton(
              onPressed: () => _handleRating('Medium'),
              child: Text('Medium'),
            ),
            ElevatedButton(
              onPressed: () => _handleRating('Hard'),
              child: Text('Hard'),
            ),
          ],
        ),
      ),
    );
  }
}
