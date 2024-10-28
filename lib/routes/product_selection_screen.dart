import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tracker/routes/supermarket_screen.dart';
import 'package:tracker/services/category_services.dart';

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
  List<Product> originalProducts = []; // Per mantenere la lista originale dei prodotti

  @override
  void initState() {
    super.initState();
    selectedCategories = List<String>.from(defaultCategories[widget.mealType.name]!);
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
          originalProducts = List.from(loadedProducts); // Backup della lista originale
          filteredProducts = loadedProducts.where((product) => selectedCategories.contains(product.category)).toList(); // Lista filtrata; // Lista filtrata
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

      List<Map<String, dynamic>> productsToSave = mealProducts.map((product) {
        return {
          'idProdotto': product.productId,
          'productName': product.productName,
          'price': product.price,
          'category': product.category,
          'quantityOwned': product.quantityOwned,
        };
      }).toList();

      await userDocRef.update({
        'meals': FieldValue.arrayUnion([
          {
            'id': DateTime.now().toIso8601String(),
            'mealType': widget.mealType.name,
            'products': productsToSave,
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
    } catch (e) {
      print('Errore durante il salvataggio del pasto: $e');
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {

        return FutureBuilder<List<String>>(
          future: CategoryServices.getCategoryNames(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Errore: ${snapshot.error}'));
            } else {
              List<String> categoryNames = snapshot.data ?? [];
              return AlertDialog(
                title: const Text('Filtra per categoria'),
                content: DropdownButtonFormField<String>(
                  value: selectedCategories.isEmpty ? null : selectedCategories[0],
                  items: categoryNames.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCategories = [newValue!];
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Seleziona Categoria',
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
                    child: const Text('Filtra'),
                    onPressed: () {
                      setState(() {
                        filteredProducts = originalProducts
                            .where((product) =>
                        selectedCategories.contains(product.category))
                            .toList();
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            }
          },
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
      filteredProducts = originalProducts.where((product) => selectedCategories.contains(product.category)).toList();
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
          CategorySelectionRow(mealType: widget.mealType,categories:selectedCategories, onCategoriesUpdated: updateCategories),
          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return ProductCard(product: product);
              },
            ),
          ),
        ],
      ),
    );
  }


}
