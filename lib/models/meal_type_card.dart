import 'package:flutter/material.dart';

import 'meal_type.dart';

class MealTypeCard extends StatelessWidget {
  final MealType? mealType;
  final VoidCallback? onTap;

  const MealTypeCard({
    required this.mealType,
    required this.onTap,
  });

  // Costruttore per una Card vuota e trasparente
  const MealTypeCard.empty()
      : mealType = null,
        onTap = null;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: mealType == null ? 0 : 4, // Nessuna ombra se vuota
      shape: mealType == null
          ? null
          : RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: mealType != null
                ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                mealType!.color.withOpacity(0.7),
                mealType!.color,
              ],
            )
                : null, // Nessun gradiente se vuoto
            color: mealType == null ? Colors.transparent : null, // Sfondo trasparente se vuoto
          ),
          child: mealType != null
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                mealType!.icon,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                mealType!.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
              : null, // Nessun contenuto se vuoto
        ),
      ),
    );
  }
}
