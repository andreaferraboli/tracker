import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tracker/models/meal_type.dart';

extension MealTypeL18n on MealType {
  String? mealString(BuildContext context) {
    switch (name) {
      case 'Breakfast':
        return AppLocalizations.of(context)?.meal_type_breakfast;
      case 'Lunch':
        return AppLocalizations.of(context)?.meal_type_lunch;
      case 'Dinner':
        return AppLocalizations.of(context)?.meal_type_dinner;
      case 'Snack':
        return AppLocalizations.of(context)?.meal_type_snack;
      default:
        return null;
    }
  }
}
