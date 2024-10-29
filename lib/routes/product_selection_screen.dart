import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tracker/models/product_added_to_meal.dart';

import '../models/category_selection_row.dart';
import '../models/meal_type.dart';
import '../models/product.dart';
import '../models/product_card.dart';

class ProductSelectionScreen extends StatefulWidget {
  final MealType mealType;

  const ProductSelectionScreen({
    Key? key,
    required this.mealType,
  }) : super(key: key);

  @override
  _ProductSelectionScreenState createState() => _ProductSelectionScreenState();
}

class _ProductSelectionScreenState extends State<ProductSelectionScreen> {
  final Map<String, List<String>> defaultCategories = {
    'Breakfast': ['Dolci', 'Latticini', 'Frutta', 'Bevande'],
    'Lunch': ['Pasta, Pane e Riso', 'Sughi e Condimenti', 'Frutta', 'Verdura'],
    'Snack': ['Dolci', 'Bevande', 'Snack Salati', 'Frutta'],
    'Dinner': ['Carne', 'Pesce', 'Frutta', 'Verdura'],
  };
  List<Product> mealProducts = [];
  List<String> selectedCategories = [];
  List<Product> filteredProducts = [];
  List<Product> originalProducts =
      []; // Per mantenere la lista originale dei prodotti

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
          if (product['quantityOwned'] > 0) {
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
        print('Nessun documento trovato per l\'utente.');
      }
    } catch (error) {
      print('Errore nel recupero dei prodotti: $error');
    }
  }

  void _saveMeal() async {
    try {
      DocumentReference userDocRef = FirebaseFirestore.instance
          .collection('meals')
          .doc(FirebaseAuth.instance.currentUser!.uid);
      Map<String, double> macronutrients = {};
      double totalExpense = 0;
      List<Map<String, dynamic>> productsToSave = mealProducts.map((product) {
        product.macronutrients.forEach((key, value) {
          macronutrients[key] = (macronutrients[key] ?? 0) +
              value * (product.selectedQuantity * 10);
        });
        double pricePerKg = product.price / product.totalWeight;
        double productExpense = pricePerKg * product.selectedQuantity;
        totalExpense += productExpense;
        return {
          'idProdotto': product.productId,
          'productName': product.productName,
          'price': productExpense.toStringAsFixed(3),
          'category': product.category,
          'quantitySelected': product.selectedQuantity,
        };
      }).toList();

      await userDocRef.update({
        'meals': FieldValue.arrayUnion([
          {
            'id': DateTime.now().toIso8601String(),
            'mealType': widget.mealType.name,
            'totalExpense': totalExpense.toStringAsFixed(3),
            'products': productsToSave,
            'macronutrients': macronutrients,
            'date': DateFormat('dd-MM-yyyy').format(DateTime.now()),
          }
        ])
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pasto salvato con successo!'),
          backgroundColor: Colors.green,
        ),
      );
      int count = 0;
      Navigator.of(context).popUntil((route) {
        return count++ == 2;
      });
    } catch (e) {
      print('Errore durante il salvataggio del pasto: $e');
    }
  }

  void _showFilterDialog() {
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

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String searchQuery = '';
        return AlertDialog(
          title: const Text('Ricerca per nome prodotto'),
          content: TextField(
            onChanged: (value) {
              searchQuery = value;
            },
            decoration: const InputDecoration(
              labelText: 'Inserisci nome prodotto',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annulla'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Cerca'),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleziona prodotti - ${widget.mealType.name}'),
        backgroundColor: widget.mealType.color,
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: _saveMeal,
                child: const Text('Salva Pasto'),
              ),
              IconButton(
                onPressed: _showFilterDialog,
                icon: const Icon(Icons.filter_list),
              ),
              IconButton(
                onPressed: _showSearchDialog,
                icon: const Icon(Icons.search),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    filteredProducts = originalProducts;
                  });
                },
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          // Spazio dedicato ai prodotti selezionati
          Flexible(
            flex: mealProducts.isEmpty ? 1 : 3, // 10% se vuoto, 30% se pieno
            child: mealProducts.isEmpty
                ? const Center(child: Text('Nessun prodotto selezionato'))
                : Column(
                    children: [
                      Text(
                        'Prodotti selezionati',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: mealProducts.length,
                          itemBuilder: (context, index) {
                            final product = mealProducts[index];
                            return ProductAddedToMeal(
                              product: product,
                              selectedQuantity: product
                                  .selectedQuantity, // Passa la quantità selezionata
                              onQuantityUpdated: (quantity) {
                                setState(() {
                                  mealProducts[index] = product.copyWith(
                                      selectedQuantity: quantity);
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),

          // Spazio dedicato ai prodotti filtrati
          Flexible(
            flex: mealProducts.isEmpty ? 9 : 7, // 90% se vuoto, 70% se pieno
            child: filteredProducts.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return ProductCard(
                        product: product,
                        addProductToMeal: (product, quantity) {
                          setState(() {
                            mealProducts.add(
                                product.copyWith(selectedQuantity: quantity));
                            originalProducts.remove(product);
                            filteredProducts.remove(product);
                          });
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
