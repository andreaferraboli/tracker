import 'package:flutter/material.dart';
import 'package:tracker/routes/product_selection_screen.dart';

import '../models/meal_type.dart';
import '../models/meal_type_card.dart';

class AddMealScreen extends StatelessWidget {
  AddMealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    Color colazioneColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.deepOrange
        : Colors.orange;
    Color pranzoColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.lightGreen
        : Colors.green;
    Color merendaColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.deepPurple
        : Colors.purple;
    Color cenaColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.lightBlue
        : Colors.blue;
    final List<MealType> mealTypes = [
      MealType(
        name: 'Breakfast',
        icon: Icons.breakfast_dining,
        color: colazioneColor,
      ),
      const MealType.empty(),
      const MealType.empty(),
      MealType(
        name: 'Lunch',
        icon: Icons.lunch_dining,
        color: pranzoColor,
      ),
      MealType(
        name: 'Snack',
        icon: Icons.cookie,
        color: merendaColor,
      ),
      const MealType.empty(),
      const MealType.empty(),
      MealType(
        name: 'Dinner',
        icon: Icons.dinner_dining,
        color: cenaColor,
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inserisci un pasto'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seleziona il tipo di pasto',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: screenWidth/2,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                  childAspectRatio: 1.1,
                ),
                itemCount: mealTypes.length,
                itemBuilder: (context, index) {
                  if (mealTypes[index].name.isEmpty) {
                    return const MealTypeCard.empty();
                  }
                  return MealTypeCard(
                    mealType: mealTypes[index],
                    onTap: () =>
                        _showProductSelection(context, mealTypes[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductSelection(BuildContext context, MealType mealType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductSelectionScreen(mealType: mealType),
      ),
    );
  }
}
