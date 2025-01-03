import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/models/base_product.dart';
import 'package:tracker/models/discounted_product.dart';
import 'package:tracker/models/product.dart';
import 'package:tracker/models/quantiy_update_type.dart';
import 'package:tracker/providers/discounted_products_provider.dart';
import 'package:collection/collection.dart';

import '../routes/product_screen.dart';

class ProductCard extends ConsumerStatefulWidget {
  final Product product;
  final Function(Product, double)? addProductToMeal;

  const ProductCard({
    super.key,
    required this.product,
    required this.addProductToMeal,
  });

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard> {
  double _weightFromTextField = 0; // Peso in grammi inserito nel TextField
  int _unitsFromTextField = 0; // Quantità in unità inserita nel TextField
  late TextEditingController _weightController;
  late TextEditingController _unitsController;
  late FocusNode _weightFocusNode;
  late FocusNode _unitsFocusNode;
  bool useDiscountedValidation = false;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(text: "0");
    _unitsController = TextEditingController(text: "0");
    _weightFocusNode = FocusNode();
    _unitsFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _unitsController.dispose();
    _weightFocusNode.dispose();
    _unitsFocusNode.dispose();
    super.dispose();
  }

  // Metodo per aggiornare le variabili dello Slider

  // Metodo per validare il valore del peso inserito nel TextField
  void _validateWeight(String value) {
    if (value.isEmpty) {
      setState(() {
        _weightFromTextField = 0;
        _unitsFromTextField = 0;
        if (!_unitsFocusNode.hasFocus) {
          _unitsController.text = '0';
        }
      });
      return;
    }

    try {
      final double newWeight = double.parse(value);
      if (newWeight < 0) {
        throw const FormatException("Il peso non può essere negativo");
      }

      final discountedProducts = ref.read(discountedProductsProvider);
      final discountedProduct = discountedProducts
          .firstWhereOrNull((dp) => dp.productId == widget.product.productId);

      final double maxWeight =
          useDiscountedValidation && discountedProduct != null
              ? discountedProduct.discountedQuantityWeightOwned * 1000
              : widget.product.quantityWeightOwned * 1000;

      if (newWeight > maxWeight) {
        throw const FormatException("Peso superiore alla quantità disponibile");
      }

      setState(() {
        _weightFromTextField = newWeight;
        if (!_unitsFocusNode.hasFocus) {
          _unitsController.text = _unitsFromTextField.toString();
        }
      });
    } catch (e) {
      _showErrorDialog();
    }
  }

  // Metodo per validare la quantità in unità inserita nel TextField
  void _validateUnits(String value) {
    if (value.isEmpty) {
      setState(() {
        _unitsFromTextField = 0;
        if (!_weightFocusNode.hasFocus) {
          _weightController.text = _weightFromTextField.toStringAsFixed(0);
        }
      });
      return;
    }

    try {
      final int newUnits = int.parse(value);
      if (newUnits < 0) {
        setState(() {
          _unitsFromTextField = 0;
          if (!_weightFocusNode.hasFocus) {
            _weightController.text = _weightFromTextField.toStringAsFixed(0);
          }
        });
        throw const FormatException("La quantità non può essere negativa");
      }

      final discountedProducts = ref.read(discountedProductsProvider);
      final discountedProduct = discountedProducts
          .firstWhereOrNull((dp) => dp.productId == widget.product.productId);

      final num maxUnits = useDiscountedValidation && discountedProduct != null
          ? discountedProduct.discountedQuantityOwned.toInt()
          : widget.product.quantityOwned;

      if (newUnits > maxUnits) {
        throw const FormatException("Quantità superiore a quella disponibile");
      }

      setState(() {
        _unitsFromTextField = newUnits;
        if (!_weightFocusNode.hasFocus) {
          _weightController.text = _weightFromTextField.toStringAsFixed(0);
        }
      });
    } catch (e) {
      _showErrorDialog();
    }
  }

