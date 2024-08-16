// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:path/path.dart' as path;
// import 'package:path_provider/path_provider.dart';
//
// import '../models/flashcard.dart';
// import '../services/flashcard_manager.dart';
// import '../services/tts_service.dart';
// import 'package:flashcard_mvp/services/database_helper.dart'; // Assuming this is the correct path to your DatabaseHelper
// import 'package:flashcard_mvp/screens/deckscreen.dart'; // New screen to view flashcards inside a deck
//
// class FlashcardDeckGenerator extends StatefulWidget {
//   @override
//   _FlashcardDeckGeneratorState createState() => _FlashcardDeckGeneratorState();
// }
//
// class _FlashcardDeckGeneratorState extends State<FlashcardDeckGenerator> {
//   final FlashcardManager _flashcardManager = FlashcardManager();
//   final DatabaseHelper _databaseHelper = DatabaseHelper();
//   final TextEditingController _wordController = TextEditingController();
//   Deck? _deck;
//   List<Deck> _savedDecks = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadSavedDecks(); // Load saved decks when the app starts
//   }
//
//   Future<void> _loadSavedDecks() async {
//     final decks = await _databaseHelper.getAllDecks();
//     setState(() {
//       _savedDecks = decks;
//     });
//   }
//
//   Future<void> _generateAndSaveDeck() async {
//     final word = _wordController.text.trim();
//     if (word.isEmpty) {
//       print('Please enter a word');
//       return;
//     }
//
//     // Generate and save the deck
//     final newDeck = Deck(name: word, flashcards: []);
//     final deckId = await _databaseHelper.insertDeck(newDeck);
//     final generatedDeck = await _flashcardManager.generateDeck(word);
//
//     if (generatedDeck != null) {
//       for (Flashcard flashcard in generatedDeck.flashcards) {
//         await _databaseHelper.insertFlashcardWithDeck(flashcard, deckId);
//       }
//       setState(() {
//         _savedDecks.add(generatedDeck);
//       });
//       print('Deck generated and saved with ${generatedDeck.flashcards.length} flashcards.');
//     } else {
//       print('Failed to generate deck.');
//     }
//   }
//
//   Future<void> _playSpeech(String word) async {
//     final directory = await getApplicationDocumentsDirectory();
//     final sanitizedWord = word.replaceAll(RegExp(r'[^\w\s]'), '').replaceAll(' ', '_'); // Remove invalid filename characters
//     final filePath = path.join(directory.path, '$sanitizedWord.mp3');
//     final file = File(filePath);
//
//     if (file.existsSync()) {
//       // If the file exists, play the saved audio
//       final audioplayerInstance = audioplayers.AudioPlayer(); // From audioplayers package
//       await audioplayerInstance.play(DeviceFileSource(filePath));
//     } else {
//       // If the file doesn't exist, generate the speech and save it
//       final generatedFilePath = await _ttsService.generateSpeech(word);
//       if (generatedFilePath != null) {
//         // Add a small delay to ensure the file is completely written and available
//         await Future.delayed(const Duration(milliseconds: 500));
//
//         // Now, attempt to play the file
//         final audioplayerInstance = audioplayers.AudioPlayer(); // From audioplayers package
//         await audioplayerInstance.play(DeviceFileSource(generatedFilePath));
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate speech')));
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Flashcard Deck Generator'),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _wordController,
//               decoration: InputDecoration(
//                 labelText: 'Enter a word or query to generate flashcards',
//               ),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _generateAndSaveDeck,
//               child: Text('Generate Flashcard Deck'),
//             ),
//             SizedBox(height: 20),
//             _deck == null
//                 ? Text('No deck generated yet')
//                 : Expanded(
//               child: ListView.builder(
//                 itemCount: _deck!.flashcards.length,
//                 itemBuilder: (context, index) {
//                   final flashcard = _deck!.flashcards[index];
//                   return Card(
//                     child: ListTile(
//                       title: Text(flashcard.word),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('Definition: ${flashcard.definition}'),
//                           Text('Example: ${flashcard.exampleSentence}'),
//                         ],
//                       ),
//                       trailing: IconButton(
//                         icon: Icon(Icons.volume_up),
//                         onPressed: () {
//                           _playSpeech(flashcard.word);
//                         },
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             SizedBox(height: 20),
//             _savedDecks.isEmpty
//                 ? Text('No saved decks available')
//                 : Expanded(
//               child: ListView.builder(
//                 itemCount: _savedDecks.length,
//                 itemBuilder: (context, index) {
//                   final deck = _savedDecks[index];
//                   return Card(
//                     child: ListTile(
//                       title: Text(deck.name),
//                       subtitle: Text(
//                         'Flashcards: ${deck.flashcards.length}',
//                       ),
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => DeckScreen(deck: deck),
//                           ),
//                         );
//                       },
//                     ),
//     import 'package:flashcard_mvp/screens/deckscreen.dart';
//               );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'dart:io';
// import 'package:flashcard_mvp/screens/flashcard_screen.dart';
// import 'package:flashcard_mvp/screens/reviewSessionScreen.dart';
// import 'package:flashcard_mvp/screens/stats%20screen.dart';
// import 'package:flutter/material.dart';
// import 'package:path/path.dart' as path;
// import 'package:path_provider/path_provider.dart';
// import 'package:audioplayers/audioplayers.dart'; // Import the audioplayers package
// import '../models/flashcard.dart';
// import '../services/flashcard_manager.dart';
// import '../services/tts_service.dart';
// import 'package:flashcard_mvp/services/database_helper.dart'; // Assuming this is the correct path to your DatabaseHelper
// import 'package:flashcard_mvp/screens/deckscreen.dart'; // New screen to view flashcards inside a deck
//
// class FlashcardDeckGenerator extends StatefulWidget {
//   @override
//   _FlashcardDeckGeneratorState createState() => _FlashcardDeckGeneratorState();
// }
//
// class _FlashcardDeckGeneratorState extends State<FlashcardDeckGenerator> {
//   final FlashcardManager _flashcardManager = FlashcardManager();
//   final DatabaseHelper _databaseHelper = DatabaseHelper();
//   final TTSService _ttsService = TTSService(); // Initialize the TTSService
//   final TextEditingController _wordController = TextEditingController();
//   final AudioPlayer _audioPlayer = AudioPlayer(); // Initialize AudioPlayer
//   Deck? _deck;
//   List<Deck> _savedDecks = [];
//
//
//
//   @override
//   void initState() {
//     super.initState();
//     _loadSavedDecks(); // Load saved decks when the app starts
//   }
//
//   Future<void> _loadSavedDecks() async {
//     final decks = await _databaseHelper.getAllDecks();
//     setState(() {
//       _savedDecks = decks;
//     });
//   }
//
//   Future<void> _generateAndSaveDeck() async {
//     final word = _wordController.text.trim();
//     if (word.isEmpty) {
//       print('Please enter a word');
//       return;
//     }
//
//     // Generate and save the deck
//     final newDeck = Deck(id: 0, name: word, flashcards: []);
//     final deckId = await _databaseHelper.insertDeck(newDeck);
//     final generatedDeck = await _flashcardManager.generateDeck(word);
//
//     if (generatedDeck != null) {
//       for (Flashcard flashcard in generatedDeck.flashcards) {
//         await _databaseHelper.insertFlashcardWithDeck(flashcard, deckId);
//       }
//       setState(() {
//         _savedDecks.add(generatedDeck);
//       });
//       print('Deck generated and saved with ${generatedDeck.flashcards.length} flashcards.');
//     } else {
//       print('Failed to generate deck.');
//     }
//   }
//
//   Future<void> _playSpeech(String word) async {
//     final directory = await getApplicationDocumentsDirectory();
//     final sanitizedWord = word.replaceAll(RegExp(r'[^\w\s]'), '').replaceAll(' ', '_'); // Remove invalid filename characters
//     final filePath = path.join(directory.path, '$sanitizedWord.mp3');
//     final file = File(filePath);
//     List<Flashcard> _savedFlashcards = []; // Assuming you have a list of flashcards
//
//
//     if (file.existsSync()) {
//       // If the file exists, play the saved audio
//       await _audioPlayer.play(DeviceFileSource(filePath)); // Play using audioplayers
//     } else {
//       // If the file doesn't exist, generate the speech and save it
//       final generatedFilePath = await _ttsService.generateSpeech(word);
//       if (generatedFilePath != null) {
//         // Add a small delay to ensure the file is completely written and available
//         await Future.delayed(const Duration(milliseconds: 500));
//
//         // Now, attempt to play the file
//         await _audioPlayer.play(DeviceFileSource(generatedFilePath)); // Play using audioplayers
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate speech')));
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Flashcard Deck Generator'),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _wordController,
//               decoration: InputDecoration(
//                 labelText: 'Enter a word or query to generate flashcards',
//               ),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _generateAndSaveDeck,
//               child: Text('Generate Flashcard Deck'),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _startReviewSession,
//               child: Text('Start Review Session'), // Add this button
//             ),
//             SizedBox(height: 20),
//             _deck == null
//                 ? Text('No deck generated yet')
//                 : Expanded(
//               child: ListView.builder(
//                 itemCount: _deck!.flashcards.length,
//                 itemBuilder: (context, index) {
//                   final flashcard = _deck!.flashcards[index];
//                   return Card(
//                     child: ListTile(
//                       title: Text(flashcard.word),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('Definition: ${flashcard.definition}'),
//                           Text('Example: ${flashcard.exampleSentence}'),
//                         ],
//                       ),
//                       trailing: IconButton(
//                         icon: Icon(Icons.volume_up),
//                         onPressed: () {
//                           _playSpeech(flashcard.word);
//                         },
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             SizedBox(height: 20),
//             _savedDecks.isEmpty
//                 ? Text('No saved decks available')
//                 : Expanded(
//               child: ListView.builder(
//                 itemCount: _savedDecks.length,
//                 itemBuilder: (context, index) {
//                   final deck = _savedDecks[index];
//                   return Card(
//                     child: ListTile(
//                       title: Text(deck.name),
//                       subtitle: Text(
//                         'Flashcards: ${deck.flashcards.length}',
//                       ),
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => DeckScreen(deck: deck),
//                           ),
//                         );
//                       },
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> _startReviewSession() async {
//     final dueFlashcards = await _databaseHelper.getDueFlashcards();
//
//     if (dueFlashcards.isNotEmpty) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => ReviewSessionScreen(flashcards: dueFlashcards),
//         ),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('No flashcards due for review')),
//       );
//     }
//   }
//
//
// }




import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart'; // Import the audioplayers package

import '../models/flashcard.dart';
import '../services/flashcard_manager.dart';
import '../services/tts_service.dart';
import 'package:flashcard_mvp/services/database_helper.dart';
import 'package:flashcard_mvp/screens/deckscreen.dart'; // New screen to view flashcards inside a deck
import 'package:flashcard_mvp/screens/reviewSessionScreen.dart';
import 'package:flashcard_mvp/screens/stats%20screen.dart'; // For statistics

class FlashcardDeckGenerator extends StatefulWidget {
  @override
  _FlashcardDeckGeneratorState createState() => _FlashcardDeckGeneratorState();
}

class _FlashcardDeckGeneratorState extends State<FlashcardDeckGenerator> {
  final FlashcardManager _flashcardManager = FlashcardManager();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final TTSService _ttsService = TTSService(); // Initialize the TTSService
  final TextEditingController _wordController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer(); // Initialize AudioPlayer
  Deck? _deck;
  List<Deck> _savedDecks = [];
  List<Flashcard> _allFlashcards = []; // This will hold all flashcards from all decks

  @override
  void initState() {
    super.initState();
    _loadSavedDecks(); // Load saved decks when the app starts
  }

  Future<void> _loadSavedDecks() async {
    final decks = await _databaseHelper.getAllDecks();
    List<Flashcard> flashcards = [];
    for (var deck in decks) {
      flashcards.addAll(deck.flashcards); // Accumulate all flashcards from each deck
    }
    setState(() {
      _savedDecks = decks;
      _allFlashcards = flashcards; // Store all flashcards
    });
  }

  Future<void> _generateAndSaveDeck() async {
    final word = _wordController.text.trim();
    if (word.isEmpty) {
      print('Please enter a word');
      return;
    }

    // Generate and save the deck
    final newDeck = Deck(id: 0, name: word, flashcards: []);
    final deckId = await _databaseHelper.insertDeck(newDeck);
    final generatedDeck = await _flashcardManager.generateDeck(word);

    if (generatedDeck != null) {
      for (Flashcard flashcard in generatedDeck.flashcards) {
        await _databaseHelper.insertFlashcardWithDeck(flashcard, deckId);
      }
      setState(() {
        _savedDecks.add(generatedDeck);
        _allFlashcards.addAll(generatedDeck.flashcards); // Add generated flashcards to the list
      });
      print('Deck generated and saved with ${generatedDeck.flashcards.length} flashcards.');
    } else {
      print('Failed to generate deck.');
    }
  }

  Future<void> _playSpeech(String word) async {
    final directory = await getApplicationDocumentsDirectory();
    final sanitizedWord = word.replaceAll(RegExp(r'[^\w\s]'), '').replaceAll(' ', '_'); // Remove invalid filename characters
    final filePath = path.join(directory.path, '$sanitizedWord.mp3');
    final file = File(filePath);

    if (file.existsSync()) {
      // If the file exists, play the saved audio
      final audioplayerInstance = AudioPlayer();
      await audioplayerInstance.play(DeviceFileSource(filePath));
    } else {
      // If the file doesn't exist, generate the speech and save it
      final generatedFilePath = await _ttsService.generateSpeech(word);
      if (generatedFilePath != null) {
        // Add a small delay to ensure the file is completely written and available
        await Future.delayed(const Duration(milliseconds: 500));

        // Now, attempt to play the file
        final audioplayerInstance = AudioPlayer();
        await audioplayerInstance.play(DeviceFileSource(generatedFilePath));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate speech')));
      }
    }
  }

  Future<void> _startReviewSession() async {
    final dueFlashcards = await _databaseHelper.getDueFlashcards();

    if (dueFlashcards.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReviewSessionScreen(flashcards: dueFlashcards),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No flashcards due for review')),
      );
    }
  }

  Future<void> _navigateToStatsScreen() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatisticsScreen(flashcards: _allFlashcards),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flashcard Deck Generator'),
        actions: [
          IconButton(
            icon: Icon(Icons.analytics),
            onPressed: _navigateToStatsScreen, // Navigate to the stats screen
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _wordController,
              decoration: InputDecoration(
                labelText: 'Enter a word or query to generate flashcards',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _generateAndSaveDeck,
              child: Text('Generate Flashcard Deck'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startReviewSession,
              child: Text('Start Review Session'), // Add this button
            ),
            SizedBox(height: 20),
            _deck == null
                ? Text('No deck generated yet')
                : Expanded(
              child: ListView.builder(
                itemCount: _deck!.flashcards.length,
                itemBuilder: (context, index) {
                  final flashcard = _deck!.flashcards[index];
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
                      trailing: IconButton(
                        icon: Icon(Icons.volume_up),
                        onPressed: () {
                          _playSpeech(flashcard.word);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            _savedDecks.isEmpty
                ? Text('No saved decks available')
                : Expanded(
              child: ListView.builder(
                itemCount: _savedDecks.length,
                itemBuilder: (context, index) {
                  final deck = _savedDecks[index];
                  return Card(
                    child: ListTile(
                      title: Text(deck.name),
                      subtitle: Text(
                        'Flashcards: ${deck.flashcards.length}',
                      ),
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



