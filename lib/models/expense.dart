import 'package:tracker/models/product_bought.dart';

class Expense {
  final String id;
  final double totalAmount;
  final String date;
  final String supermarket;
  final List<ProductBought> products;

  Expense({
    required this.id,
    required this.totalAmount,
    required this.date,
    required this.products,
    required this.supermarket,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      totalAmount: json['totalAmount'],
      date: json['date'],
      supermarket: json['supermarket'],
      products: (json['products'] as List)
          .map((product) => ProductBought.fromJson(product))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'totalAmount': totalAmount,
      'supermarket': supermarket,
      'date': date,
      'products': products.map((product) => product.toJson()).toList(),
    };
  }
}
