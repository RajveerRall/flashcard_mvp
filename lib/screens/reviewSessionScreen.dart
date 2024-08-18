// import 'package:flashcard_mvp/models/flashcard.dart';
// import 'package:flutter/material.dart';
// import 'package:flashcard_mvp/services/database_helper.dart';
//
// class ReviewSessionScreen extends StatefulWidget {
//   final List<Flashcard> flashcards;
//
//   ReviewSessionScreen({required this.flashcards});
//
//   @override
//   _ReviewSessionScreenState createState() => _ReviewSessionScreenState();
// }
//
// class _ReviewSessionScreenState extends State<ReviewSessionScreen> {
//   int _currentIndex = 0;
//   final DatabaseHelper _databaseHelper = DatabaseHelper();
//
//   void _showNextFlashcard() {
//     setState(() {
//       _currentIndex = (_currentIndex + 1) % widget.flashcards.length;
//     });
//   }
//
//   Future<void> _handleRating(String rating) async {
//     final flashcard = widget.flashcards[_currentIndex];
//     int intervalDays = flashcard.intervalDays;
//
//     if (rating == 'Easy') {
//       intervalDays = intervalDays * 4; // Increase the interval significantly
//     } else if (rating == 'Medium') {
//       intervalDays = intervalDays * 2; // Increase the interval moderately
//     } else if (rating == 'Hard') {
//       intervalDays = (intervalDays ~/ 2).clamp(1, intervalDays); // Decrease the interval or slightly increase it
//     }
//
//     final newDueDate = DateTime.now().add(Duration(days: intervalDays));
//
//     // Update the flashcard with new interval and due date
//     final updatedFlashcard = Flashcard(
//       id: flashcard.id,
//       word: flashcard.word,
//       definition: flashcard.definition,
//       exampleSentence: flashcard.exampleSentence,
//       intervalDays: intervalDays,
//       dueDate: newDueDate,
//     );
//
//     // Save this updated flashcard back to the database
//     await _databaseHelper.updateFlashcard(updatedFlashcard);
//
//     // Show the next flashcard
//     _showNextFlashcard();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final flashcard = widget.flashcards[_currentIndex];
//
//     return Scaffold(
//       appBar: AppBar(title: Text('Review Session')),
//       body: Center(
//         child: GestureDetector(
//           onTap: _showNextFlashcard,
//           child: Card(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     flashcard.word,
//                     style: TextStyle(fontSize: 24),
//                   ),
//                   SizedBox(height: 20),
//                   Text(
//                     flashcard.definition,
//                     style: TextStyle(fontSize: 18, color: Colors.grey[700]),
//                   ),
//                   SizedBox(height: 10),
//                   Text(
//                     flashcard.exampleSentence,
//                     style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//       bottomNavigationBar: BottomAppBar(
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             ElevatedButton(
//               onPressed: () => _handleRating('Easy'),
//               child: Text('Easy'),
//             ),
//             ElevatedButton(
//               onPressed: () => _handleRating('Medium'),
//               child: Text('Medium'),
//             ),
//             ElevatedButton(
//               onPressed: () => _handleRating('Hard'),
//               child: Text('Hard'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



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
  bool _showAnswer = false; // To toggle between showing word and answer
  final DatabaseHelper _databaseHelper = DatabaseHelper(); // Initialize DatabaseHelper

  void _toggleCard() {
    setState(() {
      _showAnswer = !_showAnswer;
    });
  }

  void _rateFlashcard(String rating) {
    final flashcard = widget.flashcards[_currentIndex];

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

// Example of creating a Flashcard object ensuring no null values are passed
    final updatedFlashcard = Flashcard(
      id: flashcard.id ?? 0, // Ensure that id is not null, provide a default value if needed
      word: flashcard.word ?? '', // Ensure word is not null
      definition: flashcard.definition ?? '', // Ensure definition is not null
      exampleSentence: flashcard.exampleSentence ?? '', // Ensure exampleSentence is not null
      intervalDays: flashcard.intervalDays ?? 1, // Ensure intervalDays is not null
      easeFactor: flashcard.easeFactor ?? 2.5, // Ensure easeFactor is not null
      repetitions: flashcard.repetitions ?? 0, // Ensure repetitions is not null
      dueDate: flashcard.dueDate ?? DateTime.now(), // Ensure dueDate is not null
    );


    // Save the updated flashcard back to the database
    _databaseHelper.updateFlashcard(updatedFlashcard);

    // Move to the next flashcard or end the session
    _showNextFlashcard();
  }

  void _showNextFlashcard() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.flashcards.length;
      _showAnswer = false; // Reset to show the word for the next flashcard
    });
  }

  @override
  Widget build(BuildContext context) {
    final flashcard = widget.flashcards[_currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text('Review Session')),
      body: Center(
        child: GestureDetector(
          onTap: _toggleCard, // Toggle between showing the word and the definition
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _showAnswer
                    ? '${flashcard.word}\n\nDefinition: ${flashcard.definition}\n\nExample: ${flashcard.exampleSentence}'
                    : flashcard.word, // Show word by default
                style: TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
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
    );
  }
}


