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


// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/flashcard.dart';

// class LLMService {
//   final String apiKey = 'sk-proj-MjEDyrrYvhu4gRBcNCmrT3BlbkFJfQdSUtaPPdOyklJ3SGmM'; // Replace with your OpenAI API key
//   final String apiUrl = 'https://api.openai.com/v1/chat/completions';

//   Future<Flashcard?> generateFlashcard(String word) async {
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $apiKey',
//         },
//         body: jsonEncode({
//           "model": "gpt-4o-mini", // Use the correct model name
//           "messages": [
//             {
//               "role": "system",
//               "content": "You are a helpful assistant."
//             },
//             {
//               "role": "user",
//               "content": 'Create a flashcard for the word "$word" with the following details: definition and example sentence.'
//             }
//           ],
//           "max_tokens": 100,
//           "temperature": 0.7,
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final String content = data['choices'][0]['message']['content'].trim();

//         // Log the full content to see what the API returns
//         print('API Response Content: $content');

//         // Adjusted Parsing Logic to match the provided response format
//         final definitionStart = content.indexOf("**Definition:**");
//         final exampleStart = content.indexOf("**Example Sentence:**");

//         String? definition;
//         String? exampleSentence;

//         if (definitionStart != -1 && exampleStart != -1) {
//           definition = content.substring(
//             definitionStart + "**Definition:**".length,
//             exampleStart,
//           ).trim();

//           exampleSentence = content.substring(
//             exampleStart + "**Example Sentence:**".length,
//           ).trim();

//           if (definition.isNotEmpty && exampleSentence.isNotEmpty) {
//             return Flashcard(
//               word: word,
//               definition: definition,
//               exampleSentence: exampleSentence,
//             );
//           } else {
//             print('Parsed definition or example sentence is empty.');
//           }
//         } else {
//           print('Failed to find the definition or example sentence in the response.');
//         }
//       } else {
//         print('Failed to fetch flashcard. Status code: ${response.statusCode}');
//         print('Response body: ${response.body}');
//       }
//     } catch (e) {
//       print('An error occurred: $e');
//     }
//     return null;
//   }
// }



// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/flashcard.dart';

// class LLMService {
//   final String apiKey = 'sk-proj-MjEDyrrYvhu4gRBcNCmrT3BlbkFJfQdSUtaPPdOyklJ3SGmM'; // Replace with your OpenAI API key
//   final String apiUrl = 'https://api.openai.com/v1/chat/completions';

//   // Method to generate a single flashcard
//   Future<Flashcard?> generateFlashcard(String word) async {
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $apiKey',
//         },
//         body: jsonEncode({
//           "model": "gpt-4o-mini", // Use the correct model name
//           "messages": [
//             {
//               "role": "system",
//               "content": "You are a helpful assistant."
//             },
//             {
//               "role": "user",
//               "content": 'Create a flashcard for the word "$word" with the following details: definition and example sentence.'
//             }
//           ],
//           "max_tokens": 100,
//           "temperature": 0.7,
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final String content = data['choices'][0]['message']['content'].trim();

//         // Log the full content to see what the API returns
//         print('API Response Content: $content');

//         // Adjusted Parsing Logic to match the provided response format
//         final definitionStart = content.indexOf("**Definition:**");
//         final exampleStart = content.indexOf("**Example Sentence:**");

//         String? definition;
//         String? exampleSentence;

//         if (definitionStart != -1 && exampleStart != -1) {
//           definition = content.substring(
//             definitionStart + "**Definition:**".length,
//             exampleStart,
//           ).trim();

//           exampleSentence = content.substring(
//             exampleStart + "**Example Sentence:**".length,
//           ).trim();

//           if (definition.isNotEmpty && exampleSentence.isNotEmpty) {
//             return Flashcard(
//               word: word,
//               definition: definition,
//               exampleSentence: exampleSentence,
//             );
//           } else {
//             print('Parsed definition or example sentence is empty.');
//           }
//         } else {
//           print('Failed to find the definition or example sentence in the response.');
//         }
//       } else {
//         print('Failed to fetch flashcard. Status code: ${response.statusCode}');
//         print('Response body: ${response.body}');
//       }
//     } catch (e) {
//       print('An error occurred: $e');
//     }
//     return null;
//   }

//   // Method to suggest a list of 20 words using LLM
//   // Future<List<String>> suggestWords() async {
//   //   try {
//   //     final response = await http.post(
//   //       Uri.parse(apiUrl),
//   //       headers: {
//   //         'Content-Type': 'application/json',
//   //         'Authorization': 'Bearer $apiKey',
//   //       },
//   //       body: jsonEncode({
//   //         "model": "gpt-4o-mini", // Use the correct model name
//   //         "messages": [
//   //           {
//   //             "role": "system",
//   //             "content": "You are a helpful assistant."
//   //           },
//   //           {
//   //             "role": "user",
//   //             "content": "Please suggest a list of 20 interesting words for building a vocabulary deck."
//   //           }
//   //         ],
//   //         "max_tokens": 100,
//   //         "temperature": 0.7,
//   //       }),
//   //     );

