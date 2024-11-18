import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Per multilingua
import 'package:tracker/routes/recipe_tips_screen.dart';

class FilterRecipesScreen extends StatefulWidget {
  @override
  _FilterRecipesScreenState createState() => _FilterRecipesScreenState();
}

class _FilterRecipesScreenState extends State<FilterRecipesScreen> {
  List<Map<String, dynamic>> products = []; // Contiene i prodotti
  List<String> selectedNames = []; // Contiene i nomi selezionati

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (snapshot.exists) {
        final List<dynamic> productsArray = snapshot['products'] ?? [];
        setState(() {
          products = productsArray
              .where((product) => product['quantityWeightOwned'] > 0)
              .map((product) => product as Map<String, dynamic>)
              .toList();
        });
      }
    } catch (e) {
      print('Errore: $e');
    }
  }

  void toggleSelection(String name) {
    setState(() {
      if (selectedNames.contains(name)) {
        selectedNames.remove(name); // Deseleziona
      } else {
        selectedNames.add(name); // Seleziona
      }
    });
  }

  void navigateToRecipeTips() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeTipsScreen(ingredientNames: selectedNames),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.filterRecipes),
      ),
      body: products.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      AppLocalizations.of(context)!.selectProducts,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,  // Opzionale, per rendere il testo più evidente
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, // 4 elementi per riga
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final isSelected =
                          selectedNames.contains(product['productName']);
                      return GestureDetector(
                        onTap: () => toggleSelection(product['productName']),
                        child: Card(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10), // Aggiungi angoli arrotondati
                          ),
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            // Aggiungi spazio tra immagine e card
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: Image.network(
                                    product['imageUrl'] ?? '',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateToRecipeTips,
        label: Text(AppLocalizations.of(context)!.ok),
        icon: Icon(Icons.check),
      ),
    );
  }
}