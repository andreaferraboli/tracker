import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class CategoryIcon {
  // Mappa per memorizzare i dati delle categorie
  static List<dynamic>? _categoriesData;

  // Metodo sincrono per caricare i dati
  static Future<void> loadCategoriesData() async {
    if (_categoriesData == null) {
      final jsonString =
          await rootBundle.loadString('assets/json/categories.json');
      _categoriesData = json.decode(jsonString);
    }
  }

  // Restituisci l'icona e il colore della categoria dal file JSON
  static Widget iconFromCategory(String categoryName) {
    // Assicuriamoci che i dati siano stati caricati prima di continuare
    if (_categoriesData == null) {
      return FutureBuilder(
        future: loadCategoriesData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return _buildCategoryIcon(categoryName);
          } else {
            return CircularProgressIndicator(); // Indicatore di caricamento
          }
        },
      );
    } else {
      // Se i dati sono già caricati, possiamo restituire direttamente l'icona
      return _buildCategoryIcon(categoryName);
    }
  }

  // Metodo helper per costruire l'icona della categoria
  static Widget _buildCategoryIcon(String categoryName) {
    final category = _categoriesData?.firstWhere(
      (category) => category['nomeCategoria'] == categoryName,
      orElse: () => null,
    );

    if (category != null) {
      final iconName = category['iconaFlutter'];
      final colorHex = category['coloreSfondo'];

      return Container(
        width: 50.0, // Aumenta la larghezza del contenitore
        height: 50.0, // Aumenta l'altezza del contenitore
        decoration: BoxDecoration(
          color: _hexToColor(colorHex), // Converti il colore da hex
          shape: BoxShape.circle, // Forma circolare
        ),
        child: Center(
          child: Icon(
            _getFlutterIcon(iconName), // Ottieni l'icona Flutter
            color: Colors.white,
            size: 30.0, // Dimensione dell'icona
          ),
        ),
      );
    } else {
      return Container(
        width: 50.0, // Aumenta la larghezza del contenitore
        height: 50.0, // Aumenta l'altezza del contenitore
        decoration: BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle, // Forma circolare
        ),
        child: Center(
          child: Icon(
            Icons.category,
            color: Colors.white,
            size: 30.0, // Dimensione dell'icona di default
          ),
        ),
      );
    }
  }

  // Helper per convertire un colore esadecimale in Color
  static Color _hexToColor(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  // Helper per ottenere l'icona Flutter dal nome dell'icona
  static IconData _getFlutterIcon(String iconName) {
    switch (iconName) {
      case 'restaurant_menu':
        return Icons.restaurant_menu;
      case 'local_fish_market':
        return Icons.set_meal_sharp;
      case 'local_dining':
        return Icons.local_dining;
      case 'eco':
        return Icons.eco;
      case 'apple':
        return Icons.apple;
      case 'local_cafe':
        return Icons.local_cafe;
      case 'spa':
        return Icons.spa;
      case 'local_drink':
        return Icons.local_drink;
      case 'cake':
        return Icons.cake;
      case 'local_bar':
        return Icons.local_bar;
      default:
        return Icons.category; // Icona di default
    }
  }
}
