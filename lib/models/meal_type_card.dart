import 'package:flutter/material.dart';
import 'package:tracker/l10n/app_localizations.dart';

import 'meal_type.dart';

class MealTypeCard extends StatelessWidget {
  final MealType? mealType;
  final VoidCallback? onTap;

  const MealTypeCard({
    super.key,
    required this.mealType,
    required this.onTap,
  });

  // Costruttore per una Card vuota e trasparente
  const MealTypeCard.empty({super.key})
      : mealType = null,
        onTap = null;

  @override
  Widget build(BuildContext context) {
    if (mealType == null) {
      return const SizedBox.shrink(); // Non mostra nulla se mealType è null
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.transparent,
            border: Border.all(width: 3, color: mealType!.color),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                mealType!.icon,
                size: 48,
                color: mealType!.color,
              ),
              const SizedBox(height: 8),
              Text(
                mealType!.mealString(context),
                style: TextStyle(
                  color: mealType!.color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
