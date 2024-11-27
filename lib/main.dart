import 'dart:io'; // Importa per riconoscere la piattaforma
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Per il design iOS
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';
import 'package:tracker/firebase_options.dart';
import 'package:tracker/routes/auth.dart';
import 'package:tracker/routes/filter_recipes_screen.dart';
import 'package:tracker/routes/theme_customizations.dart';
import 'package:tracker/routes/user_screen.dart';
import 'package:tracker/services/toast_notifier.dart';

import 'routes/add_meal_screen.dart';
import 'routes/home_screen.dart';
import 'routes/inventory_screen.dart';
import 'routes/shopping_screen.dart';
import 'routes/view_expenses_screen.dart';
import 'routes/view_meals_screen.dart';
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
    ToastNotifier.showError(
        'Errore durante l\'inizializzazione di Firebase: $e');
  }
  initializeDateFormatting();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    MyAppState? state = context.findAncestorStateOfType<MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool _isDarkTheme = false;
  Locale? _locale;
  static const String _languageKey = 'selected_language';
  static const String _themeKey = 'is_dark_theme';
  ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    colorScheme: ColorScheme.light(
      primary: AppColors.primaryLight,
      onPrimary: AppColors.onPrimaryLight,
      secondary: AppColors.secondaryLight,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.appBarBackgroundLight,
      foregroundColor: AppColors.appBarForegroundLight,
      elevation: 4,
      titleTextStyle: TextStyle(
          color: AppColors.appBarForegroundLight,
          fontWeight: FontWeight.bold,
          fontSize: 20),
    ),
    iconTheme: IconThemeData(color: AppColors.primaryLight),
    scaffoldBackgroundColor: Colors.white,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.onPrimaryLight,
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
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryDark,
      onPrimary: AppColors.onPrimaryDark,
      secondary: AppColors.secondaryDark,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.appBarBackgroundDark,
      foregroundColor: AppColors.appBarForegroundDark,
      elevation: 4,
      titleTextStyle: TextStyle(
          color: AppColors.appBarForegroundDark,
          fontWeight: FontWeight.bold,
          fontSize: 20),
    ),
    scaffoldBackgroundColor: Colors.black,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.onPrimaryDark,
      ),
    ),
    iconTheme: IconThemeData(color: AppColors.primaryDark),
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
    _loadSavedLanguage();
    _loadSavedTheme();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey);
    if (savedLanguage != null) {
      final parts = savedLanguage.split('_');
      if (parts.length == 2) {
        if (!mounted) return;
        setState(() {
          _locale = Locale(parts[0], parts[1]);
        });
      }
    }
  }

  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _isDarkTheme = prefs.getBool(_themeKey) ?? false;
    });
  }

  void setLocale(Locale locale) async {
    if (!mounted) return;
    setState(() {
      _locale = locale;
    });
    // Save the selected language
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _languageKey, '${locale.languageCode}_${locale.countryCode}');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      AppColors.saveAllColors();
    }
  }

  void _toggleTheme() async {
    if (!mounted) return;
    setState(() {
      _isDarkTheme = !_isDarkTheme;
    });
    // Salva la preferenza del tema
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkTheme);
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? ToastificationWrapper(
            child: CupertinoApp(
              title: 'Tracker App',
              locale: _locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              theme: CupertinoThemeData(
                brightness: _isDarkTheme ? Brightness.dark : Brightness.light,
                primaryColor: _isDarkTheme
                    ? AppColors.primaryDark
                    : AppColors.primaryLight,
                barBackgroundColor: _isDarkTheme
                    ? AppColors.appBarBackgroundDark
                    : AppColors.appBarBackgroundLight,
                textTheme: CupertinoTextThemeData(
                  textStyle: TextStyle(
                    color: _isDarkTheme
                        ? AppColors.onPrimaryDark
                        : AppColors.onPrimaryLight,
                  ),
                  navTitleTextStyle: TextStyle(
                    color: _isDarkTheme
                        ? AppColors.appBarForegroundDark
                        : AppColors.appBarForegroundLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  navLargeTitleTextStyle: TextStyle(
                    color: _isDarkTheme
                        ? AppColors.appBarForegroundDark
                        : AppColors.appBarForegroundLight,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              home: StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CupertinoActivityIndicator(),
                    );
                  } else if (snapshot.hasData) {
                    return HomeScreen(
                        toggleTheme: _toggleTheme, user: snapshot.data!);
                  } else {
                    return const AuthPage();
                  }
                },
              ),
              routes: {
                '/home': (context) => HomeScreen(
                      toggleTheme: _toggleTheme,
                    ),
                '/shopping': (context) => const ShoppingScreen(),
                '/user': (context) => const UserScreen(),
                '/addMeal': (context) => const AddMealScreen(),
                '/viewExpenses': (context) => const ViewExpensesScreen(),
                '/inventory': (context) => const InventoryScreen(),
                '/viewMeals': (context) => const ViewMealsScreen(),
                '/recipeTips': (context) => const FilterRecipesScreen(),
                '/themeCustomization': (context) => ThemeCustomizationScreen(
                      lightTheme: _lightTheme,
                      darkTheme: _darkTheme,
                      onLightThemeChanged: (newTheme) {
                        setState(() {
                          _lightTheme = newTheme;
                        });
                      },
                      onDarkThemeChanged: (newTheme) {
                        setState(() {
                          _darkTheme = newTheme;
                        });
                      },
                    ),
              },
            ),
          )
        : ToastificationWrapper(
            child: MaterialApp(
              title: 'Tracker App',
              locale: _locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: const [
                Locale('en', ''), // English
                Locale('it', ''), // Italian
                Locale('fr', ''), // French
                Locale('es', ''), // Spanish
                Locale('de', ''), // German
              ],
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
                        toggleTheme: _toggleTheme, user: snapshot.data!);
                  } else {
                    return const AuthPage();
                  }
                },
              ),
              routes: {
                '/home': (context) => HomeScreen(
                      toggleTheme: _toggleTheme,
                    ),
                '/shopping': (context) => const ShoppingScreen(),
                '/user': (context) => const UserScreen(),
                '/addMeal': (context) => const AddMealScreen(),
                '/viewExpenses': (context) => const ViewExpensesScreen(),
                '/inventory': (context) => const InventoryScreen(),
                '/viewMeals': (context) => const ViewMealsScreen(),
                '/recipeTips': (context) => const FilterRecipesScreen(),
                '/themeCustomization': (context) => ThemeCustomizationScreen(
                      lightTheme: _lightTheme,
                      darkTheme: _darkTheme,
                      onLightThemeChanged: (newTheme) {
                        setState(() {
                          _lightTheme = newTheme;
                        });
                      },
                      onDarkThemeChanged: (newTheme) {
                        setState(() {
                          _darkTheme = newTheme;
                        });
                      },
                    ),
              },
            ),
          );
  }
}
