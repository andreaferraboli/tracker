
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final categoriesProvider = StateNotifierProvider<categoriesNotifier, List<Category>>((ref) {
  return categoriesNotifier();
});

class categoriesNotifier extends StateNotifier<List<Category>> {
  categoriesNotifier() : super([]);

  void setCategories(List<Category>? categories) {
    state = categories!;
  }
}