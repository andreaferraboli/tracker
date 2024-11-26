import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

class ImageProcessor extends StatefulWidget {
  final String imageUrl;

  const ImageProcessor({super.key, required this.imageUrl});

  @override
  _ImageProcessorState createState() => _ImageProcessorState();

  static Future<Uint8List?> removeWhiteBackground(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        final originalImage =
            img.decodeImage(Uint8List.fromList(response.bodyBytes));

        if (originalImage == null) {
          debugPrint('Errore: Impossibile decodificare l\'immagine.');
          return null;
        }

        final processedImage = _processImage(originalImage);
        return Uint8List.fromList(img.encodePng(processedImage));
      } else {
        debugPrint(
            'Errore nel caricamento dell\'immagine: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Errore durante l\'elaborazione dell\'immagine: $e');
      return null;
    }
  }

  static img.Image _processImage(img.Image srcImage) {
    // Create a new image with alpha channel
    final processedImage = img.Image.from(srcImage);
    
    // Iterate through pixels and make white pixels transparent
    for (int y = 0; y < processedImage.height; y++) {
      for (int x = 0; x < processedImage.width; x++) {
        final pixel = processedImage.getPixel(x, y);
        
        // Get RGB values
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;
        
        // Check if pixel is close to white (with some tolerance)
        if (r > 240 && g > 240 && b > 240) {
          // Set pixel to fully transparent
          processedImage.setPixelRgba(x, y, r, g, b, 0);
        }
      }
    }
    return processedImage;
  }
}

class _ImageProcessorState extends State<ImageProcessor> {
  Uint8List? _processedImage;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Processor'),
      ),
      body: Center(
        child: _processedImage == null
            ? const CircularProgressIndicator()
            : Image.memory(_processedImage!),
      ),
    );
  }
}
