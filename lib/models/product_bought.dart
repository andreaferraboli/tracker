
class ProductBought {
  final String id;
  final String name;
  final int quantity;
  final String category;
  final double pricePerKg;

  ProductBought({
    required this.id,
    required this.name,
    required this.quantity,
    required this.category,
    required this.pricePerKg,
  });

  factory ProductBought.fromJson(Map<String, dynamic> json) {
    return ProductBought(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
      category: json['category'],
      pricePerKg: json['pricePerKg'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'category': category,
      'pricePerKg': pricePerKg,
    };
  }
}
