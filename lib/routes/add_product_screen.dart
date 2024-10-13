import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _productData = {
    'productId': '',
    'productName': '',
    'category': '',
    'price': 0.0,
    'quantity': 0,
    'unit': '',
    'totalPrice': 0.0,
    'supermarket': '',
    'purchaseDate': '',
    'expirationDate': '',
    'barcode': '',
    'macronutrients': {
      'calories': 0,
      'protein': 0.0,
      'fat': 0.0,
      'carbohydrates': 0.0,
    },
  };

  List<String> categories = [];
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
  final jsonString = await rootBundle.loadString('assets/json/categories.json');
  final List<dynamic> jsonData = json.decode(jsonString);
  setState(() {
    categories = jsonData.map((category) => category['name'] as String).toList();
  });
}

  void _uploadProductToFirestore() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Calculate total price automatically
      _productData['totalPrice'] = _productData['price'] * _productData['quantity'];

      // Implement your Firestore upload logic here
      print(_productData); // Just for testing purposes
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aggiungi Prodotto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildInputCard('ID Prodotto', (value) => _productData['productId'] = value),
              _buildInputCard('Nome Prodotto', (value) => _productData['productName'] = value),
              _buildCategoryCard(),
              _buildInputCard('Prezzo', (value) => _productData['price'] = double.tryParse(value!) ?? 0.0, isNumeric: true),
              _buildInputCard('Quantità', (value) => _productData['quantity'] = int.tryParse(value!) ?? 0, isNumeric: true),
              _buildInputCard('Unità di Misura', (value) => _productData['unit'] = value),
              _buildInputCard('Supermercato', (value) => _productData['supermarket'] = value),
              _buildInputCard('Data di Acquisto (YYYY-MM-DD)', (value) => _productData['purchaseDate'] = value),
              _buildInputCard('Data di Scadenza (YYYY-MM-DD)', (value) => _productData['expirationDate'] = value),
              _buildInputCard('Codice a Barre', (value) => _productData['barcode'] = value),
              _buildMacronutrientsCard('Calorie (per 100g)', (value) => _productData['macronutrients']['calories'] = int.tryParse(value!) ?? 0),
              _buildMacronutrientsCard('Proteine (per 100g)', (value) => _productData['macronutrients']['protein'] = double.tryParse(value!) ?? 0.0),
              _buildMacronutrientsCard('Grassi (per 100g)', (value) => _productData['macronutrients']['fat'] = double.tryParse(value!) ?? 0.0),
              _buildMacronutrientsCard('Carboidrati (per 100g)', (value) => _productData['macronutrients']['carbohydrates'] = double.tryParse(value!) ?? 0.0),

              ElevatedButton(
                onPressed: _uploadProductToFirestore,
                child: Text('Aggiungi Prodotto'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard(String label, Function(String?) onSaved, {bool isNumeric = false}) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextFormField(
          decoration: InputDecoration(labelText: label),
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          onSaved: onSaved,
          validator: (value) => value!.isEmpty ? 'Campo obbligatorio' : null,
        ),
      ),
    );
  }

  Widget _buildCategoryCard() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(labelText: 'Categoria'),
          value: selectedCategory,
          items: categories.map((category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedCategory = value;
              _productData['category'] = selectedCategory;
            });
          },
          validator: (value) => value == null ? 'Campo obbligatorio' : null,
        ),
      ),
    );
  }

  Widget _buildMacronutrientsCard(String label, Function(String?) onSaved) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(label),
            TextFormField(
              keyboardType: TextInputType.number,
              onSaved: onSaved,
              validator: (value) => null, // Optional fields
            ),
          ],
        ),
      ),
    );
  }
}
