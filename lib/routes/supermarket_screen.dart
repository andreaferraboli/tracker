import 'package:flutter/material.dart';

class SupermarketScreen extends StatelessWidget {
  final String supermarketName;

  SupermarketScreen({required this.supermarketName});

  @override
  Widget build(BuildContext context) {
    // Esempio di saldo e prodotti acquistati
    double totalBalance = 100.0; // Esempio di saldo
    List<String> purchasedProducts = ['Pasta', 'Riso', 'Pane']; // Esempio di lista prodotti

    return Scaffold(
      appBar: AppBar(
        title: Text(supermarketName),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Saldo Totale: €$totalBalance',
              style: TextStyle(fontSize: 24),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Funzione per aggiungere un nuovo prodotto
              // Qui puoi implementare una schermata di aggiunta prodotto
            },
            child: Text('Aggiungi Prodotto'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: purchasedProducts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(purchasedProducts[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
