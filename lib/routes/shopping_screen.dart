import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supermarkets.dart';
import 'supermarket_screen.dart';
import '../providers/supermarkets_list_provider.dart';
import '../providers/supermarket_provider.dart';

class ShoppingScreen extends ConsumerWidget {
  const ShoppingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSupermarkets = ref.watch(supermarketsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fare la spesa'),
      ),
      body: GridView.count(
        crossAxisCount: 2, // Numero di colonne
        padding: const EdgeInsets.all(16.0),
        children: [
          ...selectedSupermarkets.map((name) => _buildSupermarketCard(context, name, 'assets/images/$name.png', ref)).toList(),
          _buildAddSupermarketCard(context, ref),
        ],
      ),
    );
  }

  Widget _buildSupermarketCard(BuildContext context, String name, String imagePath, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _navigateToSupermarket(context, name, ref),
      child: Card(
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath, // Carica l'immagine del supermercato
              height: 80, // Altezza dell'immagine
              fit: BoxFit.cover, // Adatta l'immagine nel riquadro
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddSupermarketCard(BuildContext context, WidgetRef ref) {
    final supermarkets = [
      "Coop",
      "Conad",
      "Esselunga",
      "Carrefour",
      "Lidl",
      "Penny Market",
      "Eurospin",
      "Aldi",
      "Simply Market",
      "Auchan",
      "Bennet",
      "Pam",
      "Crai",
      "Selex",
      "MD",
      "Tigre",
      "Eataly"
    ];
    final selectedSupermarkets = ref.watch(supermarketsListProvider);
    final addSupermarketArray = supermarkets.where((element) => !selectedSupermarkets.contains(element)).toList();

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: Container(
                height: 400,
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Seleziona un supermercato', style: TextStyle(fontSize: 20)),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: addSupermarketArray.length,
                        itemBuilder: (context, index) {
                          final name = addSupermarketArray[index];
                          return ListTile(
                            leading: Image.asset('assets/images/$name.png', width: 50, height: 50),
                            title: Text(name),
                            onTap: () {
                              ref.read(supermarketsListProvider.notifier).addSupermarket(name);
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
                    ),
                    TextButton(
                      child: const Text('Chiudi'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: const Card(
        elevation: 4,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                size: 40,
              ),
              SizedBox(height: 8),
              Text(
                'Aggiungi Supermercato',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Naviga alla schermata del supermercato selezionato
  void _navigateToSupermarket(BuildContext context, String supermarketName, WidgetRef ref) {
    ref.read(supermarketProvider.notifier).setSupermarket(supermarketName);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SupermarketScreen(),
      ),
    );
  }
}