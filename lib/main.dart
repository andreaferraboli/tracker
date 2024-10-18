import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tracker/firebase_options.dart';
import 'package:tracker/routes/auth.dart';
import 'package:tracker/routes/recipe_tips_screen.dart';
import 'package:tracker/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/routes/user_screen.dart';
import 'routes/home_screen.dart';
import 'routes/shopping_screen.dart';
import 'routes/add_meal_screen.dart';
import 'routes/view_expenses_screen.dart';
import 'routes/inventory_screen.dart';
import 'routes/view_meals_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Aggiunto controllo degli errori per Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
  } catch (e) {
    // Log dell'errore o altre azioni di gestione dell'errore
    print('Errore durante l\'inizializzazione di Firebase: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkTheme = false;

  // Cambiato il metodo _toggleTheme per poter essere passato alla HomeScreen
  void _toggleTheme() {
    setState(() {
      _isDarkTheme = !_isDarkTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping App',
      debugShowCheckedModeBanner: false,
      theme: _isDarkTheme ? _darkTheme : _lightTheme,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData) {
            return HomeScreen(toggleTheme: _toggleTheme, user: snapshot.data!); // Aggiunto il toggleTheme e lo user
          } else {
            return const AuthPage();
          }
        },
      ),
      routes: {
        '/shopping': (context) => const ShoppingScreen(),
        '/user': (context) => UserScreen(),
        '/addMeal': (context) => const AddMealScreen(),
        '/viewExpenses': (context) => const ViewExpensesScreen(),
        '/inventory': (context) => const InventoryScreen(),
        '/viewMeals': (context) => const ViewMealsScreen(),
        '/recipeTips': (context) => const RecipeTipsScreen(),
      },
    );
  }
}

final ThemeData _lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.blue,
  colorScheme: const ColorScheme.light(
    primary: Colors.blue,
    secondary: Colors.orange,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
    elevation: 4,
  ),
  scaffoldBackgroundColor: Colors.white,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black),
    bodyMedium: TextStyle(color: Colors.black87),
    titleLarge: TextStyle(color: Colors.blueAccent, fontSize: 20),
  ),
  cardColor: Colors.grey[100],
  dividerColor: Colors.grey,
  iconTheme: const IconThemeData(color: Colors.blue),
);

final ThemeData _darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.deepPurple,
  colorScheme: const ColorScheme.dark(
    primary: Colors.deepPurple,
    secondary: Colors.pinkAccent,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.deepPurple,
    foregroundColor: Colors.white,
    elevation: 4,
  ),
  scaffoldBackgroundColor: Colors.black,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white70),
    titleLarge: TextStyle(color: Colors.pinkAccent, fontSize: 20),
  ),
  cardColor: Colors.grey[850],
  dividerColor: Colors.grey[700],
  iconTheme: const IconThemeData(color: Colors.pinkAccent),
);