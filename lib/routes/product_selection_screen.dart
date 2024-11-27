import 'dart:io'; // Aggiunto per rilevare la piattaforma
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:tracker/l10n/app_localizations.dart';
import 'package:tracker/models/product_added_to_meal.dart';
import 'package:flutter/cupertino.dart'; // Aggiunto per i widget Cupertino

import '../models/category_selection_row.dart';
import '../models/meal_type.dart';
import '../models/product.dart';
import '../models/product_card.dart';
import '../models/quantiy_update_type.dart';
import '../services/toast_notifier.dart';

class ProductSelectionScreen extends StatefulWidget {
  final MealType mealType;

  const ProductSelectionScreen({
    super.key,
    required this.mealType,
  });

  @override
  _ProductSelectionScreenState createState() => _ProductSelectionScreenState();
}

class _ProductSelectionScreenState extends State<ProductSelectionScreen> {
  final Map<String, List<String>> defaultCategories = {
    'Breakfast': ['dessert', 'dairy_products', 'fruit', 'drinks'],
    'Lunch': ['pasta_bread_rice', 'sauces_condiments', 'fruit', 'vegetables'],
    'Snack': ['dessert', 'drinks', 'salty_snacks', 'fruit'],
    'Dinner': ['meat', 'fish', 'fruit', 'vegetables'],
  };
  List<Product> mealProducts = [];
  List<String> selectedCategories = [];
  List<Product> filteredProducts = [];
  List<Product> originalProducts =
      []; // Per mantenere la lista originale dei prodotti
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    selectedCategories =
        List<String>.from(defaultCategories[widget.mealType.name]!);
    _loadAvailableProducts(); // Carica i prodotti quando viene inizializzato lo stato
  }

  Future<void> _loadAvailableProducts() async {
    DocumentReference userDocRef = FirebaseFirestore.instance
        .collection('products')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    try {
      DocumentSnapshot snapshot = await userDocRef.get();

      if (snapshot.exists) {
        final List<dynamic> productsArray = snapshot['products'] ?? [];
        final List<Product> loadedProducts = [];

        for (var product in productsArray) {
          if (product['quantityWeightOwned'] > 0) {
            loadedProducts.add(Product.fromJson(product));
          }
        }

        setState(() {
          originalProducts =
              List.from(loadedProducts); // Backup della lista originale
          filteredProducts = loadedProducts
              .where((product) => selectedCategories.contains(product.category))
              .toList(); // Lista filtrata
        });
      } else {
        ToastNotifier.showError('Nessun documento trovato per l\'utente.');
      }
    } catch (error) {
      ToastNotifier.showError('Errore nel recupero dei prodotti: $error');
    }
  }

  void _saveMeal() async {
    try {
      DocumentReference userDocRef = FirebaseFirestore.instance
          .collection('products')
          .doc(FirebaseAuth.instance.currentUser?.uid);
      DocumentSnapshot userDoc = await userDocRef.get();
      List<dynamic> products = userDoc['products'];
      Map<String, double> macronutrients = {};
      double totalExpense = 0;
      List<Map<String, dynamic>> productsToSave =
          mealProducts.map((mealProduct) {
        mealProduct.macronutrients.forEach((key, value) {
          macronutrients[key] = (macronutrients[key] ?? 0) +
              value * (mealProduct.selectedQuantity * 10);
        });
        double pricePerKg = mealProduct.price / mealProduct.totalWeight;
        double productExpense = pricePerKg * mealProduct.selectedQuantity;
        totalExpense += productExpense;
        int index = products.indexWhere(
            (product) => product['productId'] == mealProduct.productId);
        if (index != -1) {
          // Controlla il tipo di aggiornamento della quantità
          switch (mealProduct.quantityUpdateType) {
            case QuantityUpdateType.slider:
              // Aggiorna quantità in unità
              products[index]['quantityUnitOwned'] -=
                  (mealProduct.selectedQuantity / mealProduct.unitWeight)
                      .round();
              products[index]['quantityWeightOwned'] -=
                  mealProduct.selectedQuantity;
              if (products[index]['quantityUnitOwned'] <= 0) {
                // Aggiorna il conteggio totale se le unità raggiungono zero
                products[index]['quantityOwned'] -= 1;
                products[index]['quantityUnitOwned'] = mealProduct.quantity;
              }
              break;

            case QuantityUpdateType.weight:
              // Aggiorna quantità in base al peso

              if (products[index]['quantityWeightOwned'] >=
                  mealProduct.unitWeight) {
                if (mealProduct.selectedQuantity <=
                    mealProduct.unitWeight * mealProduct.quantityUnitOwned) {
                  products[index]['quantityUnitOwned'] -=
                      (mealProduct.selectedQuantity / mealProduct.unitWeight)
                          .ceil();
                  if (products[index]['quantityUnitOwned'] <= 0) {
                    products[index]['quantityOwned'] -= 1;
                    products[index]['quantityUnitOwned'] = mealProduct.quantity;
                  }
                } else {
                  products[index]['quantityOwned'] -= 1;
                  if ((products[index]['quantityWeightOwned'] -
                              mealProduct.selectedQuantity) %
                          mealProduct.totalWeight ==
                      0) {
                    products[index]['quantityUnitOwned'] = mealProduct.quantity;
                  } else {
                    products[index]['quantityUnitOwned'] = mealProduct
                            .quantity -
                        ((mealProduct.selectedQuantity / mealProduct.unitWeight)
                                .ceil() -
                            mealProduct.quantityUnitOwned);
                  }
                }
              }
              products[index]['quantityWeightOwned'] -= double.parse(
                  (mealProduct.selectedQuantity).toStringAsFixed(3));
              if (products[index]['quantityWeightOwned'] <= 0) {
                // Aggiorna il conteggio totale se il peso raggiunge zero
                products[index]['quantityOwned'] = 0;
                products[index]['quantityUnitOwned'] = 0;
                products[index]['quantityWeightOwned'] = 0;
              }
              break;

            case QuantityUpdateType.units:
              // Aggiorna quantità totale
              products[index]['quantityOwned'] -=
                  mealProduct.selectedQuantity ~/ mealProduct.totalWeight;
              products[index]['quantityWeightOwned'] -=
                  mealProduct.selectedQuantity;
              if (products[index]['quantityOwned'] <= 0 &&
                  products[index]['quantityWeightOwned'] <=
                      mealProduct.unitWeight) {
                products[index]['quantityOwned'] = 0;
                products[index]['quantityUnitOwned'] = 0;
              }
              break;

            default:
              // Gestione per tipi di aggiornamento non definiti
              ToastNotifier.showError('Tipo di aggiornamento non supportato');
          }
          if (products[index]['quantityOwned'] <= 0) {
            products[index]['quantityUnitOwned'] = 0;
          }
          products[index]['quantityWeightOwned'] = double.parse((products[index]
                              ['quantityWeightOwned'])
                          .toStringAsFixed(3))
                      .toString()
                      .endsWith('9') ||
                  double.parse((products[index]['quantityWeightOwned'])
                          .toStringAsFixed(3))
                      .toString()
                      .endsWith('1')
              ? double.parse(
                  (products[index]['quantityWeightOwned']).toStringAsFixed(2))
              : double.parse(
                  (products[index]['quantityWeightOwned']).toStringAsFixed(3));
        }

        return {
          'idProdotto': mealProduct.productId,
          'productName': mealProduct.productName,
          'price': productExpense.toStringAsFixed(3),
          'category': mealProduct.category,
          'quantitySelected': mealProduct.selectedQuantity,
        };
      }).toList();
      await userDocRef.update({
        "products": products,
      });
      userDocRef = FirebaseFirestore.instance
          .collection('meals')
          .doc(FirebaseAuth.instance.currentUser!.uid);
      await userDocRef.update({
        'meals': FieldValue.arrayUnion([
          {
            'id': DateTime.now().toIso8601String(),
            'mealType': widget.mealType.name,
            'totalExpense': totalExpense.toStringAsFixed(3),
            'products': productsToSave,
            'macronutrients': macronutrients,
            'date': DateFormat('yyyy-MM-dd').format(selectedDate),
          }
        ])
      });
      if (!mounted) return;
      ToastNotifier.showSuccess(
          context, AppLocalizations.of(context)!.mealSavedSuccessfully);
      int count = 0;
      Navigator.of(context).popUntil((route) {
        return count++ == 2;
      });
    } catch (e) {
      ToastNotifier.showError('Errore durante il salvataggio del pasto: $e');
    }
  }

  void _showFilterDialog() {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            content: CategorySelectionRow(
              mealType: widget.mealType,
              categories: selectedCategories,
              onCategoriesUpdated: updateCategories,
            ),
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: CategorySelectionRow(
              mealType: widget.mealType,
              categories: selectedCategories,
              onCategoriesUpdated: updateCategories,
            ),
          );
        },
      );
    }
  }

  void _showSearchDialog() {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          String searchQuery = '';
          return CupertinoAlertDialog(
            title: Text(AppLocalizations.of(context)!.searchProductByName),
            content: CupertinoTextField(
              onChanged: (value) {
                searchQuery = value;
              },
              placeholder: AppLocalizations.of(context)!.insertProductName,
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(AppLocalizations.of(context)!.cancel),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              CupertinoDialogAction(
                child: Text(AppLocalizations.of(context)!.search),
                onPressed: () {
                  setState(() {
                    filteredProducts = originalProducts
                        .where((product) => product.productName
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()))
                        .toList();
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          String searchQuery = '';
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.searchProductByName),
            content: TextField(
              onChanged: (value) {
                searchQuery = value;
              },
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.insertProductName,
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(AppLocalizations.of(context)!.cancel),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text(AppLocalizations.of(context)!.search),
                onPressed: () {
                  setState(() {
                    filteredProducts = originalProducts
                        .where((product) => product.productName
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()))
                        .toList();
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  updateCategories(List<String> categories) {
    setState(() {
      selectedCategories = categories;
      if (selectedCategories.isEmpty) {
        filteredProducts = originalProducts;
      } else {
        filteredProducts = originalProducts
            .where((product) => selectedCategories.contains(product.category))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: Text(
                  "${AppLocalizations.of(context)!.search}-${widget.mealType.mealString(context)}"),
              backgroundColor: widget.mealType.color,
            ),
            child: _buildBody(),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text(
                  "${AppLocalizations.of(context)!.search}-${widget.mealType.mealString(context)}"),
              backgroundColor: widget.mealType.color,
            ),
            body: _buildBody(),
          );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Platform.isIOS
                ? CupertinoButton.filled(
                    onPressed: mealProducts.isNotEmpty ? _saveMeal : null,
                    child: Text(AppLocalizations.of(context)!.save_meal),
                  )
                : ElevatedButton(
                    onPressed: mealProducts.isNotEmpty ? _saveMeal : null,
                    child: Text(AppLocalizations.of(context)!.save_meal),
                  ),
            Platform.isIOS
                ? CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _showFilterDialog,
                    child: const Icon(CupertinoIcons.slider_horizontal_3),
                  )
                : IconButton(
                    onPressed: _showFilterDialog,
                    icon: const Icon(Icons.filter_list),
                  ),
            Platform.isIOS
                ? CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _showSearchDialog,
                    child: const Icon(CupertinoIcons.search),
                  )
                : IconButton(
                    onPressed: _showSearchDialog,
                    icon: const Icon(Icons.search),
                  ),
            Platform.isIOS
                ? CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Icon(CupertinoIcons.calendar),
                    onPressed: () async {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (context) {
                          return Container(
                            height: 250,
                            color: CupertinoColors.systemBackground,
                            child: CupertinoDatePicker(
                              mode: CupertinoDatePickerMode.date,
                              initialDateTime: selectedDate,
                              onDateTimeChanged: (DateTime newDate) {
                                setState(() {
                                  selectedDate = newDate;
                                });
                              },
                            ),
                          );
                        },
                      );
                    },
                  )
                : IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2015, 8),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null && picked != selectedDate) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                  ),
            Platform.isIOS
                ? CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Icon(CupertinoIcons.refresh),
                    onPressed: () {
                      setState(() {
                        filteredProducts = originalProducts;
                      });
                    },
                  )
                : IconButton(
                    onPressed: () {
                      setState(() {
                        filteredProducts = originalProducts;
                      });
                    },
                    icon: const Icon(Icons.refresh),
                  ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ExpansionTile(
                  title: Text(
                    AppLocalizations.of(context)!.selectedProducts,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  initiallyExpanded: mealProducts.isNotEmpty,
                  leading: const Icon(Icons.food_bank),
                  children: mealProducts.isEmpty
                      ? [
                          Center(
                            child: Text(AppLocalizations.of(context)!
                                .noSelectedProducts),
                          ),
                        ]
                      : [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            itemCount: mealProducts.length,
                            itemBuilder: (context, index) {
                              final product = mealProducts[index];
                              return ProductAddedToMeal(
                                product: product,
                                selectedQuantity: product.selectedQuantity,
                                onQuantityUpdated: (quantity) {
                                  setState(() {
                                    mealProducts[index] = product.copyWith(
                                        selectedQuantity: quantity);
                                  });
                                },
                                onDeleteProduct: () {
                                  product.quantityUpdateType = null;
                                  product.selectedQuantity = 0;
                                  setState(() {
                                    filteredProducts.add(product);
                                    mealProducts.remove(product);
                                  });
                                },
                              );
                            },
                          ),
                        ],
                ),
                ExpansionTile(
                  title: Text(
                    AppLocalizations.of(context)!.listProducts,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  initiallyExpanded: true,
                  leading: const Icon(Icons.list),
                  children: filteredProducts.isEmpty
                      ? [
                          Center(
                              child: Text(AppLocalizations.of(context)!
                                  .noAvailableProducts))
                        ]
                      : [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = filteredProducts[index];
                              return ProductCard(
                                product: product,
                                addProductToMeal: (product, quantity) {
                                  setState(() {
                                    mealProducts.add(product.copyWith(
                                        selectedQuantity: quantity));
                                    originalProducts.remove(product);
                                    filteredProducts.remove(product);
                                  });
                                },
                              );
                            },
                          ),
                        ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
