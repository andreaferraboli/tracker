import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  String exportToJson() {
    final List<Map<String, dynamic>> jsonList =
        state.map((meal) => meal.toJson()).toList();
    return json.encode(jsonList);
  }

  void importFromJson(String jsonString) {
    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      final List<Meal> meals =
          jsonList.map((json) => Meal.fromJson(json)).toList();
      state = meals;
      _syncToFirebase();
    } catch (e) {
      print('Error importing meals from JSON: $e');
    }
  }

  Future<void> _syncToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('meals').doc(user.uid).set({
          'meals': state.map((meal) => meal.toJson()).toList(),
        });
      } catch (e) {
        print('Error syncing meals to Firebase: $e');
      }
    }
  }

  Future<void> fetchMeals() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('meals')
            .doc(user.uid)
            .get();

        if (snapshot.exists && snapshot.data() != null) {
          final data = snapshot.data()!;
          if (data['meals'] != null) {
            final List<dynamic> mealsData = data['meals'];
            final meals = mealsData.map((meal) => Meal.fromJson(meal)).toList();
            state = meals;
          }
        }
      } catch (e) {
        print('Error fetching meals: $e');
      }
    }
  }
}

final mealsProvider = StateNotifierProvider<MealsNotifier, List<Meal>>((ref) {
  return MealsNotifier();
});
