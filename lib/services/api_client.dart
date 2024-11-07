import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

import 'category_services.dart';

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

  static Future<Widget> getImageWithRemovedBackground(
      String imageUrl, String category) async {
    final imageBytes = await removeBackground(imageUrl);
    if (imageBytes != null) {
      return Image.memory(imageBytes, width: 100, height: 100);
    } else {
      return await _processAndUploadImage(imageUrl, category);
    }
  }

  static Future<Widget> _processAndUploadImage(
      String imageUrl, String category) async {
    try {
      // Scarica l'immagine
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        return CategoryServices.iconFromCategory(category);
      }

      final imageBytes = response.bodyBytes;
      final image = img.decodeImage(imageBytes);

      if (image == null) {
        return CategoryServices.iconFromCategory(category);
      }

      // Modifica i pixel dell'immagine
      // Processa dal bordo sinistro verso destra
      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);
          if (isWhite(pixel as int)) {
            // image.setPixel(x, y, const Color.fromARGB(0, 255, 255, 255) as img.Color);
          } else {
            break; // Ferma quando trova un pixel non bianco
          }
        }
      }

      // Processa dal bordo destro verso sinistra
      for (int y = 0; y < image.height; y++) {
        for (int x = image.width - 1; x >= 0; x--) {
          final pixel = image.getPixel(x, y);
          if (isWhite(pixel as int)) {
            // image.setPixel(x, y, const Color.fromARGB(0, 255, 255, 255) as img.Color);
          } else {
            break;
          }
        }
      }

      // Processa dal bordo superiore verso il basso
      for (int x = 0; x < image.width; x++) {
        for (int y = 0; y < image.height; y++) {
          final pixel = image.getPixel(x, y);
          if (isWhite(pixel as int)) {
            // image.setPixel(x, y, const Color.fromARGB(0, 255, 255, 255) as img.Color);
          } else {
            break;
          }
        }
      }

      // Processa dal bordo inferiore verso l'alto
      for (int x = 0; x < image.width; x++) {
        for (int y = image.height - 1; y >= 0; y--) {
          final pixel = image.getPixel(x, y);
          if (isWhite(pixel as int)) {
            // image.setPixel(x, y, const Color.fromARGB(0, 255, 255, 255) as img.Color);
          } else {
            break;
          }
        }
      }

      // Codifica l'immagine modificata
      final modifiedImageBytes = Uint8List.fromList(img.encodePng(image));

      // Carica l'immagine su Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('images/${DateTime.now().millisecondsSinceEpoch}.png');
      final uploadTask = storageRef.putData(modifiedImageBytes);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Ritorna l'immagine con l'URL aggiornato
      return Image.network(
        downloadUrl,
        width: 100,
        height: 100,
        errorBuilder: (context, error, stackTrace) {
          return CategoryServices.iconFromCategory(category);
        },
      );
    } catch (e) {
      // In caso di errore, ritorna l'icona della categoria
      print('Error occurred while processing and uploading image: $e');
      return CategoryServices.iconFromCategory(category);
    }
  }

// Funzione helper per verificare se un pixel è bianco
  // Funzione per verificare se il pixel è bianco
  static bool isWhite(int pixel) {
    // Estrai i valori dei canali di colore usando operazioni bitwise
    final r = (pixel >> 24) & 0xFF; // Estrai il canale rosso
    final g = (pixel >> 16) & 0xFF; // Estrai il canale verde
    final b = (pixel >> 8) & 0xFF; // Estrai il canale blu
    final a = pixel & 0xFF; // Estrai il canale alpha (trasparenza)

    // Controlla se il pixel è bianco (RGB: 255, 255, 255) e opaco (A: 255)
    return r == 255 && g == 255 && b == 255 && a == 255;
  }
}
