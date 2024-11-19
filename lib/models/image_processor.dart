import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

class ImageProcessor extends StatefulWidget {
  final String imageUrl;

  const ImageProcessor({super.key, required this.imageUrl});

  @override
  _ImageProcessorState createState() => _ImageProcessorState();

  static Future<Widget> removeWhiteBackground(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        final originalImage =
            img.decodeImage(Uint8List.fromList(response.bodyBytes));

        if (originalImage == null) {
          debugPrint('Errore: Impossibile decodificare l\'immagine.');
          return const SizedBox.shrink();
        }

        if (originalImage != null) {
          final processedImage = _processImage(originalImage);

          final pngBytes = Uint8List.fromList(img.encodePng(processedImage));
          return Container(
            width: 40,
            height: 40,
            child: Image.memory(
              pngBytes,
              fit: BoxFit.cover, // Adatta l'immagine al container
            ),
          );
        } else {
          debugPrint('Impossibile decodificare l\'immagine.');
          return const SizedBox.shrink();
        }
      } else {
        debugPrint(
            'Errore nel caricamento dell\'immagine: ${response.statusCode}');
        return const SizedBox.shrink();
      }
    } catch (e) {
      debugPrint('Errore durante l\'elaborazione dell\'immagine: $e');
      return const SizedBox.shrink();
    }
  }

  static img.Image _processImage(img.Image srcImage) {
    // Itera sui pixel dell'immagine e sostituisce il bianco con trasparenza
    for (int y = 0; y < srcImage.height; y++) {
      for (int x = 0; x < srcImage.width; x++) {
        final pixel = srcImage.getPixel(x, y);

        // Usa i metodi corretti per ottenere i valori RGB
        final r = pixel.r; // Red
        final g = pixel.g; // Green
        final b = pixel.b; // Blue

        // Se il pixel è bianco (255, 255, 255), rende il pixel trasparente
        if (r == 255 && g == 255 && b == 255) {
          srcImage.setPixelRgba(x, y, r, g, b, 0); // Alpha a 0 (trasparenza)
        }
      }
    }
    return srcImage;
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
