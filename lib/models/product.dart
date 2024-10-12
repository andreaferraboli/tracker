class Product {
  String productId;
  String productName;
  String category;
  double priceTotal;
  double pricePerPackage;
  double totalWeight;
  double weightPerPackage;
  int quantityOwned;
  Map<String, double> macronutrientsPer100g;
  String expirationDate;
  String supermarket;
  String lastPurchaseDate;

  // Costruttore
  Product({
    required this.productId,
    required this.productName,
    required this.category,
    required this.priceTotal,
    required this.pricePerPackage,
    required this.totalWeight,
    required this.weightPerPackage,
    required this.quantityOwned,
    required this.macronutrientsPer100g,
    required this.expirationDate,
    required this.supermarket,
    required this.lastPurchaseDate,
  });

  // Metodo per la deserializzazione da JSON (fromJson)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['productId'],
      productName: json['productName'],
      category: json['category'],
      priceTotal: json['priceTotal'].toDouble(),
      pricePerPackage: json['pricePerPackage'].toDouble(),
      totalWeight: json['totalWeight'].toDouble(),
      weightPerPackage: json['weightPerPackage'].toDouble(),
      quantityOwned: json['quantityOwned'],
      macronutrientsPer100g: Map<String, double>.from(json['macronutrientsPer100g']),
      expirationDate: json['expirationDate'],
      supermarket: json['supermarket'],
      lastPurchaseDate: json['lastPurchaseDate'],
    );
  }

  // Metodo per la serializzazione in JSON (toJson)
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'category': category,
      'priceTotal': priceTotal,
      'pricePerPackage': pricePerPackage,
      'totalWeight': totalWeight,
      'weightPerPackage': weightPerPackage,
      'quantityOwned': quantityOwned,
      'macronutrientsPer100g': macronutrientsPer100g,
      'expirationDate': expirationDate,
      'supermarket': supermarket,
      'lastPurchaseDate': lastPurchaseDate,
    };
  }
}
