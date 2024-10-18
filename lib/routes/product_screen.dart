import 'package:flutter/material.dart';
import 'package:tracker/models/product.dart';

class ProductScreen extends StatelessWidget {
  final Product product;

  const ProductScreen({super.key, required this.product});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.productName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${product.category}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Total Price: \$${product.totalPrice.toStringAsFixed(2)}'),
            Text('Unit Price: \$${product.price.toStringAsFixed(2)}'),
            Text('Quantity: ${product.quantity} ${product.unit}'),
            const SizedBox(height: 16),
            Text('Macronutrients (per 100g):', style: Theme.of(context).textTheme.titleMedium),
            ...product.macronutrients.entries.map((entry) =>
              Text('${entry.key}: ${entry.value}g')
            ),
            const SizedBox(height: 16),
            Text('Expiration Date: ${product.expirationDate}'),
            Text('Supermarket: ${product.supermarket}'),
            Text('Purchase Date: ${product.purchaseDate}'),
            Text('Barcode: ${product.barcode}'),
          ],
        ),
      ),
    );
  }
}