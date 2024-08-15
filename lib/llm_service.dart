// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'flashcard.dart';

// class LLMService {
//   final String apiKey = 'sk-proj-MjEDyrrYvhu4gRBcNCmrT3BlbkFJfQdSUtaPPdOyklJ3SGmM'; // Replace with your LLM API key
//   final String apiUrl = 'https://api.openai.com/v1/completions';

//   Future<Flashcard?> generateFlashcard(String word) async {
//     final response = await http.post(
//       Uri.parse(apiUrl),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $apiKey',
//       },
//       body: jsonEncode({
//         'model': 'text-davinci-003',
//         'prompt': 'Provide a flashcard for the word "$word" including a definition and an example sentence.',
//         'max_tokens': 100,
//       }),
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       final String content = data['choices'][0]['text'].trim();
//       final parts = content.split('\n');
//       if (parts.length >= 2) {
//         return Flashcard(
//           word: word,
//           definition: parts[0].replaceAll('Definition: ', ''),
//           exampleSentence: parts[1].replaceAll('Example: ', ''),
//         );
//       }
//     }
//     return null;
//   }
// }


import 'dart:convert';
import 'package:http/http.dart' as http;
import 'flashcard.dart';

class LLMService {
  final String apiKey = 'sk-proj-MjEDyrrYvhu4gRBcNCmrT3BlbkFJfQdSUtaPPdOyklJ3SGmM'; // Replace with your OpenAI API key
  final String apiUrl = 'https://api.openai.com/v1/chat/completions';

  Future<Flashcard?> generateFlashcard(String word) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "gpt-4o-mini", // Use the correct model name
          "messages": [
            {
              "role": "system",
              "content": "You are a helpful assistant."
            },
            {
              "role": "user",
              "content": 'Create a flashcard for the word "$word" with the following details: definition and example sentence.'
            }
          ],
          "max_tokens": 100,
          "temperature": 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String content = data['choices'][0]['message']['content'].trim();

        // Log the full content to see what the API returns
        print('API Response Content: $content');

        // Adjusted Parsing Logic to match the provided response format
        final definitionStart = content.indexOf("**Definition:**");
        final exampleStart = content.indexOf("**Example Sentence:**");

        String? definition;
        String? exampleSentence;

        if (definitionStart != -1 && exampleStart != -1) {
          definition = content.substring(
            definitionStart + "**Definition:**".length,
            exampleStart,
          ).trim();

          exampleSentence = content.substring(
            exampleStart + "**Example Sentence:**".length,
          ).trim();

          if (definition.isNotEmpty && exampleSentence.isNotEmpty) {
            return Flashcard(
              word: word,
              definition: definition,
              exampleSentence: exampleSentence,
            );
          } else {
            print('Parsed definition or example sentence is empty.');
          }
        } else {
          print('Failed to find the definition or example sentence in the response.');
        }
      } else {
        print('Failed to fetch flashcard. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
    return null;
  }
}



