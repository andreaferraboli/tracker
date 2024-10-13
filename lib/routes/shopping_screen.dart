import 'package:flutter/material.dart';
import 'supermarket_screen.dart'; // Assicurati di avere questa importazione

class ShoppingScreen extends StatelessWidget {
  const ShoppingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fare la spesa'),
      ),
      body: GridView.count(
        crossAxisCount: 2, // Numero di colonne
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSupermarketCard(context, 'Eurospin',
              'assets/images/Eurospin.png'), // Assicurati di avere l'immagine nel percorso corretto
          _buildSupermarketCard(context, 'Lidl', 'assets/images/Lidl.png'),
          _buildSupermarketCard(
              context, 'Esselunga', 'assets/images/Esselunga.png'),
          _buildAddSupermarketCard(context),
        ],
      ),
    );
  }

  Widget _buildSupermarketCard(
      BuildContext context, String name, String imagePath) {
    return GestureDetector(
      onTap: () => _navigateToSupermarket(context, name),
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

  Widget _buildAddSupermarketCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Qui puoi implementare la logica per aggiungere un supermercato
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
  void _navigateToSupermarket(BuildContext context, String supermarketName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SupermarketScreen(supermarketName: supermarketName),
      ),
    );
  }
}
