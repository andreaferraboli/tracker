import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/routes/home_screen.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tracker/models/product.dart';
import 'package:tracker/models/product_list_item.dart';
import 'package:tracker/routes/add_product_screen.dart';

import '../providers/supermarket_provider.dart';
import '../services/category_services.dart';

var uuid = Uuid();

class SupermarketScreen extends ConsumerStatefulWidget {
  const SupermarketScreen({super.key});

  @override
  _SupermarketScreenState createState() => _SupermarketScreenState();
}

class _SupermarketScreenState extends ConsumerState<SupermarketScreen>{
  double totalBalance = 0.0; // Potresti calcolare il saldo basato sui prodotti
  List<ProductListItem> purchasedProducts = [];
  List<ProductListItem> originalProducts = [];
  bool isConnected = false;

  void _updateTotalBalance(double price, bool isAdding) {
    setState(() {
      if (isAdding) {
        totalBalance += price;
      } else {
        totalBalance -= price;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // deleteAllProducts();
    // _checkConnection();
    // uploadProductsFromJsonToFirestore(FirebaseAuth.instance.currentUser!.uid, 'assets/json/esselunga_output.json');
    // uploadProductsFromJsonToFirestore(FirebaseAuth.instance.currentUser!.uid, 'assets/json/output.json');
    _fetchProducts(FirebaseAuth.instance.currentUser!.uid, ref); // Recupera i prodotti dal database
  }

  Future<void> uploadProductsFromJsonToFirestore(
      String userId, String jsonFilePath) async {
    // Leggi il file JSON
    String jsonString =
        await DefaultAssetBundle.of(context).loadString(jsonFilePath);
    List<dynamic> products = json.decode(jsonString);

    // Riferimento al documento dell'utente basato sul suo id
    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('products').doc(userId);

    try {
      // Aggiorna il documento esistente aggiungendo i prodotti all'array "products"
      await userDocRef.update({"products": FieldValue.arrayUnion(products)});
      print('Prodotti aggiunti con successo!');
    } catch (e) {
      print('Errore durante l\'aggiunta dei prodotti: $e');
    }
  }

//funzione per cancellare tutti i documenti in products
  Future<void> deleteAllProducts() async {
    DocumentReference userDocRef = FirebaseFirestore.instance
        .collection('products')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    try {
      await userDocRef.update({"products": FieldValue.delete()});
      print('Prodotti eliminati con successo!');
    } catch (e) {
      print('Errore durante l\'eliminazione dei prodotti: $e');
    }
    try {
      userDocRef = FirebaseFirestore.instance
          .collection('products')
          .doc(FirebaseAuth.instance.currentUser!.uid);
      userDocRef.set({
        "products": [],
      });
    } catch (e) {
      print('Errore durante l\'impostazione dei prodotti: $e');
    }
  }

  void _checkConnection() {
    // Firestore non ha un metodo per controllare la connessione come Realtime Database.
    print('Firestore non fornisce un controllo diretto della connessione.');
    setState(() {
      isConnected = true; // Assumiamo di essere sempre connessi a Firestore.
    });
  }

  Future<void> _fetchProducts(String userId, WidgetRef ref) async {
    // Riferimento al documento dell'utente basato sul suo id
    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('products').doc(userId);

    userDocRef.snapshots().listen((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        // Recupera l'array "products" dal documento
        final List<dynamic> productsArray = snapshot['products'] ?? [];
        final List<ProductListItem> productWidgets = [];

        // Itera sui prodotti per creare un widget ProductList per ciascuno
        if (productsArray.isNotEmpty &&
            productsArray[0]['productName'] != null) {
          for (var product in productsArray) {
            if (product['supermarket'] == ref.read(supermarketProvider)) {
              productWidgets.add(
                ProductListItem(
                    product: Product.fromJson(product),
                    onTotalPriceChange: _updateTotalBalance),
              );
            }
          }
        }

        // Aggiorna lo stato del widget per mostrare la lista dei prodotti
        setState(() {
          purchasedProducts = productWidgets;
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
        title: Center(
              child: Text(ref.watch(supermarketProvider))
            ),
        ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Saldo Totale: €${totalBalance.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 24),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
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
                    //bottone reset filtri e ricerca
                    IconButton(
                      onPressed: () {
                        setState(() {
                          purchasedProducts = originalProducts;
                        });
                      },
                      icon: Icon(Icons.refresh,
                          color: Theme.of(context).iconTheme.color),
                    ),
                  ],
                ),
              ],
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
                        builder: (context) => AddProductScreen()),
                  );
                },
                child: const Text('Aggiungi Prodotto'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 33, 78,
                      52), // Imposta il colore di sfondo del bottone
                ),
                onPressed: () async {
                  try {
                    DocumentReference userDocRef = FirebaseFirestore.instance
                        .collection('expenses')
                        .doc(FirebaseAuth.instance.currentUser!.uid);

                    List<Map<String, dynamic>> productsToSave =
                        purchasedProducts
                            .where((product) => product.product.buyQuantity > 0)
                            .map((product) {
                      return {
                        'idProdotto': product.product.productId,
                        'productName': product.product.productName,
                        'pricePerKg': (product.product.price /
                                product.product.totalWeight)
                            .toStringAsFixed(3),
                        'category': product.product.category,
                        'quantita': product.product.buyQuantity,
                      };
                    }).toList();

                    // Passo 1: Scarica l'array di prodotti
                    DocumentReference productDocRef = FirebaseFirestore.instance
                        .collection('products')
                        .doc(FirebaseAuth.instance.currentUser!.uid);

                    // Recupera il documento
                    DocumentSnapshot snapshot = await productDocRef.get();

                    if (snapshot.exists) {
                      // Recupera l'array "products" dal documento
                      final List<dynamic> productsList =
                          snapshot['products'] ?? [];

                      // Passo 2: Modifica l'array localmente
                      for (var product in purchasedProducts) {
                        if (product.product.buyQuantity > 0) {
                          // Trova il prodotto corrispondente nell'array locale
                          var existingProduct = productsList.firstWhere(
                              (p) =>
                                  p['productId'] == product.product.productId,
                              orElse: () => null);

                          // Se esiste, aggiorna la quantità
                          if (existingProduct != null) {
                            existingProduct['quantityOwned'] +=
                                product.product.buyQuantity;
                          } else {
                            // Se non esiste, aggiungi il nuovo prodotto
                            productsList.add(product.product.toJson());
                          }

                          // Reset della buyQuantity
                          product.product.buyQuantity = 0;
                        }
                      }

// Passo 3: Carica l'array modificato in Firestore
                      await productDocRef.update({
                        'products': productsList,
                      });
                    }

                    await userDocRef.update({
                      'expenses': FieldValue.arrayUnion([
                        {
                          'id': uuid.v4(),
                          'supermarket': ref.read(supermarketProvider),
                          'totalAmount': totalBalance,
                          'products': productsToSave,
                          'date':
                              DateFormat('dd-MM-yyyy').format(DateTime.now()),
                        }
                      ])
                    });

                    print('Spesa salvata con successo!');
                    Navigator.pop(context);
                  } catch (e) {
                    print('Errore durante il salvataggio della spesa: $e');
                  }
                },
                child: const Text('Salva Spesa'),
              ),
            ],
          ),
          Expanded(
            child: purchasedProducts.isNotEmpty
                ? ListView.builder(
                    itemCount: purchasedProducts.length,
                    itemBuilder: (context, index) {
                      return purchasedProducts[
                          index]; // Corretto il ritorno del widget
                    },
                  )
                : Center(
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
              return Center(child: CircularProgressIndicator());
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
                      // Implement the filter logic here
                      setState(() {
                        purchasedProducts = originalProducts
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
                // Implement the search logic here
                setState(() {
                  purchasedProducts = originalProducts
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
