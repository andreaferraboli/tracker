import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tracker/models/meal_type.dart';

extension MealTypeL18n on MealType {
  String mealString(BuildContext context) {
    switch (name) {
      case 'Breakfast':
        return AppLocalizations.of(context)!.meal_type_breakfast;
      case 'Lunch':
        return AppLocalizations.of(context)!.meal_type_lunch;
      case 'Dinner':
        return AppLocalizations.of(context)!.meal_type_dinner;
      case 'Snack':
        return AppLocalizations.of(context)!.meal_type_snack;
      default:
        return name;
    }
  }
}

// Estensione per tradurre le categorie
extension AppLocalizationsExtension on AppLocalizations {
  String translateCategory(String category) {
    switch (category) {
      case 'meat':
        return meat;
      case 'fish':
        return fish;
      case 'pasta_bread_rice':
        return pasta_bread_rice;
      case 'sauces_condiments':
        return sauces_condiments;
      case 'vegetables':
        return vegetables;
      case 'fruit':
        return fruit;
      case 'dairy_products':
        return dairy_products;
      case 'water':
        return water;
      case 'dessert':
        return dessert;
      case 'salty_snacks':
        return salty_snacks;
      case 'drinks':
        return drinks;
      default:
        return category; // Ritorna la stringa originale se non è trovata
    }
  }

  String getNutrientString(String nutrient) {
    switch (nutrient) {
      case 'Energy':
        return energy;
      case 'Fats':
        return fats;
      case 'Proteins':
        return proteins;
      case 'Carbohydrates':
        return carbohydrates;
      case 'Sugars':
        return sugars;
      case 'Fiber':
        return fiber;
      case 'Saturated Fats':
        return saturated_fats;
      case 'Monounsaturated Fats':
        return monounsaturated_fats;
      case 'Polyunsaturated Fats':
        return polyunsaturated_fats;
      case 'Cholesterol':
        return cholesterol;
      case 'Sodium':
        return sodium;
      default:
        return nutrient; // Ritorna la stringa originale se non è trovata
    }
  }

  String getStorageTitle(String storage) {
    switch (storage.toLowerCase()) {
      case 'fridge':
        return fridge;
      case 'pantry':
        return pantry;
      case 'freezer':
        return freezer;
      case 'other':
        return other;
      default:
        return storage; // Return the original string if not found
    }
  }
}
