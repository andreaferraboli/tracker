class Product {
  String productId;
  String productName;
  String category;
  double totalPrice; // Rinominato da priceTotal
  double price; // Prezzo unitario
  int quantity;
  int buyQuantity;
  double selectedQuantity;
  double quantityOwned; // Rinominato da quantityOwned
  int quantityUnitOwned;
  double quantityWeightOwned;
  String unit; // Unità di misura
  String store;
  Map<String, double> macronutrients; // Rinominato da macronutrientsPer100g
  String expirationDate;
  String supermarket;
  String purchaseDate; // Rinominato da lastPurchaseDate
  String barcode;
  String imageUrl;
  double totalWeight;
  double unitWeight;
  double unitPrice;
  double sliderValue;
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
    required this.buyQuantity,
    required this.quantityOwned,
    required this.quantityUnitOwned,
    required this.quantityWeightOwned,
    this.store = '',
    this.imageUrl = '',
    this.totalWeight = 0,
    this.unitWeight = 0,
    this.unitPrice = 0,
    this.selectedQuantity = 0,
    this.sliderValue = 0,
  });

  // Metodo per la deserializzazione da JSON (fromJson)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['productId'].toString(),
      productName: json['productName'],
      category: json['category'],
      totalPrice: double.parse(json['totalPrice'].toStringAsFixed(2)),
      price: double.parse(json['price'].toStringAsFixed(2)),
      quantity: json['quantity'],
      unit: json['unit'],
      macronutrients: (json['macronutrients'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, value.toDouble())),
      expirationDate: json['expirationDate'],
      supermarket: json['supermarket'],
      purchaseDate: json['purchaseDate'],
      barcode: json['barcode'],
      imageUrl: json['imageUrl'],
      store: json['store'] ?? 'other',
      buyQuantity: json['buyQuantity'],
      quantityOwned: double.parse(json['quantityOwned'].toString()),
      quantityUnitOwned: (json['quantityUnitOwned'] as num).toInt(),
      quantityWeightOwned: (json['quantityWeightOwned'] as num).toDouble(),
      totalWeight: double.parse(json['totalWeight'].toString()),
      unitWeight: double.parse(json['unitWeight'].toString()),
      unitPrice: double.parse(json['unitPrice'].toString()),
      selectedQuantity: json['selectedQuantity'] ?? 0,
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
      'store': store,
      'macronutrients': macronutrients,
      'expirationDate': expirationDate,
      'supermarket': supermarket,
      'purchaseDate': purchaseDate,
      'barcode': barcode,
      'imageUrl': imageUrl,
      'buyQuantity': buyQuantity,
      'quantityOwned': quantityOwned,
      'quantityUnitOwned': quantityUnitOwned,
      'quantityWeightOwned': quantityWeightOwned,
      'totalWeight': totalWeight,
      'unitWeight': unitWeight,
      'unitPrice': unitPrice,
      'selectedQuantity': selectedQuantity,
    };
  }
int daysUntilExpiration() {
    final expiration = expirationDate.isNotEmpty ? DateTime.parse(expirationDate).add(const Duration(days:1)) : DateTime.now();
    final now = DateTime.now();
    return expiration.difference(now).inDays;
  }
  Product copyWith({required double selectedQuantity}) {
    return Product(
      productId: productId,
      productName: productName,
      category: category,
      totalPrice: totalPrice,
      price: price,
      quantity: quantity,
      unit: unit,
      store: store,
      macronutrients: macronutrients,
      expirationDate: expirationDate,
      supermarket: supermarket,
      purchaseDate: purchaseDate,
      barcode: barcode,
      buyQuantity: buyQuantity,
      quantityOwned: quantityOwned,
      quantityUnitOwned: quantityUnitOwned,
      quantityWeightOwned: quantityWeightOwned,
      imageUrl: imageUrl,
      totalWeight: totalWeight,
      unitWeight: unitWeight,
      unitPrice: unitPrice,
      selectedQuantity: selectedQuantity,
    );
  }
}
