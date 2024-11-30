import 'dart:io'; // Aggiunto per rilevare la piattaforma
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tracker/l10n/app_localizations.dart';
import 'package:tracker/models/product_added_to_meal.dart';
import 'package:flutter/cupertino.dart'; // Aggiunto per i widget Cupertino
import 'package:tracker/providers/discounted_products_provider.dart';
import 'package:tracker/providers/products_provider.dart';

import '../models/category_selection_row.dart';
import '../models/meal_type.dart';
import '../models/product.dart';
import '../models/product_card.dart';
import '../models/quantiy_update_type.dart';
import '../services/toast_notifier.dart';

class ProductSelectionScreen extends ConsumerStatefulWidget {
  final MealType mealType;

  const ProductSelectionScreen({
    super.key,
    required this.mealType,
  });

  @override
  ProductSelectionScreenState createState() => ProductSelectionScreenState();
}

class ProductSelectionScreenState
    extends ConsumerState<ProductSelectionScreen> {
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
    DocumentReference discountedDocRef = FirebaseFirestore.instance
        .collection('discounted_products')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    try {
      DocumentSnapshot snapshot = await userDocRef.get();
      DocumentSnapshot discountedSnapshot = await discountedDocRef.get();

      if (snapshot.exists) {
        final List<dynamic> productsArray = snapshot['products'] ?? [];
        final List<dynamic> discountedProducts =
            discountedSnapshot.exists && discountedSnapshot.data() != null
                ? (discountedSnapshot.data()
                        as Map<String, dynamic>)['discounted_products'] ??
                    []
                : [];
        final List<Product> loadedProducts = [];

        for (var product in productsArray) {
          // Check if there's a discounted version of this product
          final discountedProduct = discountedProducts.firstWhere(
            (dp) => dp['productId'] == product['productId'],
            orElse: () => null,
          );

          // Add product if either regular or discounted version has weight > 0
          if (product['quantityWeightOwned'] > 0 ||
              (discountedProduct != null &&
                  discountedProduct['discountedQuantityWeightOwned'] > 0)) {
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
    //TODO:non va il salvataggio con i prodotti scontati
    // try {
    DocumentReference userDocRef = FirebaseFirestore.instance
        .collection('products')
        .doc(FirebaseAuth.instance.currentUser?.uid);
    DocumentReference discountedDocRef = FirebaseFirestore.instance
        .collection('discounted_products')
        .doc(FirebaseAuth.instance.currentUser?.uid);

    DocumentSnapshot userDoc = await userDocRef.get();
    DocumentSnapshot discountedDoc = await discountedDocRef.get();

    List<dynamic> products = userDoc['products'];
    List<dynamic> discountedProducts =
        discountedDoc.exists && discountedDoc.data() != null
            ? (discountedDoc.data()
                    as Map<String, dynamic>)['discounted_products'] ??
                []
            : [];

    Map<String, double> macronutrients = {};
    double totalExpense = 0;
    List<Map<String, dynamic>> productsToSave = mealProducts.map((mealProduct) {
      mealProduct.macronutrients.forEach((key, value) {
        macronutrients[key] = (macronutrients[key] ?? 0) +
            value * (mealProduct.selectedQuantity * 10);
      });

      // Cerca se il prodotto è scontato
      final discountedProduct = discountedProducts.firstWhere(
        (dp) => dp['productId'] == mealProduct.productId,
        orElse: () => null,
      );

      // Usa il prezzo scontato se disponibile
      final price = discountedProduct != null
          ? discountedProduct['discountedPrice']
          : mealProduct.price;

      double pricePerKg = price / mealProduct.totalWeight;
      double productExpense = pricePerKg * mealProduct.selectedQuantity;
      totalExpense += productExpense;

      // Aggiorna le quantità solo nel documento appropriato
      if (discountedProduct != null) {
        // Se il prodotto è scontato, aggiorna solo nella collezione discounted_products
        int index = discountedProducts.indexWhere(
            (product) => product['productId'] == mealProduct.productId);
        if (index != -1) {
          _updateProductQuantities(discountedProducts[index], mealProduct);
        }
      } else {
        // Se il prodotto non è scontato, aggiorna solo nella collezione products
        int index = products.indexWhere(
            (product) => product['productId'] == mealProduct.productId);
        if (index != -1) {
          _updateProductQuantities(products[index], mealProduct);
        }
      }

      return {
        'idProdotto': mealProduct.productId,
        'productName': mealProduct.productName,
        'price': productExpense.toStringAsFixed(3),
        'category': mealProduct.category,
        'quantitySelected': mealProduct.selectedQuantity,
        'isDiscounted': discountedProduct != null,
        'originalPrice': mealProduct.price,
        'discountedPrice': discountedProduct?['discountedPrice'],
      };
    }).toList();

    // Aggiorna solo i documenti che sono stati modificati
    bool hasNormalProducts = mealProducts.any(
        (p) => !discountedProducts.any((dp) => dp['productId'] == p.productId));
    bool hasDiscountedProducts = mealProducts.any(
        (p) => discountedProducts.any((dp) => dp['productId'] == p.productId));

    if (hasNormalProducts) {
      await userDocRef.update({
        "products": products,
      });
      // Aggiorna anche il provider
      final productsLocalProvider =
          ref.read(productsProvider.notifier).fetchProducts();
    }

    if (hasDiscountedProducts) {
      discountedProducts
          .removeWhere((p) => p['discountedQuantityWeightOwned'] == 0);

      await discountedDocRef.set({
        "discounted_products": discountedProducts,
      });

      // Aggiorna anche il provider
      ref.read(discountedProductsProvider.notifier).fetchDiscountedProducts();
    }

    // Salva il pasto
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
    // } catch (e) {
    //   print(e);
    //   ToastNotifier.showError('Errore durante il salvataggio del pasto: $e');
    // }
  }

  void _updateProductQuantities(dynamic product, Product mealProduct) {
    String globalQuantityUnitOwned = 'quantityUnitOwned';
    String globalQuantityOwned = 'quantityOwned';
    String globalQuantityWeightOwned = 'quantityWeightOwned';
    if (product.containsKey('quantityUnitOwned')) {
      globalQuantityUnitOwned = 'quantityUnitOwned';
      globalQuantityOwned = 'quantityOwned';
      globalQuantityWeightOwned = 'quantityWeightOwned';
    } else if (product.containsKey('discountedQuantityUnitOwned')) {
      globalQuantityUnitOwned = 'discountedQuantityUnitOwned';
      globalQuantityOwned = 'discountedQuantityOwned';
      globalQuantityWeightOwned = 'discountedQuantityWeightOwned';
    }

    //TODO: non va il salvataggio con i prodotti scontati
    switch (mealProduct.quantityUpdateType) {
      case QuantityUpdateType.slider:
        product[globalQuantityUnitOwned] -=
            (mealProduct.selectedQuantity / mealProduct.unitWeight).round();
        product[globalQuantityWeightOwned] -= mealProduct.selectedQuantity;
        if (product[globalQuantityUnitOwned] <= 0) {
          product[globalQuantityOwned] -= 1;
          product[globalQuantityUnitOwned] = mealProduct.quantity;
        }
        break;

      case QuantityUpdateType.weight:
        if (product[globalQuantityWeightOwned] >= mealProduct.unitWeight) {
          if (mealProduct.selectedQuantity <=
              mealProduct.unitWeight * mealProduct.quantityUnitOwned) {
            product[globalQuantityUnitOwned] -=
                (mealProduct.selectedQuantity / mealProduct.unitWeight).ceil();
            if (product[globalQuantityUnitOwned] <= 0) {
              product[globalQuantityOwned] -= 1;
              product[globalQuantityUnitOwned] = mealProduct.quantity;
            }
          } else {
            product[globalQuantityOwned] -= 1;
            if ((product[globalQuantityWeightOwned] -
                        mealProduct.selectedQuantity) %
                    mealProduct.totalWeight ==
                0) {
              product[globalQuantityUnitOwned] = mealProduct.quantity;
            } else {
              product[globalQuantityUnitOwned] = mealProduct.quantity -
                  ((mealProduct.selectedQuantity / mealProduct.unitWeight)
                          .ceil() -
                      mealProduct.quantityUnitOwned);
            }
          }
        }
        product[globalQuantityWeightOwned] -=
            double.parse((mealProduct.selectedQuantity).toStringAsFixed(3));
        if (product[globalQuantityWeightOwned] <= 0) {
          product[globalQuantityOwned] = 0;
          product[globalQuantityUnitOwned] = 0;
          product[globalQuantityWeightOwned] = 0;
        }
        break;

      case QuantityUpdateType.units:
        product[globalQuantityOwned] -=
            mealProduct.selectedQuantity ~/ mealProduct.totalWeight;
        product[globalQuantityWeightOwned] -= mealProduct.selectedQuantity;
        if (product[globalQuantityOwned] <= 0 &&
            product[globalQuantityWeightOwned] <= mealProduct.unitWeight) {
          product[globalQuantityOwned] = 0;
          product[globalQuantityUnitOwned] = 0;
        }
        break;

      default:
        ToastNotifier.showError('Tipo di aggiornamento non supportato');
    }

    if (product[globalQuantityOwned] <= 0) {
      product[globalQuantityUnitOwned] = 0;
    }
    product[globalQuantityWeightOwned] = double.parse(
                    (product[globalQuantityWeightOwned]).toStringAsFixed(3))
                .toString()
                .endsWith('9') ||
            double.parse(
                    (product[globalQuantityWeightOwned]).toStringAsFixed(3))
                .toString()
                .endsWith('1')
        ? double.parse((product[globalQuantityWeightOwned]).toStringAsFixed(2))
        : double.parse((product[globalQuantityWeightOwned]).toStringAsFixed(3));
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
              titleSpacing: 0,
              centerTitle: true,
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
                    style: Platform.isIOS
                        ? CupertinoTheme.of(context).textTheme.textStyle
                        : Theme.of(context).textTheme.bodyLarge,
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
                    style: Platform.isIOS
                        ? CupertinoTheme.of(context).textTheme.textStyle
                        : Theme.of(context).textTheme.bodyLarge,
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
