import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Assicurati di avere il pacchetto flutter_localizations configurato
import 'package:tracker/l10n/app_localizations.dart';
import 'package:tracker/routes/product_screen.dart';
import 'package:tracker/services/category_services.dart';
import 'package:tracker/services/toast_notifier.dart';

import '../models/meal.dart';
import '../models/product.dart';

class MealDetailScreen extends StatelessWidget {
  final Meal meal;

  const MealDetailScreen({super.key, required this.meal});

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    if (Platform.isIOS && false) {
      return showCupertinoDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(AppLocalizations.of(context)!.confirm),
            content: Text(AppLocalizations.of(context)!.confirmDeleteMeal),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(AppLocalizations.of(context)!.no),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: Text(AppLocalizations.of(context)!.yes),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      );
    } else {
      return showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.confirm),
            content: Text(AppLocalizations.of(context)!.confirmDeleteMeal),
            actions: <Widget>[
              TextButton(
                child: Text(AppLocalizations.of(context)!.no),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: Text(AppLocalizations.of(context)!.yes,
                    style: const TextStyle(color: Colors.red)),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> deleteMeal(Meal meal, BuildContext context) async {
    final confirm = await _showDeleteConfirmation(context);
    if (confirm == true) {
      // Recupera l'ID dell'utente
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final mealsDocRef =
          FirebaseFirestore.instance.collection('meals').doc(userId);

      // Ottiene il documento dei pasti
      final mealsDoc = await mealsDocRef.get();

      // Verifica se il documento esiste e contiene dati
      if (!mealsDoc.exists || mealsDoc.data() == null) return;

      // Recupera la lista dei pasti
      final meals = (mealsDoc.data()!['meals'] as List)
          .map((meal) => Meal.fromJson(meal))
          .toList();

      // Rimuove il pasto specifico
      meals.removeWhere((m) => m.id == meal.id);

      // Aggiorna il documento dei pasti
      await mealsDocRef
          .update({'meals': meals.map((m) => m.toJson()).toList()});

      if (!context.mounted) return;
      Navigator.of(context).pop(meals);
      ToastNotifier.showSuccess(
        context,
        AppLocalizations.of(context)!.mealDeleted,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations =
        AppLocalizations.of(context)!; // Ottieni l'istanza di AppLocalizations

    // Determina se la piattaforma è iOS
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return Scaffold(
      appBar: isIOS
          ? CupertinoNavigationBar(
              middle: Text(localizations.mealString(meal.mealType)),
              trailing: GestureDetector(
                onTap: () async {
                  await deleteMeal(meal, context);
                },
                child: const Icon(CupertinoIcons.trash, color: Colors.red),
              ),
            )
          : AppBar(
              titleSpacing: 0,
              centerTitle: true,
              title: Text(localizations.mealString(meal.mealType)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                  onPressed: () async {
                    await deleteMeal(meal, context);
                  },
                ),
              ],
            ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${localizations.date}: ${meal.date}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                '${localizations.mealType}: ${localizations.mealString(meal.mealType)}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              Text(
                localizations.macronutrients,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Table(
                border: TableBorder.all(color: Colors.grey, width: 0.5),
                children: meal.macronutrients.entries.map((entry) {
                  return _buildMacronutrientRow(
                    localizations.getNutrientString(entry.key),
                    '${entry.value.toStringAsFixed(2)} ${entry.key == 'Energy' ? 'kcal' : 'g'}',
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text(
                '${localizations.totalExpense}: €${meal.totalExpense.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              Text(
                localizations.products,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: meal.products.length,
                  itemBuilder: (context, index) {
                    final product = meal.products[index];
                    return GestureDetector(
                      onTap: () async {
                        DocumentReference productDocRef = FirebaseFirestore
                            .instance
                            .collection('products')
                            .doc(FirebaseAuth.instance.currentUser!.uid);

                        DocumentSnapshot snapshot = await productDocRef.get();
                        dynamic existingProduct;
                        Product? product;
                        if (snapshot.exists) {
                          final List<dynamic> productsList =
                              snapshot['products'] ?? [];
                          existingProduct = productsList.firstWhere(
                              (p) =>
                                  p['productId'] ==
                                  meal.products[index]["idProdotto"],
                              orElse: () => null);
                          product = Product.fromJson(existingProduct);
                        }
                        if (!context.mounted || product == null) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductScreen(product: product!),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: ListTile(
                            leading: CategoryServices.iconFromCategory(
                                product['category']),
                            title: Text(product['productName']),
                            subtitle: Text(
                                '${localizations.category}: ${localizations.translateCategory(product['category'])}'),
                            trailing: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                    '${localizations.quantity}: ${product['quantitySelected']?.toStringAsFixed(3)} kg'),
                                Text(
                                    '${localizations.price}: €${product['price']}'),
                              ],
                            ),
                            textColor: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _buildMacronutrientRow(String nutrientName, String amount) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            nutrientName,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            amount,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
