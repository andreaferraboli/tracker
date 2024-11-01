class ProductBought {
  final String idProdotto;
  final String productName;
  final int quantity;
  final double price;
  final String category;
  final String pricePerKg;

  ProductBought({
    required this.idProdotto,
    required this.productName,
    required this.quantity,
    required this.category,
    required this.pricePerKg,
    required this.price,
  });

  factory ProductBought.fromJson(Map<String, dynamic> json) {
    return ProductBought(
      idProdotto: json['idProdotto'],
      productName: json['productName'],
      quantity: json['quantita'],
      category: json['category'],
      pricePerKg: json['pricePerKg'],
      price: json['price'],
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
    };
  }
}
