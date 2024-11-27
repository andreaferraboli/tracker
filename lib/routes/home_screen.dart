import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/providers/meals_provider.dart';
import 'package:tracker/routes/language_screen.dart';
import 'package:tracker/services/app_colors.dart';

import '../models/expense.dart';
import '../models/meal.dart';
import '../models/product.dart';
import '../providers/category_provider.dart';
import '../providers/expenses_provider.dart';
import '../providers/products_provider.dart';
import '../providers/stores_provider.dart';
import '../providers/supermarkets_list_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final VoidCallback toggleTheme;
  final User? user;

  const HomeScreen({super.key, required this.toggleTheme, this.user});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    AppColors.initialize();
    if (widget.user != null) {
      loadUserData();
    }
  }

  Future<void> loadUserData() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    List<String> supermarkets = [];
    List<Map<String, dynamic>> stores = [];

    // Recupero del documento utente
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      // Caricamento della lista dei supermercati
      supermarkets = List<String>.from(userDoc.data()?['supermarkets'] ?? []);

      // Caricamento della lista degli store
      stores = List<Map<String, dynamic>>.from(userDoc.data()?['stores'] ?? []);
    }

    // Recupero dei prodotti
    final productsDocRef =
        FirebaseFirestore.instance.collection('products').doc(userId);
    final productsDoc = await productsDocRef.get();
    final products = (productsDoc.data()?['products'] as List?)
            ?.map((product) => Product.fromJson(product))
            .toList() ??
        [];
// Recupero dei pasti
    final mealsDocRef =
        FirebaseFirestore.instance.collection('meals').doc(userId);
    final mealsDoc = await mealsDocRef.get();
    final meals = (mealsDoc.data()?['meals'] as List?)
            ?.map((meal) => Meal.fromJson(meal))
            .toList() ??
        [];
    // Recupero delle categorie
    final categoriesDocRef =
        FirebaseFirestore.instance.collection('categories').doc(userId);
    final categoriesDoc = await categoriesDocRef.get();
    final categories = (categoriesDoc.data()?['categories'] as List?)
            ?.map((category) => Category.fromJson(category))
            .toList() ??
        [];

    // Recupero delle spese
    final expensesDocRef =
        FirebaseFirestore.instance.collection('expenses').doc(userId);
    final expensesDoc = await expensesDocRef.get();
    final expenses = (expensesDoc.data()?['expenses'] as List?)
            ?.map((expense) => Expense.fromJson(expense))
            .toList() ??
        [];

    // Caricamento nei provider
    ref.read(storesProvider.notifier).loadStores(stores);
    ref
        .read(supermarketsListProvider.notifier)
        .addAllSupermarkets(supermarkets);
    ref.read(mealsProvider.notifier).loadMeals(meals);
    ref.read(productsProvider.notifier).loadProducts(products);
    ref.read(categoriesProvider.notifier).loadCategories(categories);
    ref.read(expensesProvider.notifier).loadExpenses(expenses);
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

    final gridContent = GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 0.8,
      padding: const EdgeInsets.all(16),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: <Widget>[
        _buildMenuButton(context, AppLocalizations.of(context)!.shopping,
            Icons.shopping_cart, '/shopping', shoppingColor),
        _buildMenuButton(context, AppLocalizations.of(context)!.addMeal,
            Icons.restaurant, '/addMeal', addMealColor),
        _buildMenuButton(context, AppLocalizations.of(context)!.viewExpenses,
            Icons.receipt_long, '/viewExpenses', viewExpensesColor),
        _buildMenuButton(context, AppLocalizations.of(context)!.inventory,
            Icons.inventory, '/inventory', inventoryColor),
        _buildMenuButton(context, AppLocalizations.of(context)!.viewMeals,
            Icons.fastfood, '/viewMeals', viewMealsColor),
        _buildMenuButton(context, AppLocalizations.of(context)!.recipeTips,
            Icons.food_bank_outlined, '/recipeTips', recipeTipsColor),
      ],
    );

    final drawerContent = ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        if (Platform.isIOS)
          Container(
            padding: const EdgeInsets.only(
              top: 70.0,
              bottom: 20.0,
              left: 20.0,
            ),
            color: CupertinoTheme.of(context).barBackgroundColor,
            child: Text(
              AppLocalizations.of(context)!.menu,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        else
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
        Platform.isIOS
            ? CupertinoListTile(
                title: Text(AppLocalizations.of(context)!.changeLanguage),
                leading: const Icon(CupertinoIcons.globe),
                trailing: const CupertinoListTileChevron(),
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const LanguageScreen(),
                    ),
                  );
                },
              )
            : ListTile(
                leading: const Icon(Icons.language),
                title: Text(AppLocalizations.of(context)!.changeLanguage),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LanguageScreen(),
                    ),
                  );
                },
              ),
        Platform.isIOS
            ? CupertinoListTile(
                title: Text(AppLocalizations.of(context)!.modifyThemeColors),
                leading: const Icon(CupertinoIcons.paintbrush),
                trailing: const CupertinoListTileChevron(),
                onTap: () {
                  Navigator.pushNamed(context, '/themeCustomization');
                },
              )
            : ListTile(
                leading: const Icon(Icons.format_paint),
                title: Text(AppLocalizations.of(context)!.modifyThemeColors),
                onTap: () {
                  Navigator.pushNamed(context, '/themeCustomization');
                },
              ),
        Platform.isIOS
            ? CupertinoListTile(
                title: Text(AppLocalizations.of(context)!.changeTheme),
                leading: const Icon(CupertinoIcons.sun_max),
                onTap: () {
                  widget.toggleTheme();
                  Navigator.pop(context);
                },
              )
            : ListTile(
                leading: const Icon(Icons.brightness_6),
                title: Text(AppLocalizations.of(context)!.changeTheme),
                onTap: () {
                  widget.toggleTheme();
                  Navigator.pop(context);
                },
              ),
        Platform.isIOS
            ? CupertinoListTile(
                title: Text(AppLocalizations.of(context)!.logout),
                leading: const Icon(CupertinoIcons.square_arrow_right),
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  AppColors.resetAllColors();
                  ref
                      .read(supermarketsListProvider.notifier)
                      .resetSupermarkets();
                  Navigator.pop(context);
                },
              )
            : ListTile(
                leading: const Icon(Icons.logout),
                title: Text(AppLocalizations.of(context)!.logout),
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  AppColors.resetAllColors();
                  ref
                      .read(supermarketsListProvider.notifier)
                      .resetSupermarkets();
                  Navigator.pop(context);
                },
              ),
      ],
    );

    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(AppLocalizations.of(context)!.home),
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.bars),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
          trailing: widget.user == null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.loginRegister,
                      style: const TextStyle(fontSize: 16),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Icon(CupertinoIcons.arrow_right_square),
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                    ),
                  ],
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.user!.displayName ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Icon(CupertinoIcons.person),
                      onPressed: () {
                        Navigator.pushNamed(context, '/user');
                      },
                    ),
                  ],
                ),
        ),
        child: Scaffold(
          drawer: Drawer(child: drawerContent),
          body: gridContent,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.home,
          style:
              TextStyle(color: Theme.of(context).appBarTheme.foregroundColor),
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
      drawer: Drawer(child: drawerContent),
      body: gridContent,
    );
  }

  Widget _buildMenuButton(BuildContext context, String label, IconData icon,
      String? route, Color color) {
    if (Platform.isIOS) {
      return CupertinoButton(
        onPressed: route != null
            ? () {
                Navigator.pushNamed(context, route);
              }
            : null,
        padding: EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40),
              const SizedBox(height: 10),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

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
