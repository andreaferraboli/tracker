import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback toggleTheme;
  final User? user;

  const HomeScreen({super.key, required this.toggleTheme, this.user});

  //init dove stampo a console user

  @override
  Widget build(BuildContext context) {
    print(user);
    print("user_id" + user!.uid);
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
        actions: [
          if (user == null)
            IconButton(
              icon: const Icon(Icons.login),
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                user!.email ?? '',
                style: const TextStyle(fontSize: 16),
              ),
            ),
        ],
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
          _buildMenuButton(context, 'Fare la spesa', Icons.shopping_cart,
              '/shopping', const Color.fromARGB(255, 34, 83, 9)),
          _buildMenuButton(context, 'Inserire un pasto', Icons.restaurant,
              '/addMeal', const Color.fromARGB(255, 154, 135, 0)),
          _buildMenuButton(context, 'Visualizzare spese', Icons.receipt_long,
              '/viewExpenses', const Color.fromARGB(255, 97, 3, 3)),
          _buildMenuButton(context, 'Vedere inventario', Icons.inventory,
              '/inventory', const Color.fromARGB(255, 34, 65, 98)),
          _buildMenuButton(context, 'Visualizzare pasti', Icons.fastfood,
              '/viewMeals', const Color.fromARGB(255, 94, 34, 98)),
          _buildMenuButton(
              context,
              'Suggerisci ricette',
              Icons.food_bank_outlined,
              '/recipeTips',
              const Color.fromARGB(255, 182, 81, 0)),
        ],
      ),
    );
  }

  // Funzione per creare un pulsante nel grid
  Widget _buildMenuButton(BuildContext context, String label, IconData icon,
      String? route, Color color) {
    return ElevatedButton(
      onPressed: route != null
          ? () {
              Navigator.pushNamed(context, route);
            }
          : null, // Pulsante disabilitato se la route è null
      style: ElevatedButton.styleFrom(
        backgroundColor: color, // Colore del pulsante
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
