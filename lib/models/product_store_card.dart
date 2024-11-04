import 'package:flutter/material.dart';
import 'package:tracker/models/product.dart';
import 'package:tracker/routes/product_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProductStoreCard extends StatelessWidget {
  final Product product;

  const ProductStoreCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductScreen(product: product),
          ),
        );
      },
      child: Card(
        child: SizedBox(
          height: 150, // Regola l'altezza se necessario
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 80,
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
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Center(
                  child: Text(
                    '${AppLocalizations.of(context)!.quantity}: ${product.quantityOwned}',
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
