// import 'package:flutter/material.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// import 'database_helper.dart';
// import 'flashcard.dart';
// import 'llm_service.dart';

// void main() {
//   // Initialize the sqflite_common_ffi factory
//   sqfliteFfiInit();
//   databaseFactory = databaseFactoryFfi;

//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flashcard MVP',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: FlashcardHomePage(),
//     );
//   }
// }

// class FlashcardHomePage extends StatefulWidget {
//   @override
//   _FlashcardHomePageState createState() => _FlashcardHomePageState();
// }

// class _FlashcardHomePageState extends State<FlashcardHomePage> {
//   final DatabaseHelper _databaseHelper = DatabaseHelper();
//   final LLMService _llmService = LLMService();
//   final TextEditingController _wordController = TextEditingController();
//   List<Flashcard> _flashcards = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadFlashcards();
//   }

//   Future<void> _loadFlashcards() async {
//     final flashcards = await _databaseHelper.getFlashcards();
//     setState(() {
//       _flashcards = flashcards;
//     });
//   }

//   Future<void> _generateAndSaveFlashcard(String word) async {
//     final flashcard = await _llmService.generateFlashcard(word);
//     if (flashcard != null) {
//       await _databaseHelper.insertFlashcard(flashcard);
//       _loadFlashcards();
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate flashcard')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Flashcard MVP'),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _wordController,
//               decoration: InputDecoration(labelText: 'Enter a word'),
//             ),
//             SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: () {
//                 final word = _wordController.text.trim();
//                 if (word.isNotEmpty) {
//                   _generateAndSaveFlashcard(word);
//                   _wordController.clear();
//                 }
//               },
//               child: Text('Generate Flashcard'),
//             ),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: _flashcards.length,
//                 itemBuilder: (context, index) {
//                   final flashcard = _flashcards[index];
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
// }



import 'package:flashcard_mvp/services/llm_service.dart';
import 'package:flashcard_mvp/screens/flashcard_deck_generator.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:audioplayers/audioplayers.dart';
import 'services/tts_service.dart';
import 'services/database_helper.dart';
import 'models/flashcard.dart';
import 'package:path/path.dart' as path;
import 'dart:io';



// void main() {
//
//   // print('Current directory: ${Directory.current.path}');
//   // await dotenv.load(fileName: ".env");
//
//   // Initialize the sqflite_common_ffi factory
//   sqfliteFfiInit();
//   databaseFactory = databaseFactoryFfi;
//
//   runApp(MyApp());
// }

void main() async {

  // Initialize the sqflite_common_ffi factory
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Run the Flutter app
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcard MVP',
      theme: ThemeData(primarySwatch: Colors.blue),
      // home: FlashcardHomePage(),
      home: FlashcardDeckGenerator(),
    );
  }
}




// class FlashcardHomePage extends StatefulWidget {
//   @override
//   _FlashcardHomePageState createState() => _FlashcardHomePageState();
// }
//
// class _FlashcardHomePageState extends State<FlashcardHomePage> {
//   final DatabaseHelper _databaseHelper = DatabaseHelper();
//   final LLMService _llmService = LLMService();
//   final TTSService _ttsService = TTSService();
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   final TextEditingController _wordController = TextEditingController();
//   List<Flashcard> _flashcards = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadFlashcards();
//   }
//
//   Future<void> _loadFlashcards() async {
//     final flashcards = await _databaseHelper.getFlashcards();
//     setState(() {
//       _flashcards = flashcards;
//     });
//   }
//
//   Future<void> _generateAndSaveFlashcard(String word) async {
//     final flashcard = await _llmService.generateFlashcard(word);
//     if (flashcard != null) {
//       await _databaseHelper.insertFlashcard(flashcard);
//       _loadFlashcards();
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate flashcard')));
//     }
//   }
//   // old
//   // Future<void> _playSpeech(String text) async {
//   //   final filePath = await _ttsService.generateSpeech(text);
//   //   if (filePath != null) {
//   //     await _audioPlayer.play(DeviceFileSource(filePath));
//   //   } else {
//   //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate speech')));
//   //   }
//   // }
//
//   // old v1
//   // Future<void> _playSpeech(String word) async {
//   //   final filePath = await _ttsService.generateSpeech(word);
//   //   if (filePath != null) {
//   //     // Add a small delay to ensure the file is completely written and available
//   //     await Future.delayed(const Duration(milliseconds: 500));
//
//   //     // Now, attempt to play the file
//   //     await _audioPlayer.play(DeviceFileSource(filePath));
//   //   } else {
//   //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate speech')));
//   //   }
//   // }
//
// Future<void> _playSpeech(String word) async {
//   final directory = await getApplicationDocumentsDirectory();
//   final sanitizedWord = word.replaceAll(RegExp(r'[^\w\s]'), '').replaceAll(' ', '_'); // Remove invalid filename characters
//   final filePath = path.join(directory.path, '$sanitizedWord.mp3');
//   final file = File(filePath);
//
//   if (file.existsSync()) {
//     // If the file exists, play the saved audio
//     await _audioPlayer.play(DeviceFileSource(filePath));
//   } else {
//     // If the file doesn't exist, generate the speech and save it
//     final generatedFilePath = await _ttsService.generateSpeech(word);
//     if (generatedFilePath != null) {
//       // Add a small delay to ensure the file is completely written and available
//       await Future.delayed(const Duration(milliseconds: 500));
//
//       // Now, attempt to play the file
//       await _audioPlayer.play(DeviceFileSource(generatedFilePath));
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate speech')));
//     }
//   }
// }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Flashcard MVP'),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _wordController,
//               decoration: InputDecoration(labelText: 'Enter a word'),
//             ),
//             SizedBox(height: 10),
//             Row(
//               children: [
//                 ElevatedButton(
//                   onPressed: () {
//                     final word = _wordController.text.trim();
//                     if (word.isNotEmpty) {
//                       _generateAndSaveFlashcard(word);
//                       _wordController.clear();
//                     }
//                   },
//                   child: Text('Generate Flashcard'),
//                 ),
//                 SizedBox(width: 10),
//                 ElevatedButton(
//                   onPressed: () {
//                     final word = _wordController.text.trim();
//                     if (word.isNotEmpty) {
//                       _playSpeech(word);
//                     }
//                   },
//                   child: Icon(Icons.volume_up), // Icon for the audio button
//                 ),
//               ],
//             ),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: _flashcards.length,
//                 itemBuilder: (context, index) {
//                   final flashcard = _flashcards[index];
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
//                           _playSpeech(flashcard.word); // Play the word when the icon is pressed
//                         },
//                       ),
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
// }
