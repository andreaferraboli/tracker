import 'dart:convert';
import 'package:flutter/material.dart';

class RecipeTipsScreen extends StatefulWidget {
  const RecipeTipsScreen({super.key});

  @override
  _RecipeTipsScreenState createState() => _RecipeTipsScreenState();
}

class _RecipeTipsScreenState extends State<RecipeTipsScreen> {
  List<Map<String, dynamic>> _recipeSuggestions = [];

  @override
  void initState() {
    super.initState();
    _fetchRecipeSuggestions();
  }

  Future<void> _fetchRecipeSuggestions() async {
    // Simulazione di una risposta da un server
    const String mockJsonResponse = '''
    [
      {
        "name": "Torta tenerina",
        "imageUrl": "https://www.giallozafferano.it/images/242-24248/Torta-tenerina_360x300.jpg",
        "calories": 395,
        "rating": 4.4,
        "time": "45 min"
      },
      {
        "name": "Torta di mele",
        "imageUrl": "https://www.giallozafferano.it/images/242-24248/Torta-tenerina_360x300.jpg",
        "calories": 395,
        "rating": 4.1,
        "time": "1h 15min"
      }
    ]
    ''';

    // Parsing della stringa JSON simulata
    final List<dynamic> jsonData = jsonDecode(mockJsonResponse);

    setState(() {
      _recipeSuggestions = jsonData.map((recipe) => {
        'name': recipe['name'],
        'imageUrl': recipe['imageUrl'],
        'calories': recipe['calories'],
        'rating': recipe['rating'],
        'time': recipe['time'],
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Tips'),
      ),
      body: _recipeSuggestions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _recipeSuggestions.length,
        itemBuilder: (context, index) {
          final recipe = _recipeSuggestions[index];
          return Card(
            margin: const EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  // Immagine a sinistra
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Image.network(
                      recipe['imageUrl'],
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16), // Spaziatura tra immagine e info
                  // Informazioni a destra
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe['name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.local_fire_department,
                              color: Colors.orange,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text('${recipe['calories']} kcal'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.timer,
                              color: Colors.grey,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(recipe['time']),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.yellow,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(recipe['rating'].toString()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
