class ProductBought {
  final String idProdotto;
  final String productName;
  final int quantity;
  final double price;
  final String category;
  final String pricePerKg;
  final double? originalPrice;
  final bool? isDiscounted;

  ProductBought({
    required this.idProdotto,
    required this.productName,
    required this.quantity,
    required this.category,
    required this.pricePerKg,
    required this.price,
    this.originalPrice,
    this.isDiscounted,
  });

  factory ProductBought.fromJson(Map<String, dynamic> json) {
    return ProductBought(
      idProdotto: json['idProdotto'],
      productName: json['productName'],
      quantity: json['quantita'],
      category: json['category'],
      pricePerKg: json['pricePerKg'],
      price: json['price'],
      originalPrice: json['originalPrice'] ?? json['price'],
      isDiscounted: json['isDiscounted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idProdotto': idProdotto,
      'productName': productName,
      'quantita': quantity,
      'category': category,
      'pricePerKg': pricePerKg,
      'price': price,
      'originalPrice': originalPrice ?? price,
      'isDiscounted': isDiscounted ?? false,
    };
  }
}
