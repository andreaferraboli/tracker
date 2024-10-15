import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _productData = {
    'category': '',
    'value': 0.0,
    'portfolio': '',
    'date': DateTime.now(),
    'assignedTo': '',
    'notes': '',
    'isControlled': false,
  };

  List<String> categories = ['Casa', 'Seleziona categoria'];
  String? selectedCategory = 'Casa';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Nuova spesa', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.star_border, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[900],
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(16),
            children: [
              _buildTopButtons(),
              _buildValueInput(),
              _buildCategorySelector(),
              _buildTotalValue(),
              _buildDivider(),
              _buildIconTextField(Icons.account_balance, 'Portafoglio', (value) => _productData['portfolio'] = value),
              _buildIconTextField(Icons.calendar_today, '15/10/2024', (value) => _productData['date'] = value),
              _buildIconTextField(Icons.person, 'A (Opzionale)', (value) => _productData['assignedTo'] = value),
              _buildIconTextField(Icons.note, 'Note (Opzionale)', (value) => _productData['notes'] = value),
              _buildControlledSwitch(),
              _buildImageButtons(),
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
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.refresh, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildValueInput() {
    return TextFormField(
      style: TextStyle(color: Colors.white, fontSize: 24),
      decoration: InputDecoration(
        labelText: 'Valore',
        labelStyle: TextStyle(color: Colors.white54),
        suffixText: '€',
        suffixStyle: TextStyle(color: Colors.white),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      ),
      keyboardType: TextInputType.number,
      onSaved: (value) => _productData['value'] = double.tryParse(value!) ?? 0.0,
    );
  }

  Widget _buildCategorySelector() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      ),
      dropdownColor: Colors.grey[800],
      value: selectedCategory,
      items: categories.map((category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Row(
            children: [
              Icon(category == 'Casa' ? Icons.home : Icons.category, color: Colors.green),
              SizedBox(width: 10),
              Text(category, style: TextStyle(color: Colors.white)),
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

  Widget _buildTotalValue() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Totale:', style: TextStyle(color: Colors.white)),
          Text('0,00 €', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.white54);
  }

  Widget _buildIconTextField(IconData icon, String label, Function(String?) onSaved) {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        icon: Icon(icon, color: Colors.white54),
        labelText: label,
        labelStyle: TextStyle(color: Colors.white54),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      ),
      onSaved: onSaved,
    );
  }

  Widget _buildControlledSwitch() {
    return SwitchListTile(
      title: Text('Controllata', style: TextStyle(color: Colors.white)),
      value: _productData['isControlled'],
      onChanged: (bool value) {
        setState(() {
          _productData['isControlled'] = value;
        });
      },
      activeColor: Colors.red,
    );
  }

  Widget _buildImageButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(Icons.camera_alt, color: Colors.white54),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.image, color: Colors.white54),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            child: Text('ANNULLA'),
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            child: Text('SALVA'),
            onPressed: _saveProduct,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ),
      ],
    );
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Implement your save logic here
      print(_productData);
    }
  }
}