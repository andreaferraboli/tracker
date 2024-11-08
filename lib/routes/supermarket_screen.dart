import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:tracker/l10n/app_localizations.dart';
import 'package:tracker/models/product.dart';
import 'package:tracker/models/product_list_item.dart';
import 'package:tracker/routes/add_product_screen.dart';
import 'package:uuid/uuid.dart';

import '../providers/supermarket_provider.dart';
import '../services/category_services.dart';

var uuid = const Uuid();

class SupermarketScreen extends ConsumerStatefulWidget {
  const SupermarketScreen({super.key});

  @override
  _SupermarketScreenState createState() => _SupermarketScreenState();
}

class _SupermarketScreenState extends ConsumerState<SupermarketScreen> {
  double totalBalance = 0.0; // Potresti calcolare il saldo basato sui prodotti
  List<ProductListItem> purchasedProducts = [];
  List<ProductListItem> originalProducts = [];
  List<ProductListItem> selectedProducts = [];
  DateTime selectedDate = DateTime.now();
  bool isConnected = false;

  void _updateTotalBalance(double price) {
    setState(() {
      totalBalance += price;
    });
  }

  @override
  void initState() {
    super.initState();
    // deleteAllProducts();
    // _checkConnection();
    // uploadProductsFromJsonToFirestore(FirebaseAuth.instance.currentUser!.uid, 'assets/json/esselunga_output.json');
    // uploadProductsFromJsonToFirestore(FirebaseAuth.instance.currentUser!.uid, 'assets/json/output.json');
    // saveMealsToJson(FirebaseAuth.instance.currentUser!.uid, 'assets/json/meals.json');
    _fetchProducts(FirebaseAuth.instance.currentUser!.uid,
        ref); // Recupera i prodotti dal database
  }

