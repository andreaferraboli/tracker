import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tracker/models/product.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final Function(Product, double)? addProductToMeal;

  const ProductCard({
    Key? key,
    required this.product,
    required this.addProductToMeal,
  }) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  double _quantityInWeight = 0;
  int _quantityInUnits = 0;

  void _updateQuantities(double value) {
    setState(() {
      _quantityInWeight = value * widget.product.totalWeight;
      _quantityInUnits = value.toInt();
    });
  }

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

            // Nome e quantità disponibile del prodotto
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
                    '${widget.product.quantityOwned * widget.product.totalWeight} ${AppLocalizations.of(context)!.kgAvailable}',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Slider senza Expanded
                  Slider(
                    value: _quantityInUnits.toDouble(),
                    min: 0,
                    max: widget.product.quantityOwned.toDouble(),
                    divisions: widget.product.quantityOwned > 0
                        ? widget.product.quantityOwned.toInt()
                        : null,
                    label: '$_quantityInUnits',
                    onChanged: (value) => _updateQuantities(value),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // TextField per la quantità in peso
            Column(
              children: [
                SizedBox(
                  width: 40,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.weightInKg,
                    ),
                    controller: TextEditingController(
                      text: _quantityInWeight.toStringAsFixed(3),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _quantityInWeight = double.tryParse(value) ?? 0;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 40,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.units,
                    ),
                    controller: TextEditingController(
                      text: _quantityInUnits.toString(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _quantityInUnits = int.tryParse(value) ?? 0;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),

            // Pulsante per aggiungere il prodotto al pasto
            ElevatedButton(
              onPressed: () {
                if (widget.addProductToMeal != null) {
                  widget.addProductToMeal!(widget.product, _quantityInWeight);
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(8),
                minimumSize: const Size(16, 16),
              ),
              child: const Icon(Icons.add, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}
