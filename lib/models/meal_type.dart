import 'package:flutter/material.dart';
class MealType {
  final String name;
  final IconData icon;
  final Color color;

  const MealType({
    required this.name,
    required this.icon,
    required this.color,
  });
  const MealType.empty()
      : name = '',
        icon = Icons.error,
        color = Colors.transparent;
}