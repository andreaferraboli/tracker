import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Definizione della classe Category
class Category {
  final String name;
  final String icon;
  final String color;

  Category({required this.icon, required this.color, required this.name});

  static Category fromJson(Map<String, dynamic> category) {
    return Category(
      name: category['nomeCategoria'],
      icon: category['iconaFlutter'],
      color: category['coloreSfondo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nomeCategoria': name,
      'iconaFlutter': icon,
      'coloreSfondo': color,
    };
  }
}

// Definizione del provider per le categorie
final categoriesProvider =
    StateNotifierProvider<CategoriesNotifier, List<Category>>((ref) {
  return CategoriesNotifier();
});

// Definizione della classe CategoriesNotifier che estende StateNotifier
class CategoriesNotifier extends StateNotifier<List<Category>> {
  CategoriesNotifier() : super([]);

// Metodo per caricare un array di categorie
  void loadCategories(List<Category> categories) {
    state = categories;
    _syncToFirebase();
  }

  // Metodo per aggiungere una categoria
  void addCategory(Category category) {
    state = [...state, category];
    _syncToFirebase();
  }
// Metodo per esportare le categorie in formato JSON
Future<String> getCategoriesAsJson() async {
  final categoriesJson = state.map((category) => {
    'nomeCategoria': category.name,
    'iconaFlutter': category.icon,
    'coloreSfondo': category.color,
  }).toList();
  return jsonEncode(categoriesJson);
}
  // Metodo per rimuovere una categoria
  void removeCategory(String categoryName) {
    state = state.where((category) => category.name != categoryName).toList();
    _syncToFirebase();
  }

  String exportToJson() {
    final List<Map<String, dynamic>> jsonList = state.map((category) => category.toJson()).toList();
    return json.encode(jsonList);
  }

  void importFromJson(String jsonString) {
    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      final List<Category> categories = jsonList
          .map((json) => Category.fromJson(json))
          .toList();
      state = categories;
      _syncToFirebase();
    } catch (e) {
      print('Error importing categories from JSON: $e');
    }
  }

  Future<void> _syncToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('categories')
            .doc(user.uid)
            .set({
          'categories': state.map((category) => category.toJson()).toList(),
        });
      } catch (e) {
        print('Error syncing categories to Firebase: $e');
      }
    }
  }

  Future<void> fetchCategories() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('categories')
            .doc(user.uid)
            .get();

        if (snapshot.exists && snapshot.data() != null) {
          final data = snapshot.data()!;
          if (data['categories'] != null) {
            final List<dynamic> categoriesData = data['categories'];
            final categories = categoriesData
                .map((category) => Category.fromJson(category))
                .toList();
            state = categories;
          }
        }
      } catch (e) {
        print('Error fetching categories: $e');
      }
    }
  }
}
