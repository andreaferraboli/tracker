import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/meal.dart';

class MealsNotifier extends StateNotifier<List<Meal>> {
  MealsNotifier() : super([]);

  void loadMeals(List<Meal> meals) {
    state = meals;
  }

  void addMeal(Meal meal) {
    state = [...state, meal];
  }

  void removeMeal(Meal meal) {
    state = state.where((m) => m.id != meal.id).toList();
  }
}

final mealsProvider = StateNotifierProvider<MealsNotifier, List<Meal>>((ref) {
  return MealsNotifier();
});
