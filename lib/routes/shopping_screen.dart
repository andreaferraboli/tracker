import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Importa le localizzazioni generate
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
        title: Text(AppLocalizations.of(context)!.shoppingTitle), // Traduzione del titolo
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        children: [
          ...selectedSupermarkets.map((name) =>
              _buildSupermarketCard(context, name, 'assets/images/$name.png', ref)),
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
              imagePath,
              height: 80,
              fit: BoxFit.cover,
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
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        AppLocalizations.of(context)!.selectSupermarket, // Traduzione del testo dialogo
                        style: const TextStyle(fontSize: 20),
                      ),
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
                      child: Text(AppLocalizations.of(context)!.close), // Traduzione del pulsante "Chiudi"
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
      child: Card(
        elevation: 4,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add,
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.addSupermarket, // Traduzione per "Aggiungi Supermercato"
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

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
