class Product {
  String productId;
  String productName;
  String category;
  double totalPrice; // Rinominato da priceTotal
  double price; // Prezzo unitario
  int quantity; // Rinominato da quantityOwned
  String unit; // Unità di misura
  Map<String, double> macronutrients; // Rinominato da macronutrientsPer100g
  String expirationDate;
  String supermarket;
  String purchaseDate; // Rinominato da lastPurchaseDate
  String barcode; // Nuovo campo

  // Costruttore
  Product({
    required this.productId,
    required this.productName,
    required this.category,
    required this.totalPrice,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.macronutrients,
    required this.expirationDate,
    required this.supermarket,
    required this.purchaseDate,
    required this.barcode,
  });

  // Metodo per la deserializzazione da JSON (fromJson)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['productId'],
      productName: json['productName'],
      category: json['category'],
      totalPrice: json['totalPrice'],
      price: json['price'],
      quantity: json['quantity'],
      unit: json['unit'],
      macronutrients: Map<String, double>.from(json['macronutrients']),
      expirationDate: json['expirationDate'],
      supermarket: json['supermarket'],
      purchaseDate: json['purchaseDate'],
      barcode: json['barcode'],
    );
  }

  // Metodo per la serializzazione in JSON (toJson)
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'category': category,
      'totalPrice': totalPrice,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'macronutrients': macronutrients,
      'expirationDate': expirationDate,
      'supermarket': supermarket,
      'purchaseDate': purchaseDate,
      'barcode': barcode,
    };
  }
}
