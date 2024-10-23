import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hugeicons/hugeicons.dart';

class CategoryServices {
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

  //funzione che ritorna il json delle categorie
  static List<dynamic>? getCategoriesData() {
    return _categoriesData;
  }
  static Future<List?> getAndLoadCategoriesData() async {
    await loadCategoriesData();
    return _categoriesData;
  }
  static Future<List<String>> getCategoryNames() async {
    await loadCategoriesData();
    List<String> categoryNames = [];
    for (var category in _categoriesData!) {
      categoryNames.add(category['nomeCategoria']);
    }
    return categoryNames;
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
            return const CircularProgressIndicator(); // Indicatore di caricamento
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
        width: 50.0, // Larghezza del contenitore
        height: 50.0, // Altezza del contenitore
        decoration: BoxDecoration(
          color: _hexToColor(colorHex), // Converti il colore da hex
          shape: BoxShape.circle, // Forma circolare
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Ottieni la dimensione massima disponibile per l'icona
            double maxIconSize = constraints.biggest.width *
                0.6; // Adatta l'icona al 60% del contenitore

            return Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double maxIconSize = constraints.biggest.width *
                      0.6; // Adatta l'icona al 60% del contenitore
                  return Icon(
                    _getFlutterIcon(iconName), // Ottieni l'icona Flutter
                    color: _isDarkColor(colorHex) ? Colors.white : Colors.black,
                    size: maxIconSize, // Dimensione automatica dell'icona
                  );
                },
              ),
            );
          },
        ),
      );
    } else {
      return Container(
        width: 50.0, // Aumenta la larghezza del contenitore
        height: 50.0, // Aumenta l'altezza del contenitore
        decoration: const BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle, // Forma circolare
        ),
        child: const Center(
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

  // Helper per determinare se un colore è scuro
  static bool _isDarkColor(String hexColor) {
    final color = _hexToColor(hexColor);
    final brightness = color.computeLuminance();
    return brightness < 0.5;
  }

  // Helper per ottenere l'icona Flutter dal nome dell'icona
  static IconData _getFlutterIcon(String iconName) {
    switch (iconName) {
      case 'drinks':
        return FontAwesomeIcons.bottleWater;
      case 'vegetables':
        return FontAwesomeIcons.carrot;
      case 'legumes':
        return Icons.spa;
      case 'fruit':
        return Icons.apple;
      case 'dairy_products':
        return HugeIcons.strokeRoundedCheese;
      case 'pasta':
        return FontAwesomeIcons.wheatAwn;
      case 'meat':
        return HugeIcons.strokeRoundedChickenThighs;
      case 'fish':
        return FontAwesomeIcons.fish;
      case 'water':
        return Icons.water_drop;
      case 'dessert':
        return FontAwesomeIcons.cookieBite;
      default:
        return Icons.category; // Icona di default
    }
  }
}
