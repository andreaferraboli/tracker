import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tracker/l10n/app_localizations.dart';
import 'package:tracker/models/product.dart';
import 'package:tracker/routes/product_screen.dart';
import 'package:tracker/services/api_client.dart';
import 'package:tracker/services/category_services.dart';

class ProductListItem extends StatefulWidget {
  final Product product;
  final void Function(double, bool) onTotalPriceChange;

  const ProductListItem(
      {super.key, required this.product, required this.onTotalPriceChange});

  @override
  _ProductListItemState createState() => _ProductListItemState();
}

class _ProductListItemState extends State<ProductListItem> {
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
                    future: ApiClient.getImageWithRemovedBackground(
                        widget.product.imageUrl, widget.product.category),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      AppLocalizations.of(context)!
                          .translateCategory(widget.product.category),
                      style: const TextStyle(
                        color: Color.fromARGB(255, 106, 106, 106),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '€${widget.product.price.toStringAsFixed(2)}, ${AppLocalizations.of(context)!.total} €${(widget.product.price * widget.product.buyQuantity).toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
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
                            color: Theme.of(context)
                                .elevatedButtonTheme
                                .style
                                ?.backgroundColor
                                ?.resolve({}),
                            child: IconButton(
                              icon:
                                  const Icon(Icons.remove, color: Colors.white),
                              iconSize: 30.0,
                              padding: const EdgeInsets.all(10.0),
                              onPressed: () {
                                if (widget.product.buyQuantity > 0) {
                                  setState(() {
                                    widget.product.buyQuantity--;
                                  });
                                  widget.onTotalPriceChange(
                                      widget.product.price, false);
                                }
                              },
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text('${widget.product.buyQuantity}',
                                style: const TextStyle(fontSize: 20.0)),
                          ),
                          Material(
                            shape: const CircleBorder(),
                            color: Theme.of(context)
                                .elevatedButtonTheme
                                .style
                                ?.backgroundColor
                                ?.resolve({}),
                            child: IconButton(
                              icon: const Icon(Icons.add, color: Colors.white),
                              iconSize: 30.0,
                              padding: const EdgeInsets.all(10.0),
                              onPressed: () {
                                setState(() {
                                  widget.product.buyQuantity++;
                                });
                                widget.onTotalPriceChange(
                                    widget.product.price, true);
                              },
                            ),
                          ),
                        ],
                      ),
                      Text(
                          ' ${AppLocalizations.of(context)!.have}: ${widget.product.quantityOwned}'),
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
