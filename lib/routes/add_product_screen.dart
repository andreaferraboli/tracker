import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tracker/models/image_input.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

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
    'productId': '',
    'productName': '',
    'purchaseDate': '',
    'quantity': 0,
    'supermarket': '',
    'totalPrice': 0.0,
    'unit': '',
  };

  List<String> categories = ['Latticini', 'Seleziona categoria'];
  String? selectedCategory = 'Latticini';
  File? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title:
            const Text('Nuovo Prodotto', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.star_border, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[900],
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildTopButtons(),
              _buildTextField(
                  'Barcode', (value) => _productData['barcode'] = value),
              _buildTextField('Nome Prodotto',
                  (value) => _productData['productName'] = value),
              _buildValueInput(),
              _buildCategorySelector(),
              _buildTextField('Data di Scadenza',
                  (value) => _productData['expirationDate'] = value),
              _buildMacronutrientInput('Calorie', 'calories'),
              _buildMacronutrientInput('Carboidrati', 'carbohydrates'),
              _buildMacronutrientInput('Grassi', 'fat'),
              _buildMacronutrientInput('Proteine', 'protein'),
              _buildTextField(
                  'ID Prodotto', (value) => _productData['productId'] = value),
              _buildTextField('Unità', (value) => _productData['unit'] = value),
              _buildQuantityInput(),
              _buildTextField('Supermercato',
                  (value) => _productData['supermarket'] = value),
              _buildTextField(
                  'Prezzo Totale',
                  (value) => _productData['totalPrice'] =
                      double.tryParse(value!) ?? 0.0),
              _buildImageInput(),
              _buildBottomButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildValueInput() {
    return TextFormField(
      style: const TextStyle(color: Colors.white, fontSize: 24),
      decoration: const InputDecoration(
        labelText: 'Prezzo',
        labelStyle: TextStyle(color: Colors.white54),
        suffixText: '€',
        suffixStyle: TextStyle(color: Colors.white),
        enabledBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      ),
      keyboardType: TextInputType.number,
      onSaved: (value) =>
          _productData['price'] = double.tryParse(value!) ?? 0.0,
    );
  }

  Widget _buildCategorySelector() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        enabledBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      ),
      dropdownColor: Colors.grey[800],
      value: selectedCategory,
      items: categories.map((category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Row(
            children: [
              Icon(category == 'Latticini' ? Icons.fastfood : Icons.category,
                  color: Colors.green),
              const SizedBox(width: 10),
              Text(category, style: const TextStyle(color: Colors.white)),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedCategory = value;
          _productData['category'] = selectedCategory;
        });
      },
    );
  }

  Widget _buildTextField(String label, Function(String?) onSaved) {
    return TextFormField(
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white54)),
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white)),
      ),
      onSaved: onSaved,
    );
  }

  Widget _buildMacronutrientInput(String label, String fieldName) {
    return TextFormField(
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white54)),
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white)),
      ),
      keyboardType: TextInputType.number,
      onSaved: (value) => _productData['macronutrients'][fieldName] =
          double.tryParse(value!) ?? 0.0,
    );
  }

  Widget _buildQuantityInput() {
    return TextFormField(
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        labelText: 'Quantità',
        labelStyle: TextStyle(color: Colors.white54),
        enabledBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      ),
      keyboardType: TextInputType.number,
      onSaved: (value) => _productData['quantity'] = int.tryParse(value!) ?? 0,
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

  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_selectedImage != null) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child(user.uid)
              .child('product_images')
              .child(
                  '${_productData['productName']}_${UniqueKey().toString()}.jpg');

          await storageRef.putFile(_selectedImage!);
          final imageUrl = await storageRef.getDownloadURL();
          _productData['imageUrl'] = imageUrl;
        }
      }

      // Implement your save logic here
      print(_productData);
    }
  }
}
