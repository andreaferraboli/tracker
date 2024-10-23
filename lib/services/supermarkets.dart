import 'package:flutter/material.dart';
class Supermarkets {
  static Future<Image> getSupermarketImage(String supermarket) async{
    return  Image.asset(
      'assets/images/$supermarket.png', // Carica l'immagine del supermercato
      height: 80, // Altezza dell'immagine
      fit: BoxFit.cover, // Adatta l'immagine nel riquadro
    );
  }
}