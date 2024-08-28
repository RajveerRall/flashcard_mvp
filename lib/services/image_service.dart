import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageService {
  final String apiKey = 'key-2vkcZXFZbGvVvKqP8eu2MzJlxw8bZx6SnONHtyZ8YG0SmpIz4YQFb1SIMo2dqk1FnCqb9DrkhgDlJoNU16Zb43OLA9RPXRZe';
  final String apiUrl = 'https://api.getimg.ai/v1/stable-diffusion-xl/text-to-image';

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
          'prompt': prompt,
          'model': 'stable-diffusion-xl-v1-0',
          'width': 1024,
          'height': 1024,
          'steps': 30,
          'guidance': 7.5,
          'output_format': 'jpeg',
          'response_format': 'url', // Request the image as a URL
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('API Response: $data'); // Print the response for debugging

        String? imageUrl;
        if (data['image'] != null && data['image']['url'] != null) {
          imageUrl = data['image']['url'];
        } else if (data['url'] != null) {
          imageUrl = data['url'];
        } else {
          print('Image URL not found in the response');
          return null;
        }

        if (imageUrl != null) {
          // Download the image
          final imageResponse = await http.get(Uri.parse(imageUrl));

          if (imageResponse.statusCode == 200) {
            // Get the application's documents directory
            final directory = await getApplicationDocumentsDirectory();

            // Generate a unique file name
            final fileName = '${word.replaceAll(RegExp(r'[^\w\s]'), '_')}.jpg';

            // Save the image to the local file system
            final filePath = path.join(directory.path, fileName);
            final imageFile = File(filePath);
            await imageFile.writeAsBytes(imageResponse.bodyBytes);

            // Return the local file path
            return filePath;
          } else {
            print('Failed to download image: ${imageResponse.statusCode}');
            return null;
          }
        } else {
          print('Image URL is null');
          return null;
        }
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
}


// import 'dart:convert';
// import 'dart:io';
// import 'dart:math';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' as path;
//
// enum ImageAPI {
//   GetimgAI,
//   StabilityAI,
// }
//
// class ImageService {
//   final String getimgApiKey = 'key-2vkcZXFZbGvVvKqP8eu2MzJlxw8bZx6SnONHtyZ8YG0SmpIz4YQFb1SIMo2dqk1FnCqb9DrkhgDlJoNU16Zb43OLA9RPXRZe';
//   final String stabilityApiKey = 'sk-nnzeK5uVDbT0jE5sHDjfo6xj9IxQus3GR2dSjHwwCOR9WkCf';
//   final ImageAPI selectedAPI;
//
//   ImageService({required this.selectedAPI});
//
//   Future<String?> generateImage(String word, String definition) async {
//     switch (selectedAPI) {
//       case ImageAPI.GetimgAI:
//         return _generateImageWithGetimgAI(word, definition);
//       case ImageAPI.StabilityAI:
//         return _generateImageWithStabilityAI(word, definition);
//       default:
//         return null;
//     }
//   }
//
//   Future<String?> _generateImageWithGetimgAI(String word, String definition) async {
//     String prompt = 'A visual representation of the word "$word" and "$definition".';
//     final String apiUrl = 'https://api.getimg.ai/v1/stable-diffusion-xl/text-to-image';
//
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {
//           'Authorization': 'Bearer $getimgApiKey',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           'prompt': prompt,
//           'model': 'stable-diffusion-xl-v1-0',
//           'width': 1024,
//           'height': 1024,
//           'steps': 30,
//           'guidance': 7.5,
//           'output_format': 'jpeg',
//           'response_format': 'url',
//         }),
//       );
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         String? imageUrl = data['url'];
//
//         if (imageUrl != null) {
//           return await _downloadAndSaveImage(imageUrl, word);
//         } else {
//           print('Image URL is null');
//           return null;
//         }
//       } else {
//         print('Failed to generate image: ${response.statusCode}');
//         print('Response body: ${response.body}');
//         return null;
//       }
//     } catch (e) {
//       print('Error generating image with Getimg.ai: $e');
//       return null;
//     }
//   }
//
//   Future<String?> _generateImageWithStabilityAI(String word, String definition) async {
//     String prompt = 'A visual representation of the word "$word" and "$definition".';
//     final String apiUrl = 'https://api.fireworks.ai/v1/generate';
//
//     try {
//       var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
//       request.headers['Authorization'] = 'Bearer $stabilityApiKey';
//       request.headers['Accept'] = 'application/json';
//       request.fields['prompt'] = prompt;
//       request.fields['model'] = 'sd3-medium'; // Example: sd3-large, sd3-large-turbo, etc.
//       request.fields['output_format'] = 'jpeg';
//
//       var response = await request.send();
//       var responseBody = await http.Response.fromStream(response);
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(responseBody.body);
//         final imageBase64 = data['image'];
//
//         if (imageBase64 != null) {
//           return await _saveBase64Image(imageBase64, word);
//         } else {
//           print('Base64 image data is null');
//           return null;
//         }
//       } else {
//         print('Failed to generate image: ${response.statusCode}');
//         print('Response body: ${responseBody.body}');
//         return null;
//       }
//     } catch (e) {
//       print('Error generating image with Stability AI: $e');
//       return null;
//     }
//   }
//
//   Future<String?> _downloadAndSaveImage(String imageUrl, String word) async {
//     try {
//       final imageResponse = await http.get(Uri.parse(imageUrl));
//
//       if (imageResponse.statusCode == 200) {
//         final directory = await getApplicationDocumentsDirectory();
//         final fileName = '${word.replaceAll(RegExp(r'[^\w\s]'), '_')}.jpg';
//         final filePath = path.join(directory.path, fileName);
//         final imageFile = File(filePath);
//         await imageFile.writeAsBytes(imageResponse.bodyBytes);
//         return filePath;
//       } else {
//         print('Failed to download image: ${imageResponse.statusCode}');
//         return null;
//       }
//     } catch (e) {
//       print('Error downloading image: $e');
//       return null;
//     }
//   }
//
//   Future<String?> _saveBase64Image(String base64Image, String word) async {
//     try {
//       final directory = await getApplicationDocumentsDirectory();
//       final fileName = '${word.replaceAll(RegExp(r'[^\w\s]'), '_')}.jpeg';
//       final filePath = path.join(directory.path, fileName);
//       final imageFile = File(filePath);
//       await imageFile.writeAsBytes(base64Decode(base64Image));
//       return filePath;
//     } catch (e) {
//       print('Error saving image: $e');
//       return null;
//     }
//   }
// }
