import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tracker/services/app_colors.dart';
import 'package:tracker/main.dart'; // Supponendo che MyApp sia definito in main.dart

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final User? user;

  const HomeScreen({super.key, required this.toggleTheme, this.user});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    AppColors.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final shoppingColor = Theme.of(context).brightness == Brightness.light
        ? AppColors.shoppingLight
        : AppColors.shoppingDark;
    final addMealColor = Theme.of(context).brightness == Brightness.light
        ? AppColors.addMealLight
        : AppColors.addMealDark;
    final viewExpensesColor = Theme.of(context).brightness == Brightness.light
        ? AppColors.viewExpensesLight
        : AppColors.viewExpensesDark;
    final inventoryColor = Theme.of(context).brightness == Brightness.light
        ? AppColors.inventoryLight
        : AppColors.inventoryDark;
    final viewMealsColor = Theme.of(context).brightness == Brightness.light
        ? AppColors.viewMealsLight
        : AppColors.viewMealsDark;
    final recipeTipsColor = Theme.of(context).brightness == Brightness.light
        ? AppColors.recipeTipsLight
        : AppColors.recipeTipsDark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.home,
          style: TextStyle(
              color: Theme.of(context).appBarTheme.titleTextStyle?.color),
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          if (widget.user == null)
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    AppLocalizations.of(context)!.loginRegister,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.login),
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                ),
              ],
            )
          else
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    widget.user!.displayName ?? '',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () {
                    Navigator.pushNamed(context, '/user');
                  },
                ),
              ],
            ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).appBarTheme.backgroundColor,
              ),
              child: Text(
                AppLocalizations.of(context)!.menu,
                style: TextStyle(
                  color: Theme.of(context).appBarTheme.foregroundColor,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(AppLocalizations.of(context)!.changeLanguage),
              onTap: () {
                Locale newLocale =
                Localizations.localeOf(context).languageCode == 'it'
                    ? const Locale('en')
                    : const Locale('it');
                MyApp.setLocale(context, newLocale);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.format_paint),
              title: Text(AppLocalizations.of(context)!.modifyThemeColors),
              onTap: () {
                Navigator.pushNamed(context, '/themeCustomization')
                    .then((result) {
                      print('Result: $result');
                  if (result == 'reset') {
                    print('Resetting colors');
                    setState(() {});
                  }
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: Text(AppLocalizations.of(context)!.changeTheme),
              onTap: () {
                widget.toggleTheme();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(AppLocalizations.of(context)!.logout),
              onTap: () {
                FirebaseAuth.instance.signOut();
                AppColors.resetAllColors();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: <Widget>[
          _buildMenuButton(
              context,
              AppLocalizations.of(context)!.shopping,
              Icons.shopping_cart,
              '/shopping',
              shoppingColor),
          _buildMenuButton(
              context,
              AppLocalizations.of(context)!.addMeal,
              Icons.restaurant,
              '/addMeal',
              addMealColor),
          _buildMenuButton(
              context,
              AppLocalizations.of(context)!.viewExpenses,
              Icons.receipt_long,
              '/viewExpenses',
              viewExpensesColor),
          _buildMenuButton(
              context,
              AppLocalizations.of(context)!.inventory,
              Icons.inventory,
              '/inventory',
              inventoryColor),
          _buildMenuButton(
              context,
              AppLocalizations.of(context)!.viewMeals,
              Icons.fastfood,
              '/viewMeals',
              viewMealsColor),
          _buildMenuButton(
              context,
              AppLocalizations.of(context)!.recipeTips,
              Icons.food_bank_outlined,
              '/recipeTips',
              recipeTipsColor),
        ],
      ),
    );
  }

  // Funzione per creare un pulsante nel grid
  Widget _buildMenuButton(BuildContext context, String label, IconData icon,
      String? route, Color color) {
    return ElevatedButton(
      onPressed: route != null
          ? () {
        Navigator.pushNamed(context, route);
      }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40),
          const SizedBox(height: 10),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
