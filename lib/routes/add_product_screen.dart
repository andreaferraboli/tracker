import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tracker/models/image_input.dart';
import 'package:tracker/models/macronutrients_table.dart';

import '../services/category.dart';

class AddProductScreen extends StatefulWidget {
  final String supermarketName;

  const AddProductScreen({super.key, required this.supermarketName});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  // Aggiornamento della mappa _productData per includere i nuovi parametri
  final Map<String, dynamic> _productData = {
    'barcode': '',
    'category': '',
    'expirationDate': '',
    'macronutrients': {
      'calories': 0,
      'carbohydrates': 0.0,
      'fat': 0.0,
      'protein': 0.0,
    },
    'price': 0.0,
    'totalPrice': 0.0,
    'unitPrice': 0.0,
    'productId': '',
    'productName': '',
    'purchaseDate': '',
    'quantity': 0,
    'supermarket': '',
    'unit': '',
    'imageUrl': '',
    'totalWeight': 0.0, // Peso totale articolo
    'unitWeight': 0.0, // Peso del singolo articolo
  };

  List<String> categories = [];
  String? selectedCategory = 'Latticini';
  File? _selectedImage;
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _quantityController.text = _productData['quantity'].toString();
    _imageUrlController.text = _productData['imageUrl'];
    _productData['supermarket'] = widget.supermarketName;
    _productData['unit'] = 'kg';
    _productData['purchaseDate'] = DateTime.now().toString();
    _productData['productId'] = UniqueKey().toString();
    _loadCategories();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  //crea funzione che prende in input mappa di macronutrienti e setta dynamicMacronutrients\
  void _setDynamicMacronutrients(Map<String, double> macronutrients) {
    setState(() {
      _productData['macronutrients'] = macronutrients;
    });
  }

  Widget _buildValueInput() {
    return TextFormField(
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontSize: 24,
        ),
        decoration: InputDecoration(
          labelText: 'Prezzo',
          labelStyle: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          suffixText: '€',
          suffixStyle: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color:
                  Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color:
                  Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
            ),
          ),
        ),
        keyboardType: TextInputType.number,
        onChanged: (value) {
          setState(() {
            //prendi le virgole e sostituiscile con i punti
            value = value.replaceAll(',', '.');
            _productData['price'] = double.tryParse(value) ?? 0.0;
          });
        },
        onSaved: (value) {
          value = value?.replaceAll(',', '.') ?? '';
          _productData['price'] = double.tryParse(value) ?? 0.0;
        });
  }

  Future<void> _loadCategories() async {
    await CategoryIcon.loadCategoriesData();
    setState(() {
      categories = CategoryIcon.getCategoriesData()
              ?.map<String>((category) => category['nomeCategoria'])
              .toList() ??
          [];
      _productData['category'] = categories.isNotEmpty ? categories[0] : null;
      selectedCategory = categories.isNotEmpty ? categories[0] : null;
    });
  }

  Widget _buildCategorySelector() {
    return Center(
      child: DropdownButton<String>(
        value: selectedCategory,
        dropdownColor: Theme.of(context).scaffoldBackgroundColor,
        items: categories.map((category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Center(
              child: Row(
                children: [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: CategoryIcon.iconFromCategory(category),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    category,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedCategory = value;
            _productData['category'] = selectedCategory;
          });
        },
        underline: SizedBox(),
      ),
    );
  }

  Widget _buildTextField(String label, Function(String?) onChange) {
    return TextFormField(
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
            color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
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
      child: MacronutrientTable(_setDynamicMacronutrients),
    );
  }

  Widget _buildQuantityInput() {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.remove),
          onPressed: () {
            setState(() {
              _productData['quantity'] = (_productData['quantity'] as int) > 0
                  ? (_productData['quantity'] as int) - 1
                  : 0;
              _quantityController.text = _productData['quantity'].toString();
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
              labelText: 'Quantity',
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
          icon: Icon(Icons.add),
          onPressed: () {
            setState(() {
              _productData['quantity'] = (_productData['quantity'] as int) + 1;
              _quantityController.text = _productData['quantity'].toString();
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
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text('ANNULLA'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveProduct,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text('SALVA'),
          ),
        ),
      ],
    );
  }

  //funzione per creare il widget per inserire a mano imageUrl del prodotto
  Widget _buildImageUrlInput() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _imageUrlController,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            decoration: InputDecoration(
              labelText: 'ImageUrl',
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
          icon: Icon(Icons.save, color: Theme.of(context).colorScheme.primary),
          onPressed: () {
            setState(() {
              _productData['imageUrl'] = _imageUrlController.text;
            });
          },
        ),
      ],
    );
  }

  void _saveProduct() async {
    User? user;
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
          final imageUrl = await storageRef.getDownloadURL();
          //setta imageUrl in _productData con setState
          setState(() {
            _productData['imageUrl'] = imageUrl;
          });
        }
      }

      // Save product to Firestore
      print("user_uid:${user!.uid}");
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('products').doc(user?.uid);

      try {
        // Aggiorna il documento esistente aggiungendo il prodotto all'array "products"
        await userDocRef.update({
          "products": FieldValue.arrayUnion([_productData])
        });
        print('Prodotto aggiunto con successo!');
        Navigator.of(context).pop();
      } catch (e) {
        print('Errore durante l\'aggiunta del prodotto: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).textTheme.bodyLarge?.color),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Nuovo Prodotto',
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.star_border,
                color: Theme.of(context).textTheme.bodyLarge?.color),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert,
                color: Theme.of(context).textTheme.bodyLarge?.color),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
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
                        child: _buildTextField('Nome prodotto',
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
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 4, // 30% of the row
                        child: _buildQuantityInput(),
                      ),
                      Spacer(flex: 1), // 10% of the row
                      Expanded(
                        flex: 2, // 30% of the row
                        child: _buildValueInput(),
                      ),
                      Spacer(flex: 1), // 10% of the row
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
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 4, // 30% of the row
                        child:
                            _buildTextField('Peso totale (kg/litro)', (value) {
                          setState(() {
                            value = value?.replaceAll(',', '.');
                            _productData['totalWeight'] =
                                double.tryParse(value ?? '0') ?? 0.0;
                          });
                        }),
                      ),
                      Spacer(flex: 1), // 10% of the row
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
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                              ),
                            );
                          },
                        ),
                      ),
                      Spacer(flex: 1), // 10% of the row
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
                              'Peso unitario: ${(value * 1000).toStringAsFixed(3)} g',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _buildCategorySelector(),
                  SizedBox(height: 16),
                  _buildMacronutrientTable(),
                  _buildImageUrlInput(),
                  _buildTextField('Codice a barre',
                      (value) => _productData['barcode'] = value),
                  _buildBottomButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
