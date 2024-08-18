import 'package:flashcard_mvp/models/flashcard.dart';
import 'package:flutter/material.dart';
import 'package:flashcard_mvp/screens/flashcard_deck_generator.dart';
import 'package:flashcard_mvp/services/database_helper.dart';
import 'package:flashcard_mvp/screens/deckscreen.dart';
import 'package:flashcard_mvp/screens/reviewSessionScreen.dart';

import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Import your main widget or other necessary files

void main() {
  // Initialize the FFI
  sqfliteFfiInit();

  // Set the global database factory to use sqflite_common_ffi
  databaseFactory = databaseFactoryFfi;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcard App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FlashcardDeckGenerator(),  // Your main screen widget
    );
  }
}


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Deck> _decks = [];

  @override
  void initState() {
    super.initState();
    _loadDecks();
  }

  Future<void> _loadDecks() async {
    final decks = await _databaseHelper.getAllDecks();
    setState(() {
      _decks = decks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flashcard App Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FlashcardDeckGenerator()),
                );
              },
              child: Text('Create New Deck'),
            ),
            SizedBox(height: 20),
            _decks.isEmpty
                ? Text('No decks available. Create one to get started!')
                : Expanded(
              child: ListView.builder(
                itemCount: _decks.length,
                itemBuilder: (context, index) {
                  final deck = _decks[index];
                  return Card(
                    child: ListTile(
                      title: Text(deck.name),
                      subtitle: Text('${deck.flashcards.length} flashcards'),
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
