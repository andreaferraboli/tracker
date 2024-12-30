import 'package:tracker/models/base_product.dart';
import 'package:tracker/models/quantiy_update_type.dart';

class Product extends BaseProduct {
  String productId;
  String productName;
  String category;
  double totalPrice;
  double price;
  int quantity;
  int buyQuantity;
  double selectedQuantity;
  double quantityOwned;
  int quantityUnitOwned;
  double quantityWeightOwned;
  String unit;
  String store;
  Map<String, double> macronutrients;
  String expirationDate;
  String supermarket;
  String purchaseDate;
  String barcode;
  String imageUrl;
  double totalWeight;
  double unitWeight;
  double unitPrice;
  bool useDiscountedValidation;

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
    super.sliderValue,
    QuantityUpdateType super.quantityUpdateType,
    this.useDiscountedValidation = false,
  });

  // Metodo per la deserializzazione da JSON (fromJson)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['productId']?.toString() ?? '',
      productName: json['productName'] ?? '',
      category: json['category'] ?? '',
      totalPrice: (json['totalPrice'] is num)
          ? (json['totalPrice'] as num).toDouble()
          : 0.0,
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      quantity: json['quantity'] ?? 0,
      unit: json['unit'] ?? '',
      macronutrients: (json['macronutrients'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, (value as num?)?.toDouble() ?? 0.0),
      ),
      expirationDate: json['expirationDate'] ?? '',
      supermarket: json['supermarket'] ?? '',
      purchaseDate: json['purchaseDate'] ?? '',
      barcode: json['barcode'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      store: json['store'] ?? 'other',
      buyQuantity: json['buyQuantity'] ?? 0,
      quantityOwned: (json['quantityOwned'] is num)
          ? (json['quantityOwned'] as num).toDouble()
          : 0.0,
      quantityUnitOwned: (json['quantityUnitOwned'] is num)
          ? (json['quantityUnitOwned'] as num).toInt()
          : 0,
      quantityWeightOwned: (json['quantityWeightOwned'] is num)
          ? (json['quantityWeightOwned'] as num).toDouble()
          : 0.0,
      totalWeight: (json['totalWeight'] is num)
          ? (json['totalWeight'] as num).toDouble()
          : 0.0,
      unitWeight: (json['unitWeight'] is num)
          ? (json['unitWeight'] as num).toDouble()
          : 0.0,
      unitPrice: (json['unitPrice'] is num)
          ? (json['unitPrice'] as num).toDouble()
          : 0.0,
      selectedQuantity: (json['selectedQuantity'] is num)
          ? (json['selectedQuantity'] as num).toDouble()
          : 0.0,
    );
  }

  // Metodo per la serializzazione in JSON (toJson)
  @override
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
      selectedQuantity: selectedQuantity,
      quantityUpdateType: quantityUpdateType ?? QuantityUpdateType.slider,
      useDiscountedValidation: useDiscountedValidation,
    );
  }
}
