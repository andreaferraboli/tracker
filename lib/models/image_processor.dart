import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

class ImageProcessor extends StatefulWidget {
  final String imageUrl;

  const ImageProcessor({super.key, required this.imageUrl});

  @override
  _ImageProcessorState createState() => _ImageProcessorState();
}

class _ImageProcessorState extends State<ImageProcessor> {
  Uint8List? _processedImage;

  @override
  void initState() {
    super.initState();
    _removeWhiteBackground();
  }

  Future<void> _removeWhiteBackground() async {
    // Carica l'immagine dalla rete
    final response = await http.get(Uri.parse(widget.imageUrl));

    if (response.statusCode == 200) {
      // Decodifica l'immagine
      final originalImage = img.decodeImage(response.bodyBytes);

      if (originalImage != null) {
        // Processa l'immagine per rimuovere lo sfondo bianco
        final processedImage = _processImage(originalImage);

        // Converte l'immagine in byte per visualizzarla
        final pngBytes = Uint8List.fromList(img.encodePng(processedImage));

        // Aggiorna l'interfaccia utente
        setState(() {
          _processedImage = pngBytes;
        });
      }
    }
  }

  img.Image _processImage(img.Image srcImage) {
    // Ottiene i pixel dell'immagine
    var pixels = srcImage.getBytes();

    // Itera su ogni pixel e sostituisce il bianco con trasparenza
    for (int i = 0; i < pixels.length; i += 4) {
      final r = pixels[i];
      final g = pixels[i + 1];
      final b = pixels[i + 2];

      // Verifica se il pixel è bianco (255, 255, 255)
      if (r == 255 && g == 255 && b == 255) {
        // Imposta l'alpha a 0 (trasparente)
        pixels[i + 3] = 0;
      }
    }

    return srcImage;
  }

  @override
  Widget build(BuildContext context) {
    return _processedImage == null
        ? const CircularProgressIndicator()
        : Image.memory(_processedImage!);
  }
}
