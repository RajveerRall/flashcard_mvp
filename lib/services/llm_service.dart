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