import 'package:tracker/models/quantiy_update_type.dart';
import 'package:tracker/models/purchase_history.dart';

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
  QuantityUpdateType? quantityUpdateType;
  //List<PurchaseHistory> purchaseHistory = []; // Cronologia degli acquisti

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
    this.quantityUpdateType,
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
      //purchaseHistory: json['purchaseHistory'] != null
      //    ? (json['purchaseHistory'] as List)
      //        .map((p) => PurchaseHistory.fromJson(p as Map<String, dynamic>))
      //        .toList()
      //    : [],
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
      //'purchaseHistory': purchaseHistory.map((p) => p.toJson()).toList(),
    };
  }

  int daysUntilExpiration() {
    final expiration = expirationDate.isNotEmpty
        ? DateTime.parse(expirationDate).add(const Duration(days: 1))
        : DateTime.now();
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
      quantityUpdateType: quantityUpdateType,
      selectedQuantity: selectedQuantity,
      //purchaseHistory: purchaseHistory,
    );
  }

  // Metodo per aggiungere un nuovo acquisto alla cronologia
  /* void addPurchase({
    required double price,
    required int quantity,
    required String supermarket,
    double? originalPrice,
  }) {
    final isDiscounted = originalPrice != null && originalPrice > price;
    purchaseHistory.add(PurchaseHistory(
      purchaseDate: DateTime.now().toIso8601String(),
      price: price,
      quantity: quantity,
      supermarket: supermarket,
      isDiscounted: isDiscounted,
      originalPrice: originalPrice,
    ));
  }

  // Metodo per ottenere gli acquisti scontati
  List<PurchaseHistory> getDiscountedPurchases() {
    return purchaseHistory.where((p) => p.isDiscounted).toList();
  }

  // Metodo per ottenere il prezzo medio di acquisto
  double getAveragePrice() {
    if (purchaseHistory.isEmpty) return price;
    final totalPrice = purchaseHistory.fold(
        0.0, (sum, purchase) => sum + (purchase.price * purchase.quantity));
    final totalQuantity =
        purchaseHistory.fold(0, (sum, purchase) => sum + purchase.quantity);
    return totalPrice / totalQuantity;
  }

  // Metodo per ottenere l'ultimo prezzo scontato
  double? getLastDiscountedPrice() {
    final discountedPurchases = getDiscountedPurchases();
    if (discountedPurchases.isEmpty) return null;
    return discountedPurchases.last.price;
  }

  // Metodo per ottenere l'ultimo prezzo originale
  double? getLastOriginalPrice() {
    final discountedPurchases = getDiscountedPurchases();
    if (discountedPurchases.isEmpty) return null;
    return discountedPurchases.last.originalPrice;
  } */
}
