


import 'package:flashcard_mvp/models/flashcard.dart';
import 'package:flutter/material.dart';



class StatisticsScreen extends StatelessWidget {
  final List<Flashcard> flashcards;

  StatisticsScreen({required this.flashcards});

  @override
  Widget build(BuildContext context) {
    int totalReviews = flashcards.fold(0, (sum, card) => sum + card.repetitions);
    double averageInterval = flashcards.fold(0.0, (sum, card) => sum + card.intervalDays) / flashcards.length;

    return Scaffold(
      appBar: AppBar(title: Text('Statistics')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Total Reviews: $totalReviews'),
            Text('Average Interval: ${averageInterval.toStringAsFixed(2)} days'),
            // Add more statistics as needed
          ],
        ),
      ),
    );
  }
}