//   //     if (response.statusCode == 200) {
//   //       final data = jsonDecode(response.body);
//   //       final content = data['choices'][0]['message']['content'].trim();

//   //       // Assuming the LLM returns the words in a comma-separated format
//   //       return content.split(',').map((word) => word.trim()).toList();
//   //     } else {
//   //       print('Failed to fetch word suggestions. Status code: ${response.statusCode}');
//   //       return [];
//   //     }
//   //   } catch (e) {
//   //     print('An error occurred while suggesting words: $e');
//   //     return [];
//   //   }
//   // }

//     // Method to suggest a list of 20 words using LLM
//   Future<List<String>> suggestWords() async {
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $apiKey',
//         },
//         body: jsonEncode({
//           "model": "gpt-4o-mini", // Use the correct model name
//           "messages": [
//             {
//               "role": "system",
//               "content": "You are a helpful assistant."
//             },
//             {
//               "role": "user",
//               "content": "Please suggest a list of 20 interesting words for building a vocabulary deck."
//             }
//           ],
//           "max_tokens": 100,
//           "temperature": 0.7,
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final content = data['choices'][0]['message']['content'].trim();

//         // Assuming the LLM returns the words in a comma-separated format
//         return content.split(',').map((word) => word.trim()).toList();
//       } else {
//         print('Failed to fetch word suggestions. Status code: ${response.statusCode}');
//         return [];
//       }
//     } catch (e) {
//       print('An error occurred while suggesting words: $e');
//       return [];
//     }
//   }

//   // Method to generate flashcards for a list of words using LLM
//   Future<List<Flashcard>> generateFlashcards(List<String> words) async {
//     List<Flashcard> flashcards = [];

//     for (String word in words) {
//       final flashcard = await generateFlashcard(word);
//       if (flashcard != null) {
//         flashcards.add(flashcard);
//       }
//     }

//     return flashcards;
//   }
// }


// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/flashcard.dart';
//
// class LLMService {
//   // final String apiKey = dotenv.env['OPENAI_API_KEY'] ?? ''; // Fetch API key from env
//   final String apiKey = 'sk-proj-MjEDyrrYvhu4gRBcNCmrT3BlbkFJfQdSUtaPPdOyklJ3SGmM';
//   final String apiUrl = 'https://api.openai.com/v1/chat/completions';
//
//   Future<Flashcard?> generateFlashcard(String word) async {
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $apiKey',
//         },
//         body: jsonEncode({
//           "model": "gpt-4o-mini", // Use the correct model name
//           "messages": [
//             {
//               "role": "system",
//               "content": "You are a helpful assistant."
//             },
//             {
//               "role": "user",
//               "content": 'Create a flashcard for the word "$word" with the following details: definition and example sentence.'
//             }
//           ],
//           "max_tokens": 100,
//           "temperature": 0.7,
//         }),
//       );
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final String content = data['choices'][0]['message']['content'].trim();
//
//         final definitionStart = content.indexOf("**Definition:**");
//         final exampleStart = content.indexOf("**Example Sentence:**");
//
//         if (definitionStart != -1 && exampleStart != -1) {
//           final definition = content.substring(
//             definitionStart + "**Definition:**".length,
//             exampleStart,
//           ).trim();
//
//           final exampleSentence = content.substring(
//             exampleStart + "**Example Sentence:**".length,
//           ).trim();
//
//           return Flashcard(
//             word: word,
//             definition: definition,
//             exampleSentence: exampleSentence,
//           );
//         }
//       } else {
//         print('Failed to fetch flashcard. Status code: ${response.statusCode}');
//         print('Response body: ${response.body}');
//       }
//     } catch (e) {
//       print('An error occurred: $e');
//     }
//     return null;
//   }
//
//   Future<List<Flashcard>> generateFlashcards(List<String> words) async {
//     List<Flashcard> flashcards = [];
//
//     for (String word in words) {
//       final flashcard = await generateFlashcard(word);
//       if (flashcard != null) {
//         flashcards.add(flashcard);
//       }
//     }
//
//     return flashcards;
//   }
//
//
//   // Modified suggestWords to accept input
//   Future<List<String>> suggestWords(String input) async {
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $apiKey',
//         },
//         body: jsonEncode({
//           "model": "gpt-4o-mini", // Use the correct model name
//           "messages": [
//             {
//               "role": "system",
//               "content": "You are a helpful assistant."
//             },
//             {
//               "role": "user",
//               "content": "Please suggest a list of 20 interesting words related to \"$input\" for building a vocabulary deck."
//             }
//           ],
//           "max_tokens": 100,
//           "temperature": 0.7,
//         }),
//       );
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final content = data['choices'][0]['message']['content'].trim();
//
//         print('API Response Content: $content');
//
//         final List<String> words = content.split(',').map((word) => word.trim()).toList();
//         print('Suggested Words: $words');
//         return words;
//       } else {
//         print('Failed to fetch word suggestions. Status code: ${response.statusCode}');
//         print('Response Body: ${response.body}');
//         return [];
//       }
//     } catch (e) {
//       print('An error occurred while suggesting words: $e');
//       return [];
//     }
//   }
// }






