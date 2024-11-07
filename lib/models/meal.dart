class Meal {
  final String date; // Formato stringa della data (es. "2024-10-29")
  final String mealType;
  final Map<String, double> macronutrients;
  final String id;
  final double totalExpense;
  final List<Map<String, dynamic>> products;

  Meal({
    required this.date,
    required this.mealType,
    required this.macronutrients,
    required this.id,
    required this.totalExpense,
    required this.products,
  });

  // Metodo per convertire un'istanza di Meal in JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'mealType': mealType,
      'macronutrients': macronutrients,
      'id': id,
      'totalExpense': totalExpense.toStringAsFixed(3),
      'products': products,
    };
  }

  // Metodo per creare un'istanza di Meal a partire da JSON
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      date: json['date'] ?? '',
      mealType: json['mealType'] ?? '',
      macronutrients: json['macronutrients'] != null
          ? (json['macronutrients'] as Map<String, dynamic>)
              .map<String, double>((key, value) =>
                  MapEntry(key, value is int ? value.toDouble() : value))
          : {},
      id: json['id'] ?? '',
      totalExpense:
          double.tryParse(json['totalExpense']?.toString() ?? '0.0') ?? 0.0,
      products: List<Map<String, dynamic>>.from(json['products'] ?? []),
    );
  }

  // Getter per ottenere l'anno dalla data
  int get year {
    List<String> parts = date.split('-'); // Divide la stringa in parti
    return int.parse(parts[2]); // Anno è la terza parte
  }

// Getter per ottenere il mese dalla data
  int get month {
    List<String> parts = date.split('-'); // Divide la stringa in parti
    return int.parse(parts[1]); // Mese è la seconda parte
  }

// Getter per ottenere il giorno dalla data
  int get day {
    List<String> parts = date.split('-'); // Divide la stringa in parti
    return int.parse(parts[0]); // Giorno è la prima parte
  }

  num get totalCalories {
    return this.macronutrients['Energy'] ?? 0;
  }
}
