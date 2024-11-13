import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Assicurati di avere il pacchetto flutter_localizations configurato
import 'package:tracker/l10n/app_localizations.dart';
import 'package:tracker/routes/product_screen.dart';
import 'package:tracker/services/category_services.dart';

import '../models/meal.dart';
import '../models/product.dart';

class MealDetailScreen extends StatelessWidget {
  final Meal meal;

  const MealDetailScreen({Key? key, required this.meal}) : super(key: key);

  Future<void> deleteMeal(Meal meal) async {
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
    await mealsDocRef.update({'meals': meals.map((m) => m.toJson()).toList()});
  }

  @override
  Widget build(BuildContext context) {
    final localizations =
        AppLocalizations.of(context)!; // Ottieni l'istanza di AppLocalizations

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.mealString(meal.mealType)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            color: Colors.red,
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(AppLocalizations.of(context)!.confirm),
                    content:
                        Text(AppLocalizations.of(context)!.confirmDeleteMeal),
                    actions: <Widget>[
                      TextButton(
                        child: Text(AppLocalizations.of(context)!.no),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                      ),
                      TextButton(
                        child: Text(AppLocalizations.of(context)!.yes),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                      ),
                    ],
                  );
                },
              );

              if (confirm == true) {
                await deleteMeal(meal);
                Navigator.of(context).pop(meal);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.mealDeleted),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
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
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Table(
              border: TableBorder.all(color: Colors.grey, width: 0.5),
              children: [
                _buildMacronutrientRow(localizations.energy,
                    '${meal.macronutrients['Energy']?.toStringAsFixed(2)} kcal'),
                _buildMacronutrientRow(localizations.proteins,
                    '${meal.macronutrients['Proteins']?.toStringAsFixed(2)} g'),
                _buildMacronutrientRow(localizations.carbohydrates,
                    '${meal.macronutrients['Carbohydrates']?.toStringAsFixed(2)} g'),
                _buildMacronutrientRow(localizations.fats,
                    '${meal.macronutrients['Fats']?.toStringAsFixed(2)} g'),
                _buildMacronutrientRow(localizations.fiber,
                    '${meal.macronutrients['Fiber']?.toStringAsFixed(2)} g'),
                _buildMacronutrientRow(localizations.saturated_fats,
                    '${meal.macronutrients['Saturated Fats']?.toStringAsFixed(2)} g'),
                _buildMacronutrientRow(localizations.sugars,
                    '${meal.macronutrients['Sugars']?.toStringAsFixed(2)} g'),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${localizations.totalExpense}: €${meal.totalExpense.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text(
              localizations.products,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                      var existingProduct, product;
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductScreen(product: product),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
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
