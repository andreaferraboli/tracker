import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:tracker/routes/product_selection_screen.dart';

import '../models/meal_type.dart';
import '../models/meal_type_card.dart';

class AddMealScreen extends StatelessWidget {
  AddMealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    Color colazioneColor = const Color.fromRGBO(30, 144, 255, 1.0);
    Color pranzoColor = const Color.fromRGBO(243, 238, 13, 1.0);
    Color merendaColor = const Color.fromRGBO(236, 124, 38, 1.0);
    Color cenaColor = const Color.fromRGBO(0, 194, 0, 1.0);
    final List<MealType> mealTypes = [
      MealType(
        name: 'Breakfast',
        icon: HugeIcons.strokeRoundedCoffee02,
        color: colazioneColor,
      ),
      const MealType.empty(),
      const MealType.empty(),
      MealType(
        name: 'Lunch',
        icon: Icons.fastfood_outlined,
        color: pranzoColor,
      ),
      MealType(
        name: 'Snack',
        icon: HugeIcons.strokeRoundedFrenchFries02,
        color: merendaColor,
      ),
      const MealType.empty(),
      const MealType.empty(),
      MealType(
        name: 'Dinner',
        icon: Icons.dinner_dining_outlined,
        color: cenaColor,
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.insertMealType),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.selectMealType,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: screenWidth / 2,
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
