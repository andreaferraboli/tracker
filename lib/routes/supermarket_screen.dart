import 'dart:collection';
import 'dart:convert';
import 'dart:math';

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
import 'package:tracker/providers/meals_provider.dart';
import 'package:tracker/routes/add_product_screen.dart';
import 'package:tracker/services/toast_notifier.dart';
import 'package:uuid/uuid.dart';

import '../models/meal.dart';
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
    if (!mounted) return;
    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('meals').doc(userId);

    try {
      DocumentSnapshot snapshot = await userDocRef.get();
      if (!mounted) return;

      if (snapshot.exists) {
        final List<dynamic> mealsArray = snapshot['meals'] ?? [];
        String jsonString = json.encode(mealsArray);
        debugPrint(jsonString);
        ToastNotifier.showError('Dati salvati con successo in $jsonFilePath');
      } else {
        ToastNotifier.showError('Nessun documento trovato per l\'utente.');
      }
    } catch (e) {
      if (!mounted) return;
      ToastNotifier.showError('Errore durante il salvataggio dei dati: $e');
    }
  }

  Future<void> uploadProductsFromJsonToFirestore(
      String userId, String jsonFilePath) async {
    if (!mounted) return;
    String jsonString =
        await DefaultAssetBundle.of(context).loadString(jsonFilePath);
    if (!mounted) return;

    List<dynamic> products = json.decode(jsonString);
    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('products').doc(userId);

    try {
      await userDocRef.update({"products": FieldValue.arrayUnion(products)});
      if (!mounted) return;
      ToastNotifier.showError('Prodotti aggiunti con successo!');
    } catch (e) {
      if (!mounted) return;
      ToastNotifier.showError('Errore durante l\'aggiunta dei prodotti: $e');
    }
  }

