
import 'package:flutter/material.dart';
import 'package:tracker/models/product_bought.dart';
class Expense {
  final String id;
  final double totalAmount;
  final String date;
  final List<ProductBought> products;

  Expense({
    required this.id,
    required this.totalAmount,
    required this.date,
    required this.products,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      totalAmount: json['totalAmount'],
      date: json['date'],
      products: (json['products'] as List)
          .map((product) => ProductBought.fromJson(product))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'totalAmount': totalAmount,
      'date': date,
      'products': products.map((product) => product.toJson()).toList(),
    };
  }
}

