import 'package:flutter/material.dart';
import 'package:tracker/models/product.dart';

class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({
    required this.product,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  double _quantity = 0;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Immagine del prodotto
            if (widget.product.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.product.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              )
            else
              const SizedBox(width: 80, height: 80),
            const SizedBox(width: 16),
            // Nome del prodotto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.productName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.product.quantity} ${widget.product.unit} disponibili',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Campo di testo per inserire la quantità
            SizedBox(
              width: 80,
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Quantità',
                ),
                onChanged: (value) {
                  setState(() {
                    _quantity = double.tryParse(value) ?? 0;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}