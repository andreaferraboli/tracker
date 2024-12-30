import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

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

  Future<String> getMealsAsJson() async {
    final meals = state;
    final mealsJson = meals.map((meal) => meal.toJson()).toList();
    return jsonEncode(mealsJson);
  }
  Future<void> postMeals(mealsJson) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    try {
      await FirebaseFirestore.instance
          .collection('meals')
          .doc(user.uid)
          .set({'meals': jsonDecode(mealsJson)});
    } catch (e) {
      // Handle error
      print('Error posting meals: $e');
    }
  }
}
}

final mealsProvider = StateNotifierProvider<MealsNotifier, List<Meal>>((ref) {
  return MealsNotifier();
});