//funzione per cancellare tutti i documenti in products
  Future<void> deleteAllProducts() async {
    if (!mounted) return;
    DocumentReference userDocRef = FirebaseFirestore.instance
        .collection('products')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    try {
      await userDocRef.update({"products": FieldValue.delete()});
      if (!mounted) return;
      ToastNotifier.showError('Prodotti eliminati con successo!');
    } catch (e) {
      if (!mounted) return;
      ToastNotifier.showError(
          'Errore durante l\'eliminazione dei prodotti: $e');
    }
    try {
      userDocRef = FirebaseFirestore.instance
          .collection('products')
          .doc(FirebaseAuth.instance.currentUser!.uid);
      await userDocRef.set({
        "products": [],
      });
      if (!mounted) return;
    } catch (e) {
      if (!mounted) return;
      ToastNotifier.showError(
          'Errore durante l\'impostazione dei prodotti: $e');
    }
  }

  Future<void> saveExpense() async {
    if (!mounted) return;
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
      if (!mounted) return;

      if (snapshot.exists) {
        final List<dynamic> productsList = snapshot['products'] ?? [];

        for (var product in selectedProducts) {
          if (product.product.buyQuantity > 0) {
            var existingProduct = productsList.firstWhere(
                (p) => p['productId'] == product.product.productId,
                orElse: () => null);

            if (existingProduct != null) {
              existingProduct['quantityOwned'] += product.product.buyQuantity;
              existingProduct['quantityUnitOwned'] += product.product.quantity;
              existingProduct['quantityWeightOwned'] +=
                  product.product.buyQuantity * product.product.totalWeight;
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

      if (!mounted) return;
      ToastNotifier.showSuccess(
          context, AppLocalizations.of(context)!.expenseSaved);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ToastNotifier.showError('Errore durante il salvataggio della spesa: $e');
    }
  }

  Future<void> _fetchProducts(String userId, WidgetRef ref) async {
    if (!mounted) return;
    // Riferimento al documento dell'utente basato sul suo id
    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('products').doc(userId);

    userDocRef.snapshots().listen((DocumentSnapshot snapshot) {
      if (!mounted) return;
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
        ToastNotifier.showError('Nessun documento trovato per l\'utente.');
      }
    }, onError: (error) {
      ToastNotifier.showError('Errore nel recupero dei prodotti: $error');
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
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return FutureBuilder<List<String>>(
          future: CategoryServices.getCategoryNames(),
          builder: (dialogContext, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                  child: Text(
                      '${AppLocalizations.of(dialogContext)!.error}: ${snapshot.error}'));
            } else {
              String selectedCategory = '';
              List<String> categoryNames = snapshot.data ?? [];
              return AlertDialog(
                title:
                    Text(AppLocalizations.of(dialogContext)!.filterByCategory),
                content: DropdownButtonFormField<String>(
                  value: selectedCategory.isEmpty ? null : selectedCategory,
                  items: categoryNames.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(AppLocalizations.of(dialogContext)!
                          .translateCategory(category)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (!mounted) return;
                    setState(() {
                      selectedCategory = newValue!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(dialogContext)!.selectCategory,
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text(AppLocalizations.of(dialogContext)!.cancel),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                  ),
                  TextButton(
                    child: Text(AppLocalizations.of(dialogContext)!.filter),
                    onPressed: () {
                      if (!mounted) return;
                      setState(() {
                        purchasedProducts = originalProducts
                            .where((product) =>
                                product.product.category == selectedCategory)
                            .toList();
                      });
                      Navigator.of(dialogContext).pop();
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
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        String searchQuery = '';
        return AlertDialog(
          title: Text(AppLocalizations.of(dialogContext)!.searchByProductName),
          content: TextField(
            onChanged: (value) {
              searchQuery = value;
            },
            decoration: InputDecoration(
              labelText: AppLocalizations.of(dialogContext)!.enterProductName,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(dialogContext)!.cancel),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(dialogContext)!.search),
              onPressed: () {
                if (!mounted) return;
                setState(() {
                  purchasedProducts = originalProducts
                      .where((product) => product.product.productName
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase()))
                      .toList();
                });
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAiDialog() {
    return showDialog(
      context: context,
      builder: (dialogContext) {
        double budget = 0.0;
        return AlertDialog(
          title: Text(AppLocalizations.of(dialogContext)!.enterBudget),
          content: TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              budget = double.tryParse(value) ?? 0.0;
            },
            decoration: InputDecoration(
              labelText: AppLocalizations.of(dialogContext)!.enterAmount,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(dialogContext)!.cancel),
              onPressed: () {
                if (dialogContext != null) {
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(dialogContext)!.suggest),
              onPressed: () async {
                List<ProductListItem> suggestedProducts =
                    await suggestProductsWithinBudget(budget);
                if (!mounted || dialogContext == null) return;
                setState(() {
                  selectedProducts = suggestedProducts;
                  purchasedProducts = purchasedProducts
                      .where(
                        (product) => !suggestedProducts.any((suggested) =>
                            suggested.product.productId ==
                            product.product.productId),
                      )
                      .toList();
                });
                if (mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<List<ProductListItem>> suggestProductsWithinBudget(
      double budget) async {
    List<ProductListItem> suggestedProducts = [];
    double currentSum = 0.0;
    List<Meal> meals = ref.read(mealsProvider);

    try {
      // Mappa per aggregare i consumi dei prodotti (productId -> quantità totale consumata)
      Map<String, double> productConsumption = {};

      // Se non ci sono pasti, seleziona randomicamente dai prodotti originali
      if (meals.isEmpty) {
        while (currentSum < budget) {
          var randomProduct = (originalProducts.toList()..shuffle()).first;
          double cost = randomProduct.product.price;

          if (currentSum + cost <= budget) {
            randomProduct.updateQuantity(1);
            randomProduct.product.buyQuantity = 1;
            randomProduct.setSelected(true);
            suggestedProducts.add(randomProduct);
            currentSum += cost;
            _updateTotalBalance(cost);
          } else {
            break;
          }
        }
        return suggestedProducts;
      }

      // Trova il range temporale (numero di settimane di dati)
      DateTime firstDate = meals
          .map((meal) => DateTime.parse(meal.date))
          .reduce((a, b) => a.isBefore(b) ? a : b);
      DateTime lastDate = meals
          .map((meal) => DateTime.parse(meal.date))
          .reduce((a, b) => a.isAfter(b) ? a : b);
      int totalWeeks = ((lastDate.difference(firstDate).inDays) / 7).ceil();

      // Calcola i consumi aggregati
      for (var meal in meals) {
        for (var product in meal.products) {
          final productId = product['idProdotto'] as String;
          final quantity = product['quantitySelected'] as double;
          productConsumption.update(
            productId,
            (value) => value + quantity,
            ifAbsent: () => quantity,
          );
        }
      }

      // Calcola la media settimanale per ciascun prodotto
      Map<String, double> weeklyAverageConsumption = productConsumption.map(
        (key, value) => MapEntry(key, value / totalWeeks),
      );

      // Calcola il punteggio di necessità per ciascun prodotto
      const double epsilon = 0.1; // Fattore di scalatura
      final HashMap<String, double> categoryZValues =
          HashMap<String, double>.from({
        "meat": 1.9, // La carne scade molto rapidamente.
        "fish": 2, // Il pesce scade anche più velocemente della carne.
        "pasta_bread_rice": 1.1, // Alimenti secchi, molto stabili.
        "sauces_condiments": 1.4, // Salse e condimenti hanno una durata media.
        "vegetables": 1.6, // Le verdure fresche scadono relativamente presto.
        "fruit": 1.7, // La frutta, a seconda del tipo, scade velocemente.
        "dairy_products": 1.8, // I latticini hanno una durata breve.
        "water": 1.0, // L'acqua non scade praticamente mai.
        "dessert": 1.1, // I dolci confezionati hanno una durata moderata.
        "salty_snacks": 1.2, // Snack salati, stabili per lungo tempo.
        "drinks": 1.3, // Bevande confezionate hanno una buona durata.
      });

      List<Map<String, dynamic>> necessityScores = [];

      for (var product in originalProducts) {
        final productId = product.product.productId;
        double alpha =
            categoryZValues[product.product.category] ?? 1.0; // Esponente
        double quantityOwned = product.product.quantityWeightOwned;
        double weeklyConsumption = weeklyAverageConsumption[productId] ?? 0.0;

        double necessityScore = 0.0;
        if (weeklyConsumption > 0) {
          necessityScore = pow(2.7172,
                  ((weeklyConsumption / (epsilon + quantityOwned)) - 1)) *
              alpha;
        }

        necessityScores.add({
          'product': product,
          'necessityScore': necessityScore,
        });
      }

      // Ordina i prodotti per necessityScore decrescente
      necessityScores
          .sort((a, b) => b['necessityScore'].compareTo(a['necessityScore']));

      // Seleziona i prodotti fino a raggiungere il budget
      for (var entry in necessityScores) {
        var product = entry['product'];
        double weeklyConsumption =
            weeklyAverageConsumption[product.product.productId] ?? 0.0;
        double quantityWeightOwned = product.product.quantityWeightOwned;

        int quantityToBuy =
            (weeklyConsumption - quantityWeightOwned).abs().ceil();
        double totalCost = product.product.price * quantityToBuy;

        if (currentSum + totalCost <= budget) {
          product.updateQuantity(quantityToBuy);
          product.product.buyQuantity = quantityToBuy;
          product.setSelected(true);
          if (quantityToBuy > 0) {
            suggestedProducts.add(product);
          }
          currentSum += totalCost;
          _updateTotalBalance(totalCost);
        }
      }

      // Se il budget non è stato raggiunto, aggiungi prodotti casuali dagli originalProducts
      if (currentSum < budget) {
        var remainingBudget = budget - currentSum;

        for (var product in (originalProducts.toList()..shuffle())) {
          double cost = product.product.price;

          if (currentSum + cost <= budget) {
            product.updateQuantity(1);
            product.product.buyQuantity = 1;
            product.setSelected(true);
            suggestedProducts.add(product);
            currentSum += cost;
            _updateTotalBalance(cost);
          }

          if (currentSum >= budget) {
            break;
          }
        }
      }
    } catch (e) {
      ToastNotifier.showError('Errore durante il recupero dei pasti: $e');
    }

    return suggestedProducts;
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
                      onPressed: () {
                        setState(() {
                          purchasedProducts = originalProducts;
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
                                style: const TextStyle(fontSize: 18),
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
