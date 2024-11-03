import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/models/product_store_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tracker/models/product.dart';
import 'package:tracker/routes/add_product_screen.dart';
import '../services/category_services.dart';

class StorageScreen extends ConsumerStatefulWidget {
  final String name;

  const StorageScreen({super.key, required this.name});

  @override
  _StorageScreenState createState() => _StorageScreenState();
}

class _StorageScreenState extends ConsumerState<StorageScreen> {
  double totalBalance = 0.0;
  List<ProductStoreCard> storedProducts = [];
  List<ProductStoreCard> originalProducts = [];
  DateTime selectedDate = DateTime.now();
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _fetchProducts(FirebaseAuth.instance.currentUser!.uid, ref);
  }

  Future<void> _fetchProducts(String userId, WidgetRef ref) async {
    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('products').doc(userId);

    userDocRef.snapshots().listen((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        final List<dynamic> productsArray = snapshot['products'] ?? [];
        final List<ProductStoreCard> productWidgets = [];

        if (productsArray.isNotEmpty &&
            productsArray[0]['productName'] != null) {
          for (var product in productsArray) {
            if (product['store'] == widget.name.toLowerCase()) {
              productWidgets.add(
                ProductStoreCard(product: Product.fromJson(product)),
              );
            }
          }
        }

        setState(() {
          storedProducts = productWidgets;
          originalProducts = productWidgets;
        });
      } else {
        print('Nessun documento trovato per l\'utente.');
      }
    }, onError: (error) {
      print('Errore nel recupero dei prodotti: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(widget.name)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _showFilterDialog,
                      icon: Icon(Icons.filter_list,
                          color: Theme.of(context).iconTheme.color),
                    ),
                    IconButton(
                      onPressed: _showSearchDialog,
                      icon: Icon(Icons.search,
                          color: Theme.of(context).iconTheme.color),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          storedProducts = originalProducts;
                        });
                      },
                      icon: Icon(Icons.refresh,
                          color: Theme.of(context).iconTheme.color),
                    ),
                  ],
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddProductScreen()),
                  );
                },
                child: const Text('Aggiungi Prodotto'),
              ),
            ],
          ),
          Expanded(
            child: storedProducts.isNotEmpty
                ? GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemCount: storedProducts.length,
                    itemBuilder: (context, index) {
                      return storedProducts[index];
                    },
                  )
                : const Center(
                    child: Text(
                      'Non ci sono prodotti salvati disponibili',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
          )
        ],
      ),
    );
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
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              String selectedCategory = '';
              List<String> categoryNames = snapshot.data ?? [];
              return AlertDialog(
                title: const Text('Filter by Category'),
                content: DropdownButtonFormField<String>(
                  value: selectedCategory.isEmpty ? null : selectedCategory,
                  items: categoryNames.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCategory = newValue!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Select Category',
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text('Filter'),
                    onPressed: () {
                      setState(() {
                        storedProducts = originalProducts
                            .where((product) =>
                                product.product.category == selectedCategory)
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
          title: const Text('Search by Product Name'),
          content: TextField(
            onChanged: (value) {
              searchQuery = value;
            },
            decoration: const InputDecoration(
              labelText: 'Enter product name',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Search'),
              onPressed: () {
                setState(() {
                  storedProducts = originalProducts
                      .where((product) => product.product.productName
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
