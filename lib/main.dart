import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tracker/firebase_options.dart';
import 'package:tracker/routes/auth.dart';
import 'package:tracker/routes/recipe_tips_screen.dart';
import 'package:tracker/routes/theme_customizations.dart';
import 'package:tracker/routes/user_screen.dart';
import 'routes/add_meal_screen.dart';
import 'routes/home_screen.dart';
import 'routes/inventory_screen.dart';
import 'routes/shopping_screen.dart';
import 'routes/view_expenses_screen.dart';
import 'routes/view_meals_screen.dart';

// Importiamo il modulo che contiene AppColors e saveAllColors
import 'services/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
// Aggiungi il caricamento dei colori
  await AppColors.initialize();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
  } catch (e) {
    print('Errore durante l\'inizializzazione di Firebase: $e');
  }
  initializeDateFormatting();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool _isDarkTheme = false;
  Locale? _locale;
  ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    colorScheme: const ColorScheme.light(
      primary: Color.fromARGB(255, 45, 49, 66),
      onPrimary: Color.fromARGB(255, 234, 232, 255),
      secondary: Colors.orange,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(255, 234, 232, 255),
      foregroundColor: Color.fromARGB(255, 45, 49, 66),
      elevation: 4,
      titleTextStyle: TextStyle(
          color: Color.fromARGB(255, 45, 49, 66),
          fontWeight: FontWeight.bold,
          fontSize: 20),
    ),
    iconTheme: const IconThemeData(color: Color.fromARGB(255, 45, 49, 66)),
    scaffoldBackgroundColor: Colors.white,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 45, 49, 66),
        foregroundColor: const Color.fromARGB(255, 234, 232, 255),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black87),
      titleLarge: TextStyle(color: Colors.blueAccent, fontSize: 20),
    ),
    cardColor: Colors.white,
    dividerColor: Colors.grey,
  );

  ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.deepPurple,
    colorScheme: const ColorScheme.dark(
      primary: Color.fromARGB(255, 97, 3, 3),
      onPrimary: Colors.white,
      secondary: Color.fromARGB(255, 66, 12, 20),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(255, 97, 3, 3),
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    scaffoldBackgroundColor: Colors.black,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 97, 3, 3),
        foregroundColor: Colors.white,
      ),
    ),
    iconTheme: const IconThemeData(color: Color.fromARGB(255, 97, 3, 3)),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
      titleLarge: TextStyle(color: Colors.pinkAccent, fontSize: 20),
    ),
    cardColor: Colors.grey[850],
    dividerColor: Colors.grey[700],
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // Salviamo i colori quando l'app viene sospesa o passa in background
      AppColors.saveAllColors();
    }
  }

  void _toggleTheme() {
    setState(() {
      _isDarkTheme = !_isDarkTheme;
    });
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  void updateLightTheme(ThemeData newTheme) {
    setState(() {
      _lightTheme = newTheme;
    });
  }

  void updateDarkTheme(ThemeData newTheme) {
    setState(() {
      _darkTheme = newTheme;
    });
  }

  bool get isDarkTheme => _isDarkTheme;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tracker App',
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
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
            return HomeScreen(
                toggleTheme: _toggleTheme,
                user: snapshot.data!);
          } else {
            return const AuthPage();
          }
        },
      ),
      routes: {
        '/shopping': (context) => const ShoppingScreen(),
        '/user': (context) => const UserScreen(),
        '/addMeal': (context) => AddMealScreen(),
        '/viewExpenses': (context) => const ViewExpensesScreen(),
        '/inventory': (context) => const InventoryScreen(),
        '/viewMeals': (context) => const ViewMealsScreen(),
        '/recipeTips': (context) => const RecipeTipsScreen(),
        '/themeCustomization': (context) => ThemeCustomizationScreen(
          lightTheme: _lightTheme,
          darkTheme: _darkTheme,
          onLightThemeChanged: updateLightTheme,
          onDarkThemeChanged: updateDarkTheme,
        ),
      },
    );
  }
}