  // Mostra un dialog di errore
  void _showErrorDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Theme.of(context).platform == TargetPlatform.iOS
              ? CupertinoAlertDialog(
                  title: Text(AppLocalizations.of(context)!.error),
                  content: Text(AppLocalizations.of(context)!.invalidValue),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(AppLocalizations.of(context)!.ok),
                    ),
                  ],
                )
              : AlertDialog(
                  title: Text(AppLocalizations.of(context)!.error),
                  content: Text(AppLocalizations.of(context)!.invalidValue),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(AppLocalizations.of(context)!.ok),
                    ),
                  ],
                );
        });
  }

  @override
  Widget build(BuildContext context) {
    final discountedProducts = ref.read(discountedProductsProvider);
    final DiscountedProduct? discountedProduct = discountedProducts
        .firstWhereOrNull((dp) => dp.productId == widget.product.productId);

    // Calcola il valore massimo per lo slider in base alla selezione del prodotto scontato
    double maxQuantity = useDiscountedValidation && discountedProduct != null
        ? discountedProduct.discountedQuantityUnitOwned.toDouble()
        : widget.product.quantityUnitOwned > 0
            ? widget.product.quantityUnitOwned.toDouble()
            : 0;

    // Calcola la quantità da mostrare in base alla selezione del prodotto scontato
    final double displayQuantityWeight =
        useDiscountedValidation && discountedProduct != null
            ? discountedProduct.discountedQuantityWeightOwned
            : widget.product.quantityWeightOwned;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductScreen(product: widget.product),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Immagine del prodotto o spazio riservato
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

              // Dettagli del prodotto
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
                      '${(displayQuantityWeight * 1000).toStringAsFixed((displayQuantityWeight * 1000) % 1 == 0 ? 0 : 2)} ${AppLocalizations.of(context)!.gramsAvailable}',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Slider per selezionare la quantità
                    Theme.of(context).platform == TargetPlatform.iOS
                        ? CupertinoSlider(
                            value: useDiscountedValidation &&
                                    discountedProduct != null
                                ? discountedProduct.sliderValue
                                : widget.product.sliderValue,
                            min: 0,
                            max: maxQuantity,
                            divisions: useDiscountedValidation &&
                                    discountedProduct != null
                                ? discountedProduct.discountedQuantityUnitOwned
                                : widget.product.quantityUnitOwned > 0
                                    ? widget.product.quantityUnitOwned
                                    : null,
                            onChanged: (value) {
                              setState(() {
                                if (useDiscountedValidation &&
                                    discountedProduct != null) {
                                  discountedProduct.sliderValue = value;
                                } else {
                                  widget.product.sliderValue = value;
                                }
                              });
                            },
                          )
                        : Slider(
                            value: useDiscountedValidation &&
                                    discountedProduct != null
                                ? discountedProduct.sliderValue
                                : widget.product.sliderValue,
                            min: 0,
                            max: maxQuantity,
                            divisions: useDiscountedValidation &&
                                    discountedProduct != null
                                ? discountedProduct.discountedQuantityUnitOwned
                                : widget.product.quantityUnitOwned > 0
                                    ? widget.product.quantityUnitOwned
                                    : null,
                            label: useDiscountedValidation
                                ? null
                                : '${useDiscountedValidation && discountedProduct != null ? discountedProduct.sliderValue : widget.product.sliderValue}',
                            onChanged: (value) {
                              setState(() {
                                if (useDiscountedValidation &&
                                    discountedProduct != null) {
                                  discountedProduct.sliderValue = value;
                                } else {
                                  widget.product.sliderValue = value;
                                }
                              });
                            },
                          ),

                    // Input peso e unità
                    Row(
                      children: [
                        Text(AppLocalizations.of(context)!.weightInGrams),
                        const SizedBox(width: 8),
                        Expanded(
                          child:
                              Theme.of(context).platform == TargetPlatform.iOS
                                  ? CupertinoTextField(
                                      keyboardType: TextInputType.number,
                                      placeholder: AppLocalizations.of(context)!
                                          .weightInGrams,
                                      controller: _weightController,
                                      focusNode: _weightFocusNode,
                                      onChanged: (value) {
                                        _validateWeight(value);
                                      },
                                    )
                                  : TextField(
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        hintText: AppLocalizations.of(context)!
                                            .weightInGrams,
                                      ),
                                      controller: _weightController,
                                      focusNode: _weightFocusNode,
                                      onChanged: (value) {
                                        _validateWeight(value);
                                      },
                                    ),
                        ),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.of(context)!.units),
                        const SizedBox(width: 8),
                        Expanded(
                          child:
                              Theme.of(context).platform == TargetPlatform.iOS
                                  ? CupertinoTextField(
                                      keyboardType: TextInputType.number,
                                      placeholder:
                                          AppLocalizations.of(context)!.units,
                                      controller: _unitsController,
                                      focusNode: _unitsFocusNode,
                                      onChanged: (value) {
                                        _validateUnits(value);
                                      },
                                    )
                                  : TextField(
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        hintText:
                                            AppLocalizations.of(context)!.units,
                                      ),
                                      controller: _unitsController,
                                      focusNode: _unitsFocusNode,
                                      onChanged: (value) {
                                        _validateUnits(value);
                                      },
                                    ),
                        ),
                        if (discountedProduct != null)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                useDiscountedValidation =
                                    !useDiscountedValidation;
                                widget.product.useDiscountedValidation =
                                    useDiscountedValidation;
                                // Reset dei valori quando si cambia modalità
                                widget.product.sliderValue = 0;
                                _weightFromTextField = 0;
                                _unitsFromTextField = 0;
                                _weightController.text = '0';
                                _unitsController.text = '0';
                              });
                            },
                            child: Icon(Icons.discount,
                                color: useDiscountedValidation
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Bottone per aggiungere il prodotto
              Theme.of(context).platform == TargetPlatform.iOS
                  ? CupertinoButton(
                      onPressed: (_weightFromTextField > 0 ||
                              _unitsFromTextField > 0 ||
                              (useDiscountedValidation &&
                                          discountedProduct != null
                                      ? discountedProduct.sliderValue
                                      : widget.product.sliderValue) >
                                  0)
                          ? () {
                              double quantity = 0;
                              final selectedProduct = useDiscountedValidation &&
                                      discountedProduct != null
                                  ? discountedProduct
                                  : widget.product;

                              if (selectedProduct.sliderValue > 0) {
                                selectedProduct.quantityUpdateType =
                                    QuantityUpdateType.slider;
                                quantity = selectedProduct.sliderValue *
                                    widget.product.unitWeight;
                              } else if (_unitsFromTextField > 0) {
                                selectedProduct.quantityUpdateType =
                                    QuantityUpdateType.units;
                                quantity = _unitsFromTextField.toDouble() *
                                    widget.product.totalWeight;
                              } else if (_weightFromTextField > 0) {
                                selectedProduct.quantityUpdateType =
                                    QuantityUpdateType.weight;
                                quantity = double.parse(
                                    (_weightFromTextField / 1000)
                                        .toStringAsFixed(3));
                              }
                              if (widget.addProductToMeal != null) {
                                widget.addProductToMeal!(
                                    widget.product, quantity);
                              }
                            }
                          : null,
                      padding: const EdgeInsets.all(8),
                      child: const Icon(CupertinoIcons.add, size: 16),
                    )
                  : ElevatedButton(
                      onPressed: (_weightFromTextField > 0 ||
                              _unitsFromTextField > 0 ||
                              (useDiscountedValidation &&
                                          discountedProduct != null
                                      ? discountedProduct.sliderValue
                                      : widget.product.sliderValue) >
                                  0)
                          ? () {
                              double quantity = 0;
                              final BaseProduct selectedProduct =
                                  useDiscountedValidation &&
                                          discountedProduct != null
                                      ? discountedProduct
                                      : widget.product;

                              if (selectedProduct.sliderValue > 0) {
                                selectedProduct.quantityUpdateType =
                                    QuantityUpdateType.slider;
                                quantity = selectedProduct.sliderValue *
                                    widget.product.unitWeight;
                              } else if (_unitsFromTextField > 0) {
                                selectedProduct.quantityUpdateType =
                                    QuantityUpdateType.units;
                                quantity = _unitsFromTextField.toDouble() *
                                    widget.product.totalWeight;
                              } else if (_weightFromTextField > 0) {
                                selectedProduct.quantityUpdateType =
                                    QuantityUpdateType.weight;
                                quantity = double.parse(
                                    (_weightFromTextField / 1000)
                                        .toStringAsFixed(3));
                              }
                              if (widget.addProductToMeal != null) {
                                widget.addProductToMeal!(
                                    widget.product, quantity);
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(16, 16),
                      ),
                      child: const Icon(Icons.add, size: 16),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
