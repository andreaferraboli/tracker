import 'package:flutter/material.dart';
import 'package:tracker/services/category_services.dart';
import '../models/meal.dart';

class MealDetailScreen extends StatelessWidget {
  final Meal meal;

  const MealDetailScreen({Key? key, required this.meal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(meal.mealType),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data: ${meal.date}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Tipo di pasto: ${meal.mealType}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            const Text(
              'Macronutrienti:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Table(
              border: TableBorder.all(color: Colors.grey, width: 0.5),
              children: [
                _buildMacronutrientRow('Calorie', '${meal.macronutrients['Energy']} kcal'),
                _buildMacronutrientRow('Proteine', '${meal.macronutrients['Proteins']} g'),
                _buildMacronutrientRow('Carboidrati', '${meal.macronutrients['Carbohydrates']} g'),
                _buildMacronutrientRow('Grassi', '${meal.macronutrients['Fats']} g'),
                _buildMacronutrientRow('Fibre', '${meal.macronutrients['Fiber']} g'),
                _buildMacronutrientRow('Grassi Saturi', '${meal.macronutrients['Saturated_Fats']} g'),
                _buildMacronutrientRow('Zuccheri', '${meal.macronutrients['Sugars']} g'),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Totale spesa: €${meal.totalExpense.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            const Text(
              'Prodotti:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                        leading: CategoryServices.iconFromCategory(product['category']),
                        title: Text(product['productName']),
                        subtitle: Text('Categoria: ${product['category']}'),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Quantità: ${product['quantitySelected']} kg'),
                            Text('Prezzo: €${product['price']}'),
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
