import 'dart:io'; // Aggiunto per rilevare la piattaforma
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import per multilingua
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/l10n/app_localizations.dart';
import 'package:tracker/models/product.dart';
import 'package:tracker/models/product_store_card.dart';
import 'package:tracker/routes/add_product_screen.dart';
import 'package:tracker/services/toast_notifier.dart';
import 'package:flutter/cupertino.dart'; // Aggiunto per i widget Cupertino

import '../services/category_services.dart';

class StorageScreen extends ConsumerStatefulWidget {
  final String name;

  const StorageScreen({super.key, required this.name});

  @override
  StorageScreenState createState() => StorageScreenState();
}

class StorageScreenState extends ConsumerState<StorageScreen> {
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
    DocumentReference discountedDocRef = FirebaseFirestore.instance
        .collection('discounted_products')
        .doc(userId);

    userDocRef.snapshots().listen((DocumentSnapshot snapshot) async {
      if (snapshot.exists) {
        final List<dynamic> productsArray = snapshot['products'] ?? [];
        final List<ProductStoreCard> productWidgets = [];

        // Get discounted products
        DocumentSnapshot discountedSnapshot = await discountedDocRef.get();
        final List<dynamic> discountedProducts =
            discountedSnapshot.exists && discountedSnapshot.data() != null
                ? (discountedSnapshot.data()
                        as Map<String, dynamic>)['discounted_products'] ??
                    []
                : [];

        if (productsArray.isNotEmpty &&
            productsArray[0]['productName'] != null) {
          for (var product in productsArray) {
            if (product['store'] == widget.name.toLowerCase()) {
              // Check if there's a discounted version of this product
              final discountedProduct = discountedProducts.firstWhere(
                (dp) => dp['productId'] == product['productId'],
                orElse: () => null,
              );

              // Add product if either regular or discounted version has weight > 0
              if (product['quantityWeightOwned'] > 0 ||
                  (discountedProduct != null &&
                      discountedProduct['discountedQuantityWeightOwned'] > 0)) {
                productWidgets.add(
                  ProductStoreCard(product: Product.fromJson(product)),
                );
              }
            }
          }
        }
        productWidgets.sort((a, b) => a.product
            .daysUntilExpiration()
            .compareTo(b.product.daysUntilExpiration()));
        setState(() {
          storedProducts = productWidgets;
          originalProducts = productWidgets;
        });
      } else {
        ToastNotifier.showError('Nessun documento trovato per l\'utente.');
      }
    }, onError: (error) {
      ToastNotifier.showError('Errore nel recupero dei prodotti: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS && false
        ? CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: Text(
                  AppLocalizations.of(context)!.getStorageTitle(widget.name)),
            ),
            child: _buildBody(),
          )
        : Scaffold(
            appBar: AppBar(
              titleSpacing: 0,
              centerTitle: true,
              title: Text(
                  AppLocalizations.of(context)!.getStorageTitle(widget.name)),
            ),
            body: _buildBody(),
          );
  }

  Widget _buildBody() {
    return Column(
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
                  Platform.isIOS && false
                      ? CupertinoButton(
                          onPressed: _showFilterDialog,
                          child: Icon(
                            CupertinoIcons.slider_horizontal_3,
                            color: CupertinoTheme.of(context).primaryColor,
                          ),
                        )
                      : IconButton(
                          onPressed: _showFilterDialog,
                          icon: Icon(Icons.filter_list,
                              color: Theme.of(context).iconTheme.color),
                        ),
                  Platform.isIOS && false
                      ? CupertinoButton(
                          onPressed: _showSearchDialog,
                          child: Icon(
                            CupertinoIcons.search,
                            color: CupertinoTheme.of(context).primaryColor,
                          ),
                        )
                      : IconButton(
                          onPressed: _showSearchDialog,
                          icon: Icon(Icons.search,
                              color: Theme.of(context).iconTheme.color),
                        ),
                  Platform.isIOS && false
                      ? CupertinoButton(
                          onPressed: () {
                            setState(() {
                              storedProducts = originalProducts;
                            });
                          },
                          child: Icon(
                            CupertinoIcons.refresh,
                            color: CupertinoTheme.of(context).primaryColor,
                          ),
                        )
                      : IconButton(
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
            Platform.isIOS && false
                ? CupertinoButton.filled(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AddProductScreen()),
                      );
                    },
                    child: Text(AppLocalizations.of(context)!.addProduct),
                  )
                : ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AddProductScreen()),
                      );
                    },
                    child: Text(AppLocalizations.of(context)!.addProduct),
                  ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: storedProducts.isNotEmpty
              ? GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: storedProducts.length,
                  itemBuilder: (context, index) {
                    return storedProducts[index];
                  },
                )
              : Center(
                  child: Text(
                    AppLocalizations.of(context)!.noSavedProducts,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
        )
      ],
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
