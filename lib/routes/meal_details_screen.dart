import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Assicurati di avere il pacchetto flutter_localizations configurato
import 'package:tracker/l10n/app_localizations.dart';
import 'package:tracker/services/category_services.dart';

import '../models/meal.dart';

class MealDetailScreen extends StatelessWidget {
  final Meal meal;

  const MealDetailScreen({Key? key, required this.meal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations =
        AppLocalizations.of(context)!; // Ottieni l'istanza di AppLocalizations

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.mealString(meal.mealType)),
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
                  return Padding(
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
