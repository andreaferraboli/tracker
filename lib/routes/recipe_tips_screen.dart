import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RecipeTipsScreen extends StatefulWidget {
  const RecipeTipsScreen({super.key});

  @override
  _RecipeTipsScreenState createState() => _RecipeTipsScreenState();
}

class _RecipeTipsScreenState extends State<RecipeTipsScreen> {
  List<Map<String, dynamic>> _mealSuggestions = [];

  @override
  void initState() {
    super.initState();
    _fetchMealSuggestions();
  }

  Future<void> _fetchMealSuggestions() async {
    // Commento: Qui puoi inserire il codice per fare una richiesta HTTP
    // final response = await http.get(
    //   Uri.parse('https://api.example.com/recipes'),
    //   headers: {'Content-Type': 'application/json'},
    // );

    // Simulazione di un JSON ricevuto da una richiesta HTTP
    const String mockJsonResponse = '''
    {
      "meals": [
        {
          "name": "Spaghetti Carbonara",
          "ingredients": ["Spaghetti", "Uova", "Pancetta", "Pecorino", "Pepe"]
        },
        {
          "name": "Insalata Greca",
          "ingredients": ["Pomodori", "Cipolla", "Olive", "Feta", "Cetrioli"]
        },
        {
          "name": "Pizza Margherita",
          "ingredients": ["Farina", "Mozzarella", "Pomodoro", "Basilico", "Olio"]
        }
      ]
    }
    ''';

    // Parsing del mock JSON come se fosse la risposta da un server
    final Map<String, dynamic> jsonResponse = jsonDecode(mockJsonResponse);

    // Aggiorna lo stato con i dati della simulazione
    setState(() {
      _mealSuggestions = List<Map<String, dynamic>>.from(jsonResponse['meals']);
    });

    // Nel caso reale:
    // if (response.statusCode == 200) {
    //   setState(() {
    //     _mealSuggestions = List<Map<String, dynamic>>.from(jsonDecode(response.body)['meals']);
    //   });
    // } else {
    //   // Gestione dell'errore
    //   print('Failed to fetch meal suggestions');
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Tips'),
      ),
      body: _mealSuggestions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _mealSuggestions.length,
        itemBuilder: (context, index) {
          final recipe = _mealSuggestions[index];
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text(recipe['name']),
              subtitle: Text("Ingredients: ${recipe['ingredients'].join(', ')}"),
            ),
          );
        },
      ),
    );
  }
}
