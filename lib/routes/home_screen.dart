 import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback toggleTheme;

  HomeScreen({super.key, required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu), // Icona burger menu
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: const Text('Cambia tema'),
              onTap: () {
                toggleTheme(); // Chiama la funzione per cambiare il tema
                Navigator.pop(context); // Chiude il drawer
              },
            ),
          ],
        ),
      ),
      body: GridView.count(
        crossAxisCount: 2, // Definisce due pulsanti per riga
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: <Widget>[
          _buildMenuButton(context, 'Fare la spesa', Icons.shopping_cart, '/shopping'),
          _buildMenuButton(context, 'Inserire un pasto', Icons.restaurant, '/addMeal'),
          _buildMenuButton(context, 'Visualizzare spese', Icons.receipt_long, '/viewExpenses'),
          _buildMenuButton(context, 'Vedere inventario', Icons.inventory, '/inventory'),
          _buildMenuButton(context, 'Visualizzare pasti', Icons.fastfood, '/viewMeals'),
          _buildMenuButton(context, 'Vuoto', Icons.block, null),
        ],
      ),
    );
  }

  // Funzione per creare un pulsante nel grid
  Widget _buildMenuButton(BuildContext context, String label, IconData icon, String? route) {
    return ElevatedButton(
      onPressed: route != null
          ? () {
              Navigator.pushNamed(context, route);
            }
          : null, // Pulsante disabilitato se la route è null
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40),
          const SizedBox(height: 10),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