  Future<void> saveMealsToJson(String userId, String jsonFilePath) async {
    // Riferimento al documento dell'utente basato sul suo id
    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('meals').doc(userId);

    try {
      // Recupera il documento
      DocumentSnapshot snapshot = await userDocRef.get();

      if (snapshot.exists) {
        // Recupera l'array "meals" dal documento
        final List<dynamic> mealsArray = snapshot['meals'] ?? [];

        // Converti l'array in una stringa JSON
        String jsonString = json.encode(mealsArray);

        // Salva la stringa JSON nel file specificato
        debugPrint(jsonString);

        print('Dati salvati con successo in $jsonFilePath');
      } else {
        print('Nessun documento trovato per l\'utente.');
      }
    } catch (e) {
      print('Errore durante il salvataggio dei dati: $e');
    }
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

  Future<void> saveExpense() async {
    try {
      DocumentReference userDocRef = FirebaseFirestore.instance
          .collection('expenses')
          .doc(FirebaseAuth.instance.currentUser!.uid);

      List<Map<String, dynamic>> productsToSave =
          selectedProducts.map((product) {
        return {
          'idProdotto': product.product.productId,
          'productName': product.product.productName,
          'price': product.product.price,
          'pricePerKg': (product.product.price / product.product.totalWeight)
              .toStringAsFixed(3),
          'category': product.product.category,
          'quantita': product.product.buyQuantity,
        };
      }).toList();

      DocumentReference productDocRef = FirebaseFirestore.instance
          .collection('products')
          .doc(FirebaseAuth.instance.currentUser!.uid);

      DocumentSnapshot snapshot = await productDocRef.get();

      if (snapshot.exists) {
        final List<dynamic> productsList = snapshot['products'] ?? [];

        for (var product in selectedProducts) {
          if (product.product.buyQuantity > 0) {
            var existingProduct = productsList.firstWhere(
                (p) => p['productId'] == product.product.productId,
                orElse: () => null);

            if (existingProduct != null) {
              existingProduct['quantityOwned'] += product.product.buyQuantity;
            } else {
              productsList.add(product.product.toJson());
            }

            product.product.buyQuantity = 0;
          }
        }

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
            'date': DateFormat('dd-MM-yyyy').format(selectedDate),
          }
        ])
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.expenseSaved),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Errore durante il salvataggio della spesa: $e');
    }
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
                  onTotalPriceChange: _updateTotalBalance,
                  updateProductLists: _updateProductLists,
                ),
              );
            }
          }
        }

        // Aggiorna lo stato del widget per mostrare la lista dei prodotti
        setState(() {
          purchasedProducts = productWidgets;
          originalProducts = productWidgets;
          selectedProducts = [];
        });
      } else {
        print('Nessun documento trovato per l\'utente.');
      }
    }, onError: (error) {
      print('Errore nel recupero dei prodotti: $error');
    });
  }

  void _updateProductLists() {
    setState(() {
      selectedProducts = originalProducts.where((product) {
        bool isSelected = product.product.buyQuantity > 0;
        product.setSelected(isSelected);
        return isSelected;
      }).toList();
      purchasedProducts = originalProducts.where((product) {
        bool isSelected = product.product.buyQuantity == 0;
        product.setSelected(!isSelected);
        return isSelected;
      }).toList();
    });
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
              return Center(
                  child: Text(
                      '${AppLocalizations.of(context)!.error}: ${snapshot.error}'));
            } else {
              String selectedCategory = '';
              List<String> categoryNames = snapshot.data ?? [];
              return AlertDialog(
                title: Text(AppLocalizations.of(context)!.filterByCategory),
                content: DropdownButtonFormField<String>(
                  value: selectedCategory.isEmpty ? null : selectedCategory,
                  items: categoryNames.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(AppLocalizations.of(context)!
                          .translateCategory(category)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCategory = newValue!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.selectCategory,
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
                    child: Text(AppLocalizations.of(context)!.filter),
                    onPressed: () {
                      // Implementa la logica di filtro qui
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
          title: Text(AppLocalizations.of(context)!.searchByProductName),
          content: TextField(
            onChanged: (value) {
              searchQuery = value;
            },
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.enterProductName,
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
                // Implementa la logica di ricerca qui
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

  void _showAiDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        double budget = 0.0;
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.enterBudget),
          content: TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              budget = double.tryParse(value) ?? 0.0;
            },
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.enterAmount,
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
              child: Text(AppLocalizations.of(context)!.suggest),
              onPressed: () {
                List<ProductListItem> suggestedProducts = [];
                double currentSum = 0.0;

                for (var product in originalProducts) {
                  if (currentSum + product.product.price <= budget) {
                    product.setSelected(true);
                    suggestedProducts.add(product);
                    currentSum += product.product.price;
                  }
                }

                setState(() {
                  selectedProducts = suggestedProducts;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(ref.watch(supermarketProvider))),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                double fontSize = 18.0; // Dimensione font di base
                String totalText =
                    '${AppLocalizations.of(context)!.totalBalance}: €${totalBalance.toStringAsFixed(2)}';
                double textWidth = (totalText.length * fontSize) *
                    0.99; // Stima della larghezza del testo

                // Se il testo supera la larghezza disponibile, riduci la dimensione del font
                if (textWidth > constraints.maxWidth) {
                  fontSize = fontSize - 2; // Riduci in proporzione
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // Posiziona i pulsanti alla fine
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Utilizza il font size calcolato
                    Text(
                      totalText,
                      style: TextStyle(fontSize: fontSize),
                    ),
                    // Pulsante filtro
                    IconButton(
                      onPressed: _showFilterDialog,
                      icon: Icon(Icons.filter_list,
                          color: Theme.of(context).iconTheme.color),
                    ),
                    // Pulsante ricerca
                    IconButton(
                      onPressed: _showSearchDialog,
                      icon: Icon(Icons.search,
                          color: Theme.of(context).iconTheme.color),
                    ),
                    IconButton(
                      onPressed: _showAiDialog,
                      icon: Icon(HugeIcons.strokeRoundedAiBrain01,
                          color: Theme.of(context).iconTheme.color),
                    ),
                    // Pulsante reset filtri e ricerca
                    IconButton(
                      onPressed: _showAiDialog,
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
                child: Text(AppLocalizations.of(context)!.addProduct),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 33, 78, 52),
                ),
                onPressed: () async {
                  await saveExpense();
                },
                child: Text(AppLocalizations.of(context)!.saveExpense),
              ),
              IconButton(
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
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Sezione per i prodotti acquistati con quantità selezionata > 0
                  ExpansionTile(
                    title: Text(
                      AppLocalizations.of(context)!.selectedProducts,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    initiallyExpanded: selectedProducts.isNotEmpty,
                    leading: const Icon(Icons.shopping_cart),
                    children: selectedProducts.isEmpty
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
                              itemCount: selectedProducts.length,
                              itemBuilder: (context, index) {
                                final product = selectedProducts[index];
                                return product;
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
                    children: purchasedProducts.isEmpty
                        ? [
                            Center(
                              child: Text(
                                AppLocalizations.of(context)!.noSavedProducts,
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ]
                        : [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: purchasedProducts.length,
                              itemBuilder: (context, index) {
                                final product = purchasedProducts[index];
                                return product;
                              },
                            ),
                          ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
