import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class TTSService {
  final String apiKey = 'sk-proj-MjEDyrrYvhu4gRBcNCmrT3BlbkFJfQdSUtaPPdOyklJ3SGmM'; // Replace with your OpenAI API key
  final String apiUrl = 'https://api.openai.com/v1/audio/speech';

  Future<String?> generateSpeech(String word) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: '''{
          "model": "tts-1",
          "input": "$word",
          "voice": "alloy"
        }''',
      );

      if (response.statusCode == 200) {
        // Save the response as an MP3 file named after the word
        final directory = await getApplicationDocumentsDirectory();
        final sanitizedWord = word.replaceAll(RegExp(r'[^\w\s]'), '').replaceAll(' ', '_'); // Remove invalid filename characters
        final filePath = path.join(directory.path, '$sanitizedWord.mp3');
        final file = File(filePath);

        // Write to the file and ensure it's closed properly
        final raf = file.openSync(mode: FileMode.write);
        raf.writeFromSync(response.bodyBytes);
        await raf.close();

        return filePath;
      } else {
        print('Failed to generate speech. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('An error occurred: $e');
      return null;
    }
  }
}