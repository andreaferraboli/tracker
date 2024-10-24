import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class ApiClient {
  static final String apiKey = 'tyqPYQx9H98UiewRiqV8fGtw';

  static Future<Uint8List?> removeBackground(String imageUrl) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.remove.bg/v1.0/removebg'),
      );

      // Add headers
      request.headers['X-API-Key'] = apiKey;

      // Add form data (image URL and size)
      request.fields['image_url'] = imageUrl;
      request.fields['size'] = 'auto';

      // Send the request
      var response = await request.send();

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Read the response bytes (image with background removed)
        final imageBytes = await response.stream.toBytes();
        return imageBytes;
      } else {
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error occurred while removing background: $e');
      return null;
    }
  }

  static Future<Widget> getImageWithRemovedBackground(String imageUrl) async {
    final imageBytes = await removeBackground(imageUrl);
    if (imageBytes != null) {
      return Image.memory(imageBytes, width: 100, height: 100);
    } else {
      return const Text('Error removing background');
    }
  }
}
