import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  }

  // Metodo per aggiungere una categoria
  void addCategory(Category category) {
    state = [...state, category];
  }

  // Metodo per rimuovere una categoria
  void removeCategory(String categoryName) {
    state = state.where((category) => category.name != categoryName).toList();
  }
}
