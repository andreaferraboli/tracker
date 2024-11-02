import 'package:flutter/material.dart';

// Schermata per vedere l'inventario
class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vedere Inventario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // Numero di colonne
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            const StorageCard(
              icon: Icons.kitchen,
              title: 'Frigorifero',
            ),
            const StorageCard(
              icon: Icons.storage,
              title: 'Dispensa',
            ),
            const StorageCard(
              icon: Icons.ac_unit,
              title: 'Freezer',
            ),
            const StorageCard(
              icon: Icons.restaurant,
              title: 'Altro',
            ),
            AddStorageCard(
              onAddPressed: () {
                // Qui puoi gestire l'aggiunta di una nuova dispensa
                _showAddStorageDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddStorageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Aggiungi Nuova Dispensa"),
          content: TextField(
            decoration: const InputDecoration(hintText: "Nome della dispensa"),
            onSubmitted: (value) {
              // Logica per aggiungere la dispensa
              Navigator.pop(context); // Chiude il dialog dopo l'inserimento
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annulla"),
            ),
            TextButton(
              onPressed: () {
                // Aggiungi logica di salvataggio
                Navigator.pop(context);
              },
              child: const Text("Aggiungi"),
            ),
          ],
        );
      },
    );
  }
}

class StorageCard extends StatelessWidget {
  final IconData icon;
  final String title;

  const StorageCard({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Aggiungi azione quando si clicca sulla card
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class AddStorageCard extends StatelessWidget {
  final VoidCallback onAddPressed;

  const AddStorageCard({super.key, required this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onAddPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              size: 48,
              color: Colors.green,
            ),
            const SizedBox(height: 8),
            const Text(
              'Aggiungi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
