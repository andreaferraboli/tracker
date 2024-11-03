import 'package:flutter/material.dart';
import 'package:tracker/models/product.dart';

class ProductStoreCard extends StatelessWidget {
  final Product product;

  const ProductStoreCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        // Set a fixed height for the card
        height: 100, // Adjust as needed
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 60,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(product.imageUrl),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Center(
                child: Text(
                  product.productName,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Center(
                child: Text(
                  'Quantità: ${product.quantityOwned}',
                  style: const TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