//   // Method to suggest a list of 20 words using LLM
// Future<List<String>> suggestWords() async {
//   try {
//     final response = await http.post(
//       Uri.parse(apiUrl),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $apiKey',
//       },
//       body: jsonEncode({
//         "model": "gpt-4o-mini", // Use the correct model name
//         "messages": [
//           {
//             "role": "system",
//             "content": "You are a helpful assistant."
//           },
//           {
//             "role": "user",
//             "content": "Please suggest a list of 20 interesting words for building a vocabulary deck."
//           }
//         ],
//         "max_tokens": 100,
//         "temperature": 0.7,
//       }),
//     );
//
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       final content = data['choices'][0]['message']['content'].trim();
//
//       // Assuming the LLM returns the words in a comma-separated format
//       return content.split(',').map((word) => word.trim()).toList();
//     } else {
//       print('Failed to fetch word suggestions. Status code: ${response.statusCode}');
//       return [];
//     }
//   } catch (e) {
//     print('An error occurred while suggesting words: $e');
//     return [];
//   }
// }





import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/flashcard.dart';

class LLMService {
  final String apiKey = 'sk-proj-MjEDyrrYvhu4gRBcNCmrT3BlbkFJfQdSUtaPPdOyklJ3SGmM';
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
          "model": "gpt-4o-2024-08-06",
          "messages": [
            {
              "role": "system",
              "content": "You are a helpful assistant that generates vocabulary flashcards. Respond with the following JSON format: {\"word\": \"<Word>\", \"definition\": \"<Definition>\", \"example_sentence\": \"<Example Sentence>\"}."
            },
            {
              "role": "user",
              "content": 'Create a flashcard for the word "$word".'
            }
          ],
          "response_format": {
            "type": "json_schema",
            "json_schema": {
              "name": "flashcard_generation",
              "schema": {
                "type": "object",
                "properties": {
                  "word": { "type": "string" },
                  "definition": { "type": "string" },
                  "example_sentence": { "type": "string" }
                },
                "required": ["word", "definition", "example_sentence"],
                "additionalProperties": false
              },
              "strict": true
            }
          },
          "max_tokens": 100,
          "temperature": 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('API Response Content: $data'); // Print the entire response

        final String contentString = data['choices'][0]['message']['content'];
        final parsedContent = jsonDecode(contentString);

        final flashcardData = parsedContent['flashcards'][0];

        return Flashcard(

          word: flashcardData['word'],
          definition: flashcardData['definition'],
          exampleSentence: flashcardData['example_sentence'],
        );
      } else {
        print('Failed to fetch flashcard. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
    return null;
  }

  Future<List<Flashcard>> suggestWords(String input) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "gpt-4o-2024-08-06",
          "messages": [
            {
              "role": "system",
              "content": "You are a helpful assistant that generates vocabulary flashcards. Respond with a list of flashcards in JSON format."
            },
            {
              "role": "user",
              "content": "Generate a list of 20 interesting words related to \"$input\" with their definitions and example sentences."
            }
          ],
          "response_format": {
            "type": "json_schema",
            "json_schema": {
              "name": "flashcard_generation",
              "schema": {
                "type": "object",
                "properties": {
                  "flashcards": {
                    "type": "array",
                    "items": {
                      "type": "object",
                      "properties": {
                        "word": { "type": "string" },
                        "definition": { "type": "string" },
                        "example_sentence": { "type": "string" }
                      },
                      "required": ["word", "definition", "example_sentence"],
                      "additionalProperties": false
                    }
                  }
                },
                "required": ["flashcards"],
                "additionalProperties": false
              },
              "strict": true
            }
          },
          "max_tokens": 1000,
          "temperature": 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('API Response Content: $data'); // Print the entire response

        final String contentString = data['choices'][0]['message']['content'];
        final parsedContent = jsonDecode(contentString);

        final flashcardsJson = parsedContent['flashcards'];

        if (flashcardsJson != null) {
          final List<Flashcard> flashcards = flashcardsJson.map<Flashcard>((flashcardJson) {
            return Flashcard(

              word: flashcardJson['word'],
              definition: flashcardJson['definition'],
              exampleSentence: flashcardJson['example_sentence'],
            );
          }).toList();

          print('Generated Flashcards: $flashcards');
          return flashcards;
        } else {
          print('Flashcards key not found in response.');
          return [];
        }
      } else {
        print('Failed to fetch word suggestions. Status code: ${response.statusCode}');
        print('Response Body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('An error occurred while suggesting words: $e');
      return [];
    }
  }
}



