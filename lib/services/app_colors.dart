import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppColors {
  static Color primaryLight = const Color.fromARGB(255, 45, 49, 66);
  static Color onPrimaryLight = const Color.fromARGB(255, 234, 232, 255);
  static Color secondaryLight = Colors.orange;
  static Color appBarBackgroundLight = const Color.fromARGB(255, 234, 232, 255);
  static Color appBarForegroundLight = const Color.fromARGB(255, 45, 49, 66);
  static Color primaryDark = const Color.fromARGB(255, 97, 3, 3);
  static Color onPrimaryDark = Colors.white;
  static Color secondaryDark = const Color.fromARGB(255, 66, 12, 20);
  static Color appBarBackgroundDark = const Color.fromARGB(255, 97, 3, 3);
  static Color appBarForegroundDark = Colors.white;
  static var shoppingLight = const Color.fromARGB(255, 34, 65, 98);
  static var shoppingDark = const Color.fromARGB(255, 41, 36, 36);

  static var addMealLight = const Color.fromARGB(255, 97, 3, 3);
  static var addMealDark = const Color.fromARGB(255, 97, 3, 3);

  static var viewExpensesLight = const Color.fromARGB(255, 89, 100, 117);
  static var viewExpensesDark = const Color.fromARGB(255, 100, 100, 100);

  static var inventoryLight = const Color.fromARGB(255, 0, 126, 167);
  static var inventoryDark = const Color.fromARGB(255, 150, 150, 150);

  static var viewMealsLight = const Color.fromARGB(255, 45, 49, 66);
  static var viewMealsDark = const Color.fromARGB(255, 50, 50, 50);

  static var recipeTipsLight = const Color.fromARGB(255, 66, 12, 20);
  static var recipeTipsDark = const Color.fromARGB(255, 66, 12, 20);

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

// Metodo per resettare tutti i colori ai valori originali
  static Future<void> resetAllColors() async {
    primaryLight = const Color.fromARGB(255, 45, 49, 66);
    onPrimaryLight = const Color.fromARGB(255, 234, 232, 255);
    secondaryLight = Colors.orange;
    appBarBackgroundLight = const Color.fromARGB(255, 234, 232, 255);
    appBarForegroundLight = const Color.fromARGB(255, 45, 49, 66);
    primaryDark = const Color.fromARGB(255, 97, 3, 3);
    onPrimaryDark = Colors.white;
    secondaryDark = const Color.fromARGB(255, 66, 12, 20);
    appBarBackgroundDark = const Color.fromARGB(255, 97, 3, 3);
    appBarForegroundDark = Colors.white;
    shoppingLight = const Color.fromARGB(255, 34, 65, 98);
    shoppingDark = const Color.fromARGB(255, 41, 36, 36);
    addMealLight = const Color.fromARGB(255, 97, 3, 3);
    addMealDark = const Color.fromARGB(255, 97, 3, 3);
    viewExpensesLight = const Color.fromARGB(255, 89, 100, 117);
    viewExpensesDark = const Color.fromARGB(255, 100, 100, 100);
    inventoryLight = const Color.fromARGB(255, 0, 126, 167);
    inventoryDark = const Color.fromARGB(255, 150, 150, 150);
    viewMealsLight = const Color.fromARGB(255, 45, 49, 66);
    viewMealsDark = const Color.fromARGB(255, 50, 50, 50);
    recipeTipsLight = const Color.fromARGB(255, 66, 12, 20);
    recipeTipsDark = const Color.fromARGB(255, 66, 12, 20);
    await saveAllColors();
  }

  // Metodo per salvare tutti i colori
  static Future<void> saveAllColors() async {
    await saveColor('primaryLight', primaryLight);
    await saveColor('onPrimaryLight', onPrimaryLight);
    await saveColor('secondaryLight', secondaryLight);
    await saveColor('appBarBackgroundLight', appBarBackgroundLight);
    await saveColor('appBarForegroundLight', appBarForegroundLight);
    await saveColor('primaryDark', primaryDark);
    await saveColor('onPrimaryDark', onPrimaryDark);
    await saveColor('secondaryDark', secondaryDark);
    await saveColor('appBarBackgroundDark', appBarBackgroundDark);
    await saveColor('appBarForegroundDark', appBarForegroundDark);
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
    primaryLight = await loadColor('primaryLight', primaryLight);
    onPrimaryLight = await loadColor('onPrimaryLight', onPrimaryLight);
    secondaryLight = await loadColor('secondaryLight', secondaryLight);
    appBarBackgroundLight =
        await loadColor('appBarBackgroundLight', appBarBackgroundLight);
    appBarForegroundLight =
        await loadColor('appBarForegroundLight', appBarForegroundLight);
    primaryDark = await loadColor('primaryDark', primaryDark);
    onPrimaryDark = await loadColor('onPrimaryDark', onPrimaryDark);
    secondaryDark = await loadColor('secondaryDark', secondaryDark);
    appBarBackgroundDark =
        await loadColor('appBarBackgroundDark', appBarBackgroundDark);
    appBarForegroundDark =
        await loadColor('appBarForegroundDark', appBarForegroundDark);
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
