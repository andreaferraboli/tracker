import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/l10n/app_localizations.dart';
import 'package:tracker/models/discounted_product.dart';
import 'package:tracker/models/image_processor.dart';
import 'package:tracker/models/product.dart';
import 'package:tracker/providers/discounted_products_provider.dart';
import 'package:tracker/routes/product_screen.dart';
import 'package:tracker/services/category_services.dart';

class ProductListItem extends ConsumerStatefulWidget {
  final Product product;
  final void Function(double) onTotalPriceChange;
  final void Function() updateProductLists;
  late bool selected;

  ProductListItem({
    super.key,
    required this.product,
    required this.onTotalPriceChange,
    required this.updateProductLists,
    this.selected = false,
  });

  final GlobalKey<ProductListItemState> _key = GlobalKey();

  void setSelected(bool value) {
    selected = value;
  }

  // Metodo per chiamare updateQuantity sullo stato
  void updateQuantity(int change) {
    _key.currentState?.updateQuantity(change);
  }

  @override
  ProductListItemState createState() => ProductListItemState();
}

class ProductListItemState extends ConsumerState<ProductListItem> {
  final TextEditingController _discountedPriceController = TextEditingController();

  void updateQuantity(int change) {
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
  void dispose() {
    _discountedPriceController.dispose();
    super.dispose();
  }

  void _showDiscountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

        return isIOS
            ? CupertinoAlertDialog(
                title: Text(AppLocalizations.of(context)!.discountedPrice),
                content: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CupertinoTextField(
                    controller: _discountedPriceController,
                    keyboardType: TextInputType.number,
                    placeholder: AppLocalizations.of(context)!.enterDiscountedPrice,
                  ),
                ),
                actions: [
                  CupertinoDialogAction(
                    child: Text(AppLocalizations.of(context)!.cancel),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoDialogAction(
                    child: Text(AppLocalizations.of(context)!.save),
                    onPressed: () {
                      _saveDiscountedProduct();
                      Navigator.pop(context);
                    },
                  ),
                ],
              )
            : AlertDialog(
                title: Text(AppLocalizations.of(context)!.discountedPrice),
                content: TextField(
                  controller: _discountedPriceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.enterDiscountedPrice,
                  ),
                ),
                actions: [
                  TextButton(
                    child: Text(AppLocalizations.of(context)!.cancel),
                    onPressed: () => Navigator.pop(context),
                  ),
                  TextButton(
                    child: Text(AppLocalizations.of(context)!.save),
                    onPressed: () {
                      _saveDiscountedProduct();
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
      },
    );
  }

  void _saveDiscountedProduct() {
    final discountedPrice = double.tryParse(_discountedPriceController.text);
    if (discountedPrice != null) {
      final discountedProduct = DiscountedProduct(
        productId: widget.product.productId,
        quantityBought: widget.product.buyQuantity,
        discountedQuantityOwned: widget.product.quantityOwned,
        discountedQuantityWeightOwned: widget.product.quantityWeightOwned,
        discountedQuantityUnitOwned: widget.product.quantityUnitOwned,
        discountedPrice: discountedPrice,
      );
      ref.read(discountedProductsProvider.notifier).addDiscountedProduct(discountedProduct);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          isIOS
              ? CupertinoPageRoute(
                  builder: (context) => ProductScreen(product: widget.product),
                )
              : MaterialPageRoute(
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
                  FutureBuilder<Uint8List?>(
                    future: ImageProcessor.removeWhiteBackground(
                        widget.product.imageUrl),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData) {
                          return SizedBox(
                            width: 40,
                            height: 40,
                            child: Image.memory(
                              snapshot.data!,
                              fit: BoxFit.cover,
                            ),
                          );
                        } else {
                          return CategoryServices.iconFromCategory(
                              widget.product.category);
                        }
                      } else {
                        return const CupertinoActivityIndicator();
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
                                isIOS ? CupertinoIcons.minus : Icons.remove,
                                color: !widget.selected
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.primary,
                              ),
                              iconSize: 30.0,
                              padding: const EdgeInsets.all(10.0),
                              onPressed: () {
                                updateQuantity(-1);
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
                                        ? Theme.of(context).colorScheme.onPrimary
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
                                isIOS ? CupertinoIcons.plus : Icons.add,
                                color: !widget.selected
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.primary,
                              ),
                              iconSize: 30.0,
                              padding: const EdgeInsets.all(10.0),
                              onPressed: () {
                                updateQuantity(1);
                              },
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(
                          isIOS ? CupertinoIcons.tag : Icons.local_offer,
                          color: widget.selected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: _showDiscountDialog,
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
