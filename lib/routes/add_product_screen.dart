import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tracker/l10n/app_localizations.dart';
import 'package:tracker/models/discounted_product.dart';
import 'package:tracker/models/image_input.dart';
import 'package:tracker/models/macronutrients_table.dart';
import 'package:tracker/providers/discounted_products_provider.dart';

import '../models/product.dart';
import '../providers/stores_provider.dart';
import '../providers/supermarket_provider.dart';
import '../services/category_services.dart';
import '../services/icons_helper.dart';
import '../services/toast_notifier.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  final String? supermarketName;

  final Product? product;

  const AddProductScreen({super.key, this.supermarketName, this.product});

  @override
  AddProductScreenState createState() => AddProductScreenState();
}

class AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  // Aggiornamento della mappa _productData per includere i nuovi parametri
  final Map<String, dynamic> _productData = {
    'productId': '',
    'productName': '',
    'category': '',
    'totalPrice': 0.0,
    'price': 0.0,
    'quantity': 0,
    'buyQuantity': 0,
    'quantityOwned': 0,
    'store': '',
    'quantityUnitOwned': 0,
    'quantityWeightOwned': 0,
    'unit': '',
    'macronutrients': {},
    'expirationDate': '',
    'supermarket': '',
    'purchaseDate': '',
    'barcode': '',
    'imageUrl': '',
    'totalWeight': 0.0,
    'unitWeight': 0.0,
    'unitPrice': 0.0,
  };
  DiscountedProduct? discountedProduct;
  List<DiscountedProduct> discountedProducts = [];
  List<String> categories = [];
  var stores = [];
  String? selectedCategory;
  String? selectedStore;
  File? _selectedImage;
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _quantityOwnedController =
      TextEditingController();
  final TextEditingController _quantityUnitOwnedController =
      TextEditingController();
  final TextEditingController _quantityWeightOwnedController =
      TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _totalWeightController = TextEditingController();
  final TextEditingController _nameProductController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _discountedPriceController =
      TextEditingController();
  final TextEditingController _discountedQuantityOwnedController =
      TextEditingController();
  final TextEditingController _discountedQuantityUnitOwnedController =
      TextEditingController();
  final TextEditingController _discountedQuantityWeightOwnedController =
      TextEditingController();

  //aggiungi i controller per ogni campo di testo

  @override
  void initState() {
    super.initState();
    _loadCategories();
    discountedProducts = ref.read(discountedProductsProvider);
    stores = ref.read(storesProvider);
    if (widget.product != null) {
      _productData['barcode'] = widget.product!.barcode;
      _productData['category'] = widget.product!.category;
      _productData['expirationDate'] = widget.product!.expirationDate;
      _productData['macronutrients'] = widget.product!.macronutrients;
      _productData['price'] = widget.product!.price;
      _productData['totalPrice'] = widget.product!.totalPrice;
      _productData['unitPrice'] = widget.product!.unitPrice;
      _productData['productId'] = widget.product!.productId;
      _productData['store'] = widget.product!.store;
      _productData['productName'] = widget.product!.productName;
      _productData['purchaseDate'] = widget.product!.purchaseDate;
      _productData['quantity'] = widget.product!.quantity;
      _productData['supermarket'] = widget.product!.supermarket;
      _productData['unit'] = widget.product!.unit;
      _productData['imageUrl'] = widget.product!.imageUrl;
      _productData['totalWeight'] = widget.product!.totalWeight;
      _productData['unitWeight'] = widget.product!.unitWeight;
      _productData['buyQuantity'] = widget.product!.buyQuantity;
      _productData['quantityOwned'] = widget.product!.quantityOwned;
      _productData['quantityUnitOwned'] = widget.product!.quantityUnitOwned;
      _productData['quantityWeightOwned'] = widget.product!.quantityWeightOwned;
      selectedCategory = widget.product!.category;
      selectedStore = widget.product!.store;
      discountedProduct = discountedProducts.firstWhereOrNull(
          (element) => element.productId == widget.product!.productId);
    } else {
      _productData['supermarket'] =
          widget.supermarketName ?? ref.read(supermarketProvider);
      _productData['unit'] = 'kg';

      _productData['purchaseDate'] = DateTime.now().toString();
      _productData['productId'] = UniqueKey().toString();
    }
    _quantityController.text = _productData['quantity'].toString();
    _quantityOwnedController.text = _productData['quantityOwned'].toString();
    _quantityUnitOwnedController.text =
        _productData['quantityUnitOwned'].toString();
    _quantityWeightOwnedController.text =
        _productData['quantityWeightOwned'].toString();
    _imageUrlController.text = _productData['imageUrl'];
    _priceController.text = _productData['price'].toString();
    _totalWeightController.text = _productData['totalWeight'].toString();
    _nameProductController.text = _productData['productName'];
    _barcodeController.text = _productData['barcode'];
    _discountedPriceController.text =
        discountedProduct?.discountedPrice.toString() ?? '';
    _discountedQuantityOwnedController.text =
        discountedProduct?.discountedQuantityOwned.toString() ?? '';
    _discountedQuantityUnitOwnedController.text =
        discountedProduct?.discountedQuantityUnitOwned.toString() ?? '';
    _discountedQuantityWeightOwnedController.text =
        discountedProduct?.discountedQuantityWeightOwned.toString() ?? '';
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _quantityOwnedController.dispose();
    _quantityUnitOwnedController.dispose();
    _quantityWeightOwnedController.dispose();
    _imageUrlController.dispose();
    _priceController.dispose();
    _totalWeightController.dispose();
    _nameProductController.dispose();
    _barcodeController.dispose();
    _discountedPriceController.dispose();
    _discountedQuantityOwnedController.dispose();
    _discountedQuantityUnitOwnedController.dispose();
    _discountedQuantityWeightOwnedController.dispose();
    super.dispose();
  }

  //crea funzione che prende in input mappa di macronutrienti e setta dynamicMacronutrients\
  void _setDynamicMacronutrients(Map<String, double> macronutrients) {
    setState(() {
      _productData['macronutrients'] = macronutrients;
    });
  }

  Widget _buildValueInput() {
    return Platform.isIOS
        ? CupertinoTextField(
            controller: _priceController,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 24,
            ),
            placeholder: AppLocalizations.of(context)!.price,
            suffix: Text(
              '€',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                // prendi le virgole e sostituiscile con i punti
                value = value.replaceAll(',', '.');
                _productData['price'] = double.tryParse(value) ?? 0.0;
              });
            },
            onSubmitted: (value) {
              value = value.replaceAll(',', '.');
              _productData['price'] = double.tryParse(value) ?? 0.0;
            },
          )
        : TextFormField(
            controller: _priceController,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 24,
            ),
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.price,
              labelStyle: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              suffixText: '€',
              suffixStyle: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).textTheme.bodyLarge?.color ??
                      Colors.black,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).textTheme.bodyLarge?.color ??
                      Colors.black,
                ),
              ),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                // prendi le virgole e sostituiscile con i punti
                value = value.replaceAll(',', '.');
                _productData['price'] = double.tryParse(value) ?? 0.0;
              });
            },
            onSaved: (value) {
              value = value?.replaceAll(',', '.') ?? '';
              _productData['price'] = double.tryParse(value) ?? 0.0;
            },
          );
  }

  Future<void> _loadCategories() async {
    if (!mounted) return;
    await CategoryServices.loadCategoriesData();
    if (!mounted) return;
    setState(() {
      categories = CategoryServices.getCategoriesData()
              ?.map<String>((category) => category['nomeCategoria'])
              .toList() ??
          [];
      _productData['category'] = categories.isNotEmpty
          ? (widget.product?.category ?? categories[0])
          : null;
      selectedCategory = categories.isNotEmpty
          ? (widget.product?.category ?? categories[0])
          : null;
    });
  }

  Widget _buildCategorySelector() {
    // Assicura che selectedCategory abbia un valore iniziale valido
    if (!categories.contains(selectedCategory)) {
      selectedCategory = categories.isNotEmpty ? categories[0] : '';
    }

    return Platform.isIOS
        ? CupertinoPicker(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            itemExtent: 32.0,
            onSelectedItemChanged: (int index) {
              setState(() {
                selectedCategory = categories[index];
                _productData['category'] = selectedCategory;
              });
            },
            children: categories.map((category) {
              return Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CategoryServices.iconFromCategory(category),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        AppLocalizations.of(context)!
                            .translateCategory(category),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          )
        : DropdownButton<String>(
            itemHeight: null,
            isExpanded: true,
            value: selectedCategory,
            dropdownColor: Theme.of(context).scaffoldBackgroundColor,
            items: categories.map((category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CategoryServices.iconFromCategory(category),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        AppLocalizations.of(context)!
                            .translateCategory(category),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedCategory = value;
                  _productData['category'] = selectedCategory;
                });
              }
            },
            underline: const SizedBox(),
          );
  }

  Widget _buildStoreSelector() {
    // Garantisci un valore iniziale valido per selectedStore
    if (!stores.any((store) => store['name'] == selectedStore)) {
      selectedStore = stores.isNotEmpty ? stores[0]['name'] : '';
      _productData['store'] = selectedStore;
    }

    return Platform.isIOS
        ? CupertinoPicker(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            itemExtent: 32.0,
            onSelectedItemChanged: (int index) {
              setState(() {
                selectedStore = stores[index]['name'];
                _productData['store'] = selectedStore;
              });
            },
            children: stores.map((store) {
              return Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: Icon(
                        IconsHelper.iconMap[store['icon']],
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        AppLocalizations.of(context)!
                            .getStorageTitle(store['name']),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          )
        : DropdownButton<String>(
            itemHeight: null,
            isExpanded: true,
            value: selectedStore,
            dropdownColor: Theme.of(context).scaffoldBackgroundColor,
            items: stores.map((store) {
              return DropdownMenuItem<String>(
                value: store['name'],
                child: Row(
                  children: [
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: Icon(
                        IconsHelper.iconMap[store['icon']],
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      AppLocalizations.of(context)!
                          .getStorageTitle(store['name']),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedStore = value;
                  _productData['store'] = selectedStore;
                });
              }
            },
            underline: const SizedBox(),
          );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      Function(String?) onChange) {
    return Platform.isIOS
        ? CupertinoTextField(
            controller: controller,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            placeholder: label,
            onChanged: onChange,
          )
        : TextFormField(
            controller: controller,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).textTheme.bodyLarge?.color ??
                      Colors.black,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).textTheme.bodyLarge?.color ??
                      Colors.black,
                ),
              ),
            ),
            onChanged: onChange,
          );
  }

  Widget _buildMacronutrientTable() {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height *
            0.5, // Set max height to 50% of screen height
      ),
      child: widget.product != null
          ? MacronutrientTable(
              _setDynamicMacronutrients, widget.product!.macronutrients)
          : MacronutrientTable(_setDynamicMacronutrients),
    );
  }

  Widget _buildQuantityInput() {
    return Platform.isIOS
        ? Row(
            children: [
              CupertinoButton(
                child: const Icon(CupertinoIcons.minus),
                onPressed: () {
                  setState(() {
                    _productData['quantity'] =
                        (_productData['quantity'] as int) > 0
                            ? (_productData['quantity'] as int) - 1
                            : 0;
                    _quantityController.text =
                        _productData['quantity'].toString();
                  });
                },
              ),
              Expanded(
                child: CupertinoTextField(
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 24,
                  ),
                  placeholder: AppLocalizations.of(context)!.quantity,
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _productData['quantity'] = int.tryParse(value) ?? 0;
                    });
                  },
                ),
              ),
              CupertinoButton(
                child: const Icon(CupertinoIcons.plus),
                onPressed: () {
                  setState(() {
                    _productData['quantity'] =
                        (_productData['quantity'] as int) + 1;
                    _quantityController.text =
                        _productData['quantity'].toString();
                  });
                },
              ),
            ],
          )
        : Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  setState(() {
                    _productData['quantity'] =
                        (_productData['quantity'] as int) > 0
                            ? (_productData['quantity'] as int) - 1
                            : 0;
                    _quantityController.text =
                        _productData['quantity'].toString();
                  });
                },
              ),
              Expanded(
                child: TextFormField(
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 24,
                  ),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.quantity,
                    labelStyle: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  controller: _quantityController,
                  onChanged: (value) {
                    setState(() {
                      _productData['quantity'] = int.tryParse(value) ?? 0;
                    });
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    _productData['quantity'] =
                        (_productData['quantity'] as int) + 1;
                    _quantityController.text =
                        _productData['quantity'].toString();
                  });
                },
              ),
            ],
          );
  }

  Widget _buildImageInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ImageInput(
        onPickImage: (image) {
          setState(() {
            _selectedImage = image;
          });
        },
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Platform.isIOS
        ? Row(
            children: [
              Expanded(
                child: CupertinoButton(
                  onPressed: () => Navigator.of(context).pop(),
                  color: Theme.of(context).colorScheme.primary,
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CupertinoButton(
                  onPressed:
                      widget.product == null ? _saveProduct : _updateProduct,
                  color: Theme.of(context).colorScheme.primary,
                  child: Text(widget.product == null
                      ? AppLocalizations.of(context)!.save
                      : AppLocalizations.of(context)!.update),
                ),
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      widget.product == null ? _saveProduct : _updateProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: Text(widget.product == null
                      ? AppLocalizations.of(context)!.save
                      : AppLocalizations.of(context)!.update),
                ),
              ),
            ],
          );
  }

  //funzione per creare il widget per inserire a mano imageUrl del prodotto
  Widget _buildImageUrlInput() {
    return Platform.isIOS
        ? Row(
            children: [
              Expanded(
                child: CupertinoTextField(
                  controller: _imageUrlController,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  placeholder: AppLocalizations.of(context)!.imageUrl,
                  onChanged: (value) {
                    setState(() {
                      _productData['imageUrl'] = value;
                    });
                  },
                ),
              ),
              CupertinoButton(
                child: Icon(CupertinoIcons.delete,
                    color: Theme.of(context).colorScheme.error),
                onPressed: () {
                  setState(() {
                    _imageUrlController.clear();
                    _selectedImage = null;
                    _productData['imageUrl'] = '';
                  });
                },
              ),
              CupertinoButton(
                child: Icon(CupertinoIcons.check_mark,
                    color: Theme.of(context).colorScheme.primary),
                onPressed: () {
                  setState(() {
                    _productData['imageUrl'] = _imageUrlController.text;
                  });
                },
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _imageUrlController,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.imageUrl,
                    labelStyle: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).textTheme.bodyLarge?.color ??
                            Colors.black,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).textTheme.bodyLarge?.color ??
                            Colors.black,
                      ),
                    ),
                  ),
                  onSaved: (value) {
                    setState(() {
                      _productData['imageUrl'] = value;
                    });
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _imageUrlController.clear();
                    _selectedImage = null;
                    _productData['imageUrl'] = '';
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.save,
                    color: Theme.of(context).colorScheme.primary),
                onPressed: () {
                  setState(() {
                    _productData['imageUrl'] = _imageUrlController.text;
                  });
                },
              ),
            ],
          );
  }

  //scrivi _updateProduct per aggiornare il prodotto nel database
  void _updateProduct() async {
    //TODO: funziona ma è inefficiente, bisogna ottimizzare
    if (!mounted) return;
    User? user;
    _productData['unitPrice'] =
        _productData['price'] / _productData['quantity'];
    _productData['unitWeight'] =
        _productData['totalWeight'] / _productData['quantity'];
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      user = FirebaseAuth.instance.currentUser;
      if (_selectedImage != null) {
        if (user != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child(user.uid)
              .child('product_images')
              .child(
                  '${_productData['productName']}_${UniqueKey().toString()}.jpg');

          await storageRef.putFile(_selectedImage!);
          if (!mounted) return;
          final imageUrl = await storageRef.getDownloadURL();
          if (!mounted) return;
          setState(() {
            _productData['imageUrl'] = imageUrl;
          });
        }
      }
      if (discountedProduct != null) {
        if (discountedProduct!.discountedQuantityWeightOwned == 0) {
          ref
              .read(discountedProductsProvider.notifier)
              .removeDiscountedProduct(discountedProduct!.productId);
          discountedProduct = null;
        } else {
          ref
              .read(discountedProductsProvider.notifier)
              .updateDiscountedProduct(discountedProduct!);
        }
      }

      // Save product to Firestore
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('products').doc(user?.uid);

      try {
        // Trova il prodotto con lo stesso id e aggiorna i suoi dati
        // Leggi il documento corrente
        DocumentSnapshot userDoc = await userDocRef.get();
        if (!mounted) return;
        List<dynamic> products = userDoc['products'];
        //
        // for (Map<String, dynamic> product in products) {
        //   product['quantityOwned']=0;
        //   product['quantityUnitOwned'] = 0;
        //   product['quantityWeightOwned'] = 0;
        // }

// Trova il prodotto da rimuovere confrontando il productId
        int index = products.indexWhere(
            (product) => product['productId'] == widget.product!.productId);
        if (index != -1) {
          products[index] = _productData;
        }

// Aggiorna il documento con l'array aggiornato
        await userDocRef.update({
          "products": products,
        });
        if (!mounted) return;
        ToastNotifier.showSuccess(context, 'Prodotto aggiornato con successo!');
        int count = 0;
        Navigator.of(context).popUntil((route) {
          return count++ == 2;
        });
      } catch (e) {
        if (!mounted) return;
        ToastNotifier.showError(
            'Errore durante l\'aggiornamento del prodotto: $e');
      }
    }
  }

  void _saveProduct() async {
    if (!mounted) return;
    User? user;
    _productData['unitPrice'] =
        _productData['price'] / _productData['quantity'];
    _productData['unitWeight'] =
        _productData['totalWeight'] / _productData['quantity'];
    // if (_productData['quantityUnitOwned'] == 0) {
    //   _productData['quantityUnitOwned'] = _productData['quantity'];
    // }
    // if (_productData['quantityWeightOwned'] == 0) {
    //   _productData['quantityWeightOwned'] =
    //       _productData['totalWeight'] * _productData['quantityOwned'];
    // }
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      user = FirebaseAuth.instance.currentUser;
      if (_selectedImage != null) {
        if (user != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child(user.uid)
              .child('product_images')
              .child(
                  '${_productData['productName']}_${UniqueKey().toString()}.jpg');

          await storageRef.putFile(_selectedImage!);
          if (!mounted) return;
          final imageUrl = await storageRef.getDownloadURL();
          if (!mounted) return;
          setState(() {
            _productData['imageUrl'] = imageUrl;
          });
        }
      }

      // Save product to Firestore
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('products').doc(user?.uid);

      try {
        // Aggiorna il documento esistente aggiungendo il prodotto all'array "products"
        await userDocRef.update({
          "products": FieldValue.arrayUnion([_productData])
        });
        if (!mounted) return;
        ToastNotifier.showSuccess(
            context, AppLocalizations.of(context)!.successAddProduct);
        Navigator.of(context).pop();
      } catch (e) {
        if (!mounted) return;
        ToastNotifier.showError('Errore durante l\'aggiunta del prodotto: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(
            widget.product != null
                ? AppLocalizations.of(context)!.editProduct
                : AppLocalizations.of(context)!.newProduct,
            style: TextStyle(
              color: CupertinoTheme.of(context).primaryColor,
            ),
          ),
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Icon(
              CupertinoIcons.back,
              color: CupertinoTheme.of(context).primaryColor,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        child: SafeArea(
          child: _buildForm(context),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          centerTitle: true,
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: Theme.of(context).appBarTheme.foregroundColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            widget.product != null
                ? AppLocalizations.of(context)!.editProduct
                : AppLocalizations.of(context)!.newProduct,
            style:
                TextStyle(color: Theme.of(context).appBarTheme.foregroundColor),
          ),
        ),
        body: _buildForm(context),
      );
    }
  }

  Widget _buildForm(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3, // 60% of the row
                      child: _buildTextField(
                          AppLocalizations.of(context)!.productName,
                          _nameProductController,
                          (value) => _productData['productName'] = value),
                    ),
                    Expanded(
                      flex: 2, // 40% of the row
                      child: _productData['imageUrl'] == null ||
                              _productData['imageUrl'].isEmpty
                          ? _buildImageInput()
                          : Image.network(_productData['imageUrl']),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 4, // 30% of the row
                      child: _buildQuantityInput(),
                    ),
                    const Spacer(flex: 1), // 10% of the row
                    Expanded(
                      flex: 2, // 30% of the row
                      child: _buildValueInput(),
                    ),
                    const Spacer(flex: 1), // 10% of the row
                    Expanded(
                      flex: 2, // 20% of the row
                      child: ValueListenableBuilder(
                        valueListenable: ValueNotifier(_productData['price'] /
                            (_productData['quantity'] > 0
                                ? _productData['quantity']
                                : 1)),
                        builder: (context, value, child) {
                          return Text(
                            'C/U: €${value.toStringAsFixed(3)}',
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 4, // 30% of the row
                      child: _buildTextField(
                          '${AppLocalizations.of(context)!.totalWeight} (kg/l)',
                          _totalWeightController, (value) {
                        setState(() {
                          value = value?.replaceAll(',', '.');
                          _productData['totalWeight'] =
                              double.tryParse(value ?? '0') ?? 0.0;
                        });
                      }),
                    ),
                    const Spacer(flex: 1), // 10% of the row
                    Expanded(
                      flex: 2, // 30% of the row
                      child: ValueListenableBuilder(
                        valueListenable: ValueNotifier(_productData['price'] /
                            (_productData['totalWeight'] > 0
                                ? _productData['totalWeight']
                                : 1)),
                        builder: (context, value, child) {
                          return Text(
                            '€/kg: €${value.toStringAsFixed(3)}',
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          );
                        },
                      ),
                    ),
                    const Spacer(flex: 1), // 10% of the row
                    Expanded(
                      flex: 2, // 20% of the row
                      child: ValueListenableBuilder(
                        valueListenable: ValueNotifier(
                            _productData['totalWeight'] /
                                (_productData['quantity'] > 0
                                    ? _productData['quantity']
                                    : 1)),
                        builder: (context, value, child) {
                          return Text(
                            '${AppLocalizations.of(context)!.unitWeight}: ${value > 1 ? value.toStringAsFixed(3) + ' Kg' : (value * 1000).toStringAsFixed(3) + ' g'}',
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: _buildTextField(
                        '${AppLocalizations.of(context)!.quantityOwned}:',
                        _quantityOwnedController, (value) {
                      setState(() {
                        value = value?.replaceAll(',', '.');
                        _productData['quantityOwned'] =
                            double.tryParse(value ?? '0') ?? 0.0;
                      });
                    }),
                  ),
                  Expanded(
                    child: _buildTextField(
                        '${AppLocalizations.of(context)!.quantityUnitOwned}:',
                        _quantityUnitOwnedController, (value) {
                      setState(() {
                        value = value?.replaceAll(',', '.');
                        _productData['quantityUnitOwned'] =
                            double.tryParse(value ?? '0') ?? 0.0;
                      });
                    }),
                  ),
                ]),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: _buildTextField(
                            '${AppLocalizations.of(context)!.quantityWeightOwned}:',
                            _quantityWeightOwnedController, (value) {
                          setState(() {
                            value = value?.replaceAll(',', '.');
                            _productData['quantityWeightOwned'] =
                                double.tryParse(value ?? '0') ?? 0.0;
                          });
                        }),
                      ),
                    ),
                  ],
                ),
                if (discountedProduct != null)
                  Column(
                    children: [
                      const Divider(),
                      Text(
                        AppLocalizations.of(context)!.discountedProduct,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              AppLocalizations.of(context)!
                                  .discountedQuantityOwned,
                              _discountedQuantityOwnedController,
                              (value) {
                                value = value?.replaceAll(',', '.');
                                setState(() {
                                  discountedProduct!.discountedQuantityOwned =
                                      double.tryParse(value ?? '0') ?? 0;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              AppLocalizations.of(context)!
                                  .discountedQuantityUnitOwned,
                              _discountedQuantityUnitOwnedController,
                              (value) {
                                setState(() {
                                  value = value?.replaceAll(',', '.');
                                  discountedProduct!
                                          .discountedQuantityUnitOwned =
                                      int.tryParse(value ?? '0') ?? 0;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              AppLocalizations.of(context)!
                                  .discountedQuantityWeightOwned,
                              _discountedQuantityWeightOwnedController,
                              (value) {
                                setState(() {
                                  value = value?.replaceAll(',', '.');
                                  discountedProduct!
                                          .discountedQuantityWeightOwned =
                                      double.tryParse(value ?? '0') ?? 0.0;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              AppLocalizations.of(context)!.discountedPrice,
                              _discountedPriceController,
                              (value) {
                                setState(() {
                                  value = value?.replaceAll(',', '.');
                                  discountedProduct!.discountedPrice =
                                      double.tryParse(value ?? '0') ?? 0.0;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                    ],
                  ),
                Row(
                  children: [
                    Flexible(
                      fit: FlexFit.tight,
                      child: _buildCategorySelector(),
                    ),
                    Flexible(
                      fit: FlexFit.tight,
                      child: _buildStoreSelector(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildMacronutrientTable(),
                _buildImageUrlInput(),
                _buildTextField(
                    AppLocalizations.of(context)!.barcode,
                    _barcodeController,
                    (value) => _productData['barcode'] = value),
                Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.expirationDate,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    Platform.isIOS
                        ? CupertinoButton(
                            child: Icon(CupertinoIcons.calendar,
                                color: Theme.of(context).colorScheme.primary),
                            onPressed: () async {
                              DateTime? pickedDate =
                                  await showCupertinoModalPopup(
                                context: context,
                                builder: (context) => Container(
                                  height: 250,
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  child: CupertinoDatePicker(
                                    initialDateTime:
                                        _productData['expirationDate']
                                                .isNotEmpty
                                            ? DateTime.parse(
                                                _productData['expirationDate'])
                                            : DateTime.now(),
                                    mode: CupertinoDatePickerMode.date,
                                    onDateTimeChanged: (DateTime dateTime) {
                                      setState(() {
                                        _productData['expirationDate'] =
                                            dateTime.toIso8601String();
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          )
                        : IconButton(
                            icon: Icon(Icons.calendar_today,
                                color: Theme.of(context).colorScheme.primary),
                            onPressed: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate:
                                    _productData['expirationDate'].isNotEmpty
                                        ? DateTime.parse(
                                            _productData['expirationDate'])
                                        : DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  _productData['expirationDate'] =
                                      pickedDate.toIso8601String();
                                });
                              }
                            },
                          ),
                    Text(
                      _productData['expirationDate'].isNotEmpty
                          ? DateFormat('yyyy-MM-dd').format(
                              DateTime.parse(_productData['expirationDate']))
                          : '',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildBottomButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
