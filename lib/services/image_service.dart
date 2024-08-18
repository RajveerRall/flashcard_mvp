import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageService {
  final String apiKey = 'sk-proj-MjEDyrrYvhu4gRBcNCmrT3BlbkFJfQdSUtaPPdOyklJ3SGmM';
  final String apiUrl = 'https://api.openai.com/v1/images/generations';

  Future<String?> generateImage(String word, String definition) async {
    String prompt = 'A visual representation of the word "$word" and "$definition".';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'dall-e-3',
          'prompt': prompt,
          'n': 1,
          'size': '1024x1024',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final imageUrl = data['data'][0]['url'];

        // Download the image and save it locally
        return await _downloadImage(imageUrl, word);
      } else {
        print('Failed to generate image: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error generating image: $e');
      return null;
    }
  }

  Future<String?> _downloadImage(String imageUrl, String word) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final sanitizedWord = word.replaceAll(RegExp(r'[^\w\s]'), '').replaceAll(' ', '_');
        final filePath = path.join(directory.path, '$sanitizedWord.jpg');
        final file = File(filePath);

        await file.writeAsBytes(response.bodyBytes);
        return filePath; // Return the local file path
      } else {
        print('Failed to download image: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('An error occurred while downloading the image: $e');
      return null;
    }
  }
}
