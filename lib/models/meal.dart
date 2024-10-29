import 'package:tracker/models/product.dart';

class Meal {
  final String date;
  final String mealType;
  final Map<String, dynamic> macronutrients;
  final String id;
  final double totalExpense;
  final List<Product> products;

  Meal({
    this.date = '',
    this.mealType = '',
    this.macronutrients = const <String, dynamic>{},
    this.id = '',
    this.totalExpense = 0.0,
    this.products = const [],
  });

  // Metodo per convertire un'istanza di Meal in JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'mealType': mealType,
      'macronutrients': macronutrients,
      'id': id,
      'totalExpense': totalExpense,
      'products': products.map((product) => product.toJson()).toList(),
    };
  }

  // Metodo per creare un'istanza di Meal a partire da JSON
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      date: json['date'] ?? '',
      mealType: json['mealType'] ?? '',
      macronutrients: json['macronutrients'] ?? <String, dynamic>{},
      id: json['id'] ?? '',
      totalExpense: (json['totalExpense'] ?? 0.0).toDouble(),
      products: (json['products'] as List<dynamic>?)
          ?.map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
}
