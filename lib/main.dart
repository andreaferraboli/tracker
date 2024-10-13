import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tracker/firebase_options.dart';
import 'package:tracker/routes/recipe_tips_screen.dart';
import 'routes/home_screen.dart';
import 'routes/shopping_screen.dart';
import 'routes/add_meal_screen.dart';
import 'routes/view_expenses_screen.dart';
import 'routes/inventory_screen.dart';
import 'routes/view_meals_screen.dart';
import 'package:firebase_core/firebase_core.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Variabile per tenere traccia del tema attuale (true = dark mode)
  bool _isDarkTheme = false;

  // Metodo per cambiare tema
  void _toggleTheme() {
    setState(() {
      _isDarkTheme = !_isDarkTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping App',
      debugShowCheckedModeBanner: false, // Rimuove la scritta debug
      theme: _isDarkTheme ? _darkTheme : _lightTheme, // Seleziona il tema
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(toggleTheme: _toggleTheme),
        '/shopping': (context) => const ShoppingScreen(),
        '/addMeal': (context) => const AddMealScreen(),
        '/viewExpenses': (context) => const ViewExpensesScreen(),
        '/inventory': (context) => const InventoryScreen(),
        '/viewMeals': (context) => const ViewMealsScreen(),
        '/recipeTips': (context) => RecipeTipsScreen(),
      },
    );
  }
}
// Definizione del tema chiaro
// Definizione del tema chiaro
final ThemeData _lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.blue, // Serie di tonalità di blu
  colorScheme: const ColorScheme.light(
    primary: Colors.blue, // Colore principale
    secondary: Colors.orange, // Colore secondario
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.blue, // Colore dell'AppBar
    foregroundColor: Colors.white, // Colore del testo nell'AppBar
    elevation: 4, // Ombreggiatura AppBar
  ),
  scaffoldBackgroundColor: Colors.white, // Sfondo delle schermate
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue, // Colore dei pulsanti
      foregroundColor: Colors.white, // Colore del testo dei pulsanti
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black), // Nuovo `bodyText1`
    bodyMedium: TextStyle(color: Colors.black87), // Nuovo `bodyText2`
    titleLarge: TextStyle(color: Colors.blueAccent, fontSize: 20), // Nuovo `headline6`
  ),
  cardColor: Colors.grey[100], // Colore delle card
  dividerColor: Colors.grey, // Colore dei divisori
  iconTheme: const IconThemeData(color: Colors.blue), // Colore delle icone
);

// Definizione del tema scuro
final ThemeData _darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.deepPurple, // Serie di tonalità di viola
  colorScheme: const ColorScheme.dark(
    primary: Colors.deepPurple, // Colore principale
    secondary: Colors.pinkAccent, // Colore secondario
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.deepPurple, // Colore dell'AppBar
    foregroundColor: Colors.white, // Colore del testo nell'AppBar
    elevation: 4, // Ombreggiatura AppBar
  ),
  scaffoldBackgroundColor: Colors.black, // Sfondo delle schermate
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.deepPurple, // Colore dei pulsanti
      foregroundColor: Colors.white, // Colore del testo dei pulsanti
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white), // Nuovo `bodyText1`
    bodyMedium: TextStyle(color: Colors.white70), // Nuovo `bodyText2`
    titleLarge: TextStyle(color: Colors.pinkAccent, fontSize: 20), // Nuovo `headline6`
  ),
  cardColor: Colors.grey[850], // Colore delle card
  dividerColor: Colors.grey[700], // Colore dei divisori
  iconTheme: const IconThemeData(color: Colors.pinkAccent), // Colore delle icone
);












