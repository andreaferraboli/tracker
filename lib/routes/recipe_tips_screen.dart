import 'dart:io'; // Aggiunto per rilevare la piattaforma
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import per multilingua
import 'package:flutter/cupertino.dart'; // Aggiunto per i widget Cupertino
import 'package:http/http.dart' as http;
import 'package:tracker/services/toast_notifier.dart';

class RecipeTipsScreen extends StatefulWidget {
  final List<String> ingredientNames;

  // Costruttore per passare i nomi degli ingredienti
  const RecipeTipsScreen({super.key, required this.ingredientNames});

  @override
  RecipeTipsScreenState createState() => RecipeTipsScreenState();
}

class RecipeTipsScreenState extends State<RecipeTipsScreen> {
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
          ToastNotifier.showError('Errore API: ${response.statusCode}');
        }
      }
    } catch (e) {
      ToastNotifier.showError('Errore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: Text(AppLocalizations.of(context)!.recipeTips),
            ),
            child: _buildBody(),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!
                  .recipeTips), // Traduci se necessario
            ),
            body: _buildBody(),
          );
  }

  Widget _buildBody() {
    return recipes.isEmpty
        ? Center(
            child: Platform.isIOS
                ? const CupertinoActivityIndicator()
                : const CircularProgressIndicator(),
          )
        : GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return GestureDetector(
                onTap: () => _showRecipeDetail(recipe),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: SizedBox(
                    width: 150, // Larghezza fissa della card
                    height: 200, // Altezza fissa della card
                    child: Column(
                      children: [
                        Expanded(
                          flex: 2, // Prende 3/5 dello spazio disponibile
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              image: recipe['image']?.isNotEmpty == true
                                  ? DecorationImage(
                                      image: NetworkImage(recipe['image']!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: recipe['image']?.isNotEmpty != true
                                ? const Center(
                                    child: Icon(Icons.no_photography, size: 50),
                                  )
                                : null,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              recipe['title']?.toString() ?? 'Unknown Recipe',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }

  void _showRecipeDetail(Map<String, dynamic> recipe) {
    // Implementare la logica per mostrare i dettagli della ricetta
  }
}
