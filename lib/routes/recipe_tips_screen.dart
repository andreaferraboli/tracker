import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import per multilingua
import 'package:http/http.dart' as http;

class RecipeTipsScreen extends StatefulWidget {
  final List<String> ingredientNames;

  // Costruttore per passare i nomi degli ingredienti
  RecipeTipsScreen({required this.ingredientNames});

  @override
  _RecipeTipsScreenState createState() => _RecipeTipsScreenState();
}

class _RecipeTipsScreenState extends State<RecipeTipsScreen> {
  final String apiKey =
      'f5d282cdf14a463f9c042dff7e58f255'; // Inserisci la tua chiave API
  List<Map<String, dynamic>> recipes = [];

  @override
  void initState() {
    super.initState();
    fetchRecipes(widget.ingredientNames); // Usa i parametri forniti
  }

  Future<void> fetchRecipes(List<String> ingredientNames) async {
    try {
      // Verifica che la lista degli ingredienti non sia vuota
      if (ingredientNames.isNotEmpty) {
        final ingredients = ingredientNames.join(',');
        final url =
            'https://api.spoonacular.com/recipes/findByIngredients?ingredients=$ingredients&number=10&apiKey=$apiKey';

        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          setState(() {
            recipes = data.map((e) => e as Map<String, dynamic>).toList();
          });
        } else {
          print('Errore API: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Errore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            AppLocalizations.of(context)!.recipeTips), // Traduci se necessario
      ),
      body: recipes.isEmpty
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary,
                          blurRadius: 2,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    height: 400,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 150,
                          child: recipe['image']?.isNotEmpty == true
                              ? Image.network(
                            recipe['image']!,
                            width: double.infinity,
                            height: 150,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.broken_image, size: 50),
                              );
                            },
                          )
                              : const Center(
                            child: Icon(Icons.no_photography, size: 50),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                          child: Text(
                            recipe['title']?.toString() ?? 'Unknown Recipe',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
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
