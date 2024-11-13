import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tracker/models/product.dart';

class ProductAddedToMeal extends StatefulWidget {
  final Product product;
  final double selectedQuantity;
  final Function(double)? onQuantityUpdated;
  final VoidCallback? onDeleteProduct;

  const ProductAddedToMeal({
    Key? key,
    required this.product,
    required this.selectedQuantity,
    required this.onQuantityUpdated,
    required this.onDeleteProduct,
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
          title: Text(AppLocalizations.of(context)!.editQuantity),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.quantityInKg,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  tempQuantity =
                      double.tryParse(value) ?? widget.selectedQuantity;
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
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onQuantityUpdated?.call(tempQuantity);
              },
              child: Text(AppLocalizations.of(context)!.confirm),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primary,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.productName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${AppLocalizations.of(context)!.selectedQuantity}: ${widget.selectedQuantity.toStringAsFixed(3)} kg',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: Icon(Icons.edit,color: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: _showEditQuantityDialog,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: widget.onDeleteProduct,
            ),
          ],
        ),
      ),
    );
  }
}
