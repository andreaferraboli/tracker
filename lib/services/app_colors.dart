import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppColors {

  static var shoppingLight = Color.fromARGB(255, 34, 65, 98);
  static var shoppingDark = Color.fromARGB(255, 41, 36, 36);

  static var addMealLight = Color.fromARGB(255, 97, 3, 3);
  static var addMealDark = Color.fromARGB(255, 97, 3, 3);

  static var viewExpensesLight = Color.fromARGB(255, 89, 100, 117);
  static var viewExpensesDark = Color.fromARGB(255, 100, 100, 100);

  static var inventoryLight = Color.fromARGB(255, 0, 126, 167);
  static var inventoryDark = Color.fromARGB(255, 150, 150, 150);

  static var viewMealsLight = Color.fromARGB(255, 45, 49, 66);
  static var viewMealsDark = Color.fromARGB(255, 50, 50, 50);

  static var recipeTipsLight = Color.fromARGB(255, 66, 12, 20);
  static var recipeTipsDark = Color.fromARGB(255, 66, 12, 20);
  // Blocco statico che carica i colori non appena la classe viene utilizzata per la prima volta
  static Future<void> initialize() async {
    await loadAllColors();
  }
  // Salva un colore in memoria
  static Future<void> saveColor(String key, Color color) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, color.value);
  }

  // Carica un colore dalla memoria
  static Future<Color> loadColor(String key, Color defaultColor) async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt(key);
    return colorValue != null ? Color(colorValue) : defaultColor;
  }

  // Metodo per salvare tutti i colori
  static Future<void> saveAllColors() async {
    await saveColor('shoppingLight', shoppingLight);
    await saveColor('shoppingDark', shoppingDark);
    await saveColor('addMealLight', addMealLight);
    await saveColor('addMealDark', addMealDark);
    await saveColor('viewExpensesLight', viewExpensesLight);
    await saveColor('viewExpensesDark', viewExpensesDark);
    await saveColor('inventoryLight', inventoryLight);
    await saveColor('inventoryDark', inventoryDark);
    await saveColor('viewMealsLight', viewMealsLight);
    await saveColor('viewMealsDark', viewMealsDark);
    await saveColor('recipeTipsLight', recipeTipsLight);
    await saveColor('recipeTipsDark', recipeTipsDark);
  }

  // Metodo per caricare tutti i colori
  static Future<void> loadAllColors() async {
    shoppingLight = await loadColor('shoppingLight', shoppingLight);
    shoppingDark = await loadColor('shoppingDark', shoppingDark);
    addMealLight = await loadColor('addMealLight', addMealLight);
    addMealDark = await loadColor('addMealDark', addMealDark);
    viewExpensesLight = await loadColor('viewExpensesLight', viewExpensesLight);
    viewExpensesDark = await loadColor('viewExpensesDark', viewExpensesDark);
    inventoryLight = await loadColor('inventoryLight', inventoryLight);
    inventoryDark = await loadColor('inventoryDark', inventoryDark);
    viewMealsLight = await loadColor('viewMealsLight', viewMealsLight);
    viewMealsDark = await loadColor('viewMealsDark', viewMealsDark);
    recipeTipsLight = await loadColor('recipeTipsLight', recipeTipsLight);
    recipeTipsDark = await loadColor('recipeTipsDark', recipeTipsDark);
  }
}
