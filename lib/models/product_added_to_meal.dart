import 'package:flutter/material.dart';
import 'package:tracker/models/product.dart';

class ProductAddedToMeal extends StatefulWidget {
  final Product product;
  final double selectedQuantity;
  final Function(double)? onQuantityUpdated;

  const ProductAddedToMeal({
    Key? key,
    required this.product,
    required this.selectedQuantity,
    required this.onQuantityUpdated,
  }) : super(key: key);

  @override
  State<ProductAddedToMeal> createState() => _ProductAddedToMealState();
}

class _ProductAddedToMealState extends State<ProductAddedToMeal> {
  void _showEditQuantityDialog() {
    double tempQuantity = widget.selectedQuantity;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifica Quantità'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Quantità in peso (kg)',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  tempQuantity = double.tryParse(value) ?? widget.selectedQuantity;
                },
                controller: TextEditingController(
                  text: widget.selectedQuantity.toStringAsFixed(2),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onQuantityUpdated?.call(tempQuantity);
              },
              child: const Text('Conferma'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primary, // Sfondo primario del tema
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

            // Dettagli prodotto e quantità selezionata
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.productName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.product.quantityOwned * widget.product.totalWeight} kg disponibili',
                    style: TextStyle(
                      color: Colors.grey[300],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Quantità selezionata: ${widget.selectedQuantity.toStringAsFixed(2)} kg',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Pulsante di modifica quantità
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: _showEditQuantityDialog,
            ),
          ],
        ),
      ),
    );
  }
}
