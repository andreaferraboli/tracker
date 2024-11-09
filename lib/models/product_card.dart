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
  double _sliderValue = 0; // Slider per la quantità unità
  double _weightFromTextField = 0; // Peso in grammi inserito nel TextField
  int _unitsFromTextField = 0; // Quantità in unità inserita nel TextField
  late TextEditingController _weightController;
  late TextEditingController _unitsController;
  late FocusNode _weightFocusNode;
  late FocusNode _unitsFocusNode;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
        text: widget.product.quantityWeightOwned.toStringAsFixed(0));
    _unitsController = TextEditingController(
        text: widget.product.quantityOwned.toString());
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
  void _updateSliderValue(double value) {
    setState(() {
      _sliderValue = value;
      widget.product.quantityUnitOwned = value.toInt();
      _weightFromTextField = _sliderValue * widget.product.totalWeight * 1000;
    });
  }

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
        throw FormatException("Il peso non può essere negativo");
      }

      setState(() {
        _weightFromTextField = newWeight;
        widget.product.quantityWeightOwned = newWeight;
        _unitsFromTextField = (newWeight / widget.product.totalWeight).toInt();
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
    try {
      final int newUnits = int.parse(value);
      if (newUnits < 0) {
        throw FormatException("La quantità non può essere negativa");
      }

      setState(() {
        _unitsFromTextField = newUnits;
        widget.product.quantityOwned = newUnits as double;
        _weightFromTextField = newUnits * widget.product.totalWeight * 1000;
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
        return AlertDialog(
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double maxQuantity = widget.product.quantityUnitOwned.toDouble();

    return Card(
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.product.quantityWeightOwned} ${AppLocalizations.of(context)!.gramsAvailable}',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _sliderValue,
                    min: 0,
                    max: maxQuantity,
                    divisions: widget.product.quantityUnitOwned > 0
                        ? widget.product.quantityUnitOwned
                        : null,
                    label: '$_sliderValue',
                    onChanged: (value) {
                      _updateSliderValue(value);
                    },
                  ),
                  Row(
                    children: [
                      Text(AppLocalizations.of(context)!.weightInGrams),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 40,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText:
                            AppLocalizations.of(context)!.weightInGrams,
                          ),
                          controller: _weightController,
                          focusNode: _weightFocusNode,
                          onChanged: (value) {
                            _validateWeight(value);
                          },
                        ),
                      ),
                      Text(AppLocalizations.of(context)!.units),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 40,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.units,
                          ),
                          controller: _unitsController,
                          focusNode: _unitsFocusNode,
                          onChanged: (value) {
                            _validateUnits(value);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                if (widget.addProductToMeal != null) {
                  widget.addProductToMeal!(
                      widget.product, _weightFromTextField / 1000);
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
