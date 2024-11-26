class PurchaseHistory {
  final String purchaseDate;
  final double price;
  final int quantity;
  final String supermarket;
  final bool isDiscounted;
  final double? originalPrice; // prezzo non scontato, se applicabile

  PurchaseHistory({
    required this.purchaseDate,
    required this.price,
    required this.quantity,
    required this.supermarket,
    this.isDiscounted = false,
    this.originalPrice,
  });

  factory PurchaseHistory.fromJson(Map<String, dynamic> json) {
    return PurchaseHistory(
      purchaseDate: json['purchaseDate'],
      price: double.parse(json['price'].toString()),
      quantity: json['quantity'],
      supermarket: json['supermarket'],
      isDiscounted: json['isDiscounted'] ?? false,
      originalPrice: json['originalPrice'] != null 
          ? double.parse(json['originalPrice'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'purchaseDate': purchaseDate,
      'price': price,
      'quantity': quantity,
      'supermarket': supermarket,
      'isDiscounted': isDiscounted,
      'originalPrice': originalPrice,
    };
  }
}
