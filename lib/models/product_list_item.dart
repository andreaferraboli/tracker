import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tracker/l10n/app_localizations.dart';
import 'package:tracker/models/image_processor.dart';
import 'package:tracker/models/product.dart';
import 'package:tracker/routes/product_screen.dart';
import 'package:tracker/services/api_client.dart';
import 'package:tracker/routes/supermarket_screen.dart';
import 'package:tracker/services/category_services.dart';

class ProductListItem extends StatefulWidget {
  final Product product;
  final void Function(double) onTotalPriceChange;
  final void Function() updateProductLists;
  bool selected;

  ProductListItem({
    super.key,
    required this.product,
    required this.onTotalPriceChange,
    required this.updateProductLists,
    this.selected = false,
  });

  void setSelected(bool value) {
    selected = value;
  }

  @override
  _ProductListItemState createState() => _ProductListItemState();
}

class _ProductListItemState extends State<ProductListItem> {
  void _updateQuantity(int change) {
    setState(() {
      widget.product.buyQuantity += change;
      widget.product.quantityWeightOwned += change * widget.product.totalWeight;
      if (widget.product.buyQuantity < 0) {
        widget.product.buyQuantity = 0;
      }
    });
    widget.onTotalPriceChange(widget.product.price * change);
    widget.updateProductLists();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductScreen(product: widget.product),
          ),
        );
      },
      child: Card(
        color: widget.selected
            ? Theme.of(context).primaryColor
            : Theme.of(context).cardColor,
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
        elevation: 3,
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              if (widget.product.imageUrl.isNotEmpty)
                if (Theme.of(context).brightness == Brightness.dark)
                  FutureBuilder<Widget>(
                    future: ImageProcessor
                        .removeWhiteBackground(widget.product.imageUrl),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData) {
                          return snapshot.data!;
                        } else {
                          return CategoryServices.iconFromCategory(
                              widget.product.category);
                        }
                      } else {
                        return const CircularProgressIndicator();
                      }
                    },
                  )
                else
                  Image.network(
                    widget.product.imageUrl,
                    width: 100,
                    height: 100,
                    errorBuilder: (context, error, stackTrace) {
                      return CategoryServices.iconFromCategory(
                          widget.product.category);
                    },
                  )
              else
                CategoryServices.iconFromCategory(widget.product.category),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.product.productName,
                      style: TextStyle(
                        color: widget.selected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      AppLocalizations.of(context)!
                          .translateCategory(widget.product.category),
                      style: TextStyle(
                        color: widget.selected
                            ? Theme.of(context)
                                .colorScheme
                                .onPrimary
                                .withOpacity(0.9)
                            : Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.color
                                ?.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '€${widget.product.price.toStringAsFixed(2)}, ${AppLocalizations.of(context)!.total} €${(widget.product.price * widget.product.buyQuantity).toStringAsFixed(2)}',
                      style: TextStyle(
                        color: widget.selected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Material(
                            shape: const CircleBorder(),
                            color: widget.selected
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context)
                                    .elevatedButtonTheme
                                    .style
                                    ?.backgroundColor
                                    ?.resolve({}),
                            child: IconButton(
                              icon: Icon(
                                Icons.remove,
                                color: !widget.selected
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.primary,
                              ),
                              iconSize: 30.0,
                              padding: const EdgeInsets.all(10.0),
                              onPressed: () {
                                _updateQuantity(-1);
                              },
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text('${widget.product.buyQuantity}',
                                style: TextStyle(
                                    fontSize: 20.0,
                                    color: widget.selected
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onPrimary
                                        : Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color)),
                          ),
                          Material(
                            shape: const CircleBorder(),
                            color: widget.selected
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context)
                                    .elevatedButtonTheme
                                    .style
                                    ?.backgroundColor
                                    ?.resolve({}),
                            child: IconButton(
                              icon: Icon(
                                Icons.add,
                                color: !widget.selected
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.primary,
                              ),
                              iconSize: 30.0,
                              padding: const EdgeInsets.all(10.0),
                              onPressed: () {
                                _updateQuantity(1);
                              },
                            ),
                          ),
                        ],
                      ),
                      Text(
                        ' ${AppLocalizations.of(context)!.have}: ${widget.product.quantityOwned}',
                        style: TextStyle(
                          color: widget.selected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
