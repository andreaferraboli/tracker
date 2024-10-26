class ProductBought {
  final String idProdotto;
  final String productName;
  final int quantita;
  final double price;
  final String category;
  final String pricePerKg;

  ProductBought({
    required this.idProdotto,
    required this.productName,
    required this.quantita,
    required this.category,
    required this.pricePerKg,
    required this.price,
  });

  factory ProductBought.fromJson(Map<String, dynamic> json) {
    return ProductBought(
      idProdotto: json['idProdotto'],
      productName: json['productName'],
      quantita: json['quantita'],
      category: json['category'],
      pricePerKg: json['pricePerKg'],
      price: json['price'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idProdotto': idProdotto,
      'productName': productName,
      'quantita': quantita,
      'category': category,
      'pricePerKg': pricePerKg,
      'price': price,
    };
  }
}
