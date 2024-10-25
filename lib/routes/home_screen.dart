import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback toggleTheme;
  final User? user;

  const HomeScreen({super.key, required this.toggleTheme, this.user});

  //init dove stampo a console user

  @override
  Widget build(BuildContext context) {
    final shoppingColor = Theme.of(context).brightness == Brightness.light
        ? const Color.fromARGB(255, 34, 65, 98)
        : const Color.fromARGB(255, 41, 36, 36);
    final addMealColor = Theme.of(context).brightness == Brightness.light
        ? const Color.fromARGB(255, 97, 3, 3)
        : const Color.fromARGB(255, 97, 3, 3);
    final viewExpensesColor = Theme.of(context).brightness == Brightness.light
        ? const Color.fromARGB(255, 89, 100, 117)
        : const Color.fromARGB(255, 100, 100, 100);
    final inventoryColor = Theme.of(context).brightness == Brightness.light
        ? const Color.fromARGB(255, 0, 126, 167)
        : const Color.fromARGB(255, 150, 150, 150);
    final viewMealsColor = Theme.of(context).brightness == Brightness.light
        ? const Color.fromARGB(255, 45, 49, 66)
        : const Color.fromARGB(255, 50, 50, 50);
    final recipeTipsColor = Theme.of(context).brightness == Brightness.light
        ? const Color.fromARGB(255, 66, 12, 20)
        : const Color.fromARGB(255, 66, 12, 20);

    return Scaffold(
      appBar: AppBar(
        title: Text('Home',
            style: TextStyle(
                color: Theme.of(context).appBarTheme.titleTextStyle?.color)),
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
        // After
        actions: [
          if (user == null)
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "accedi/registrati",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.login),
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                ),
              ],
            )
          else
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    user!.displayName ?? '',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () {
                    Navigator.pushNamed(context, '/user');
                  },
                ),
              ],
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
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                FirebaseAuth.instance.signOut(); // Effettua il logout
                Navigator.pop(context); // Chiude il drawer
              },
            ),
          ],
        ),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        childAspectRatio:
            0.8, // Regola l'aspetto dei pulsanti per occupare più spazio
        // Definisce due pulsanti per riga
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: <Widget>[
          _buildMenuButton(context, 'Fare la spesa', Icons.shopping_cart,
              '/shopping', shoppingColor),
          _buildMenuButton(context, 'Inserire un pasto', Icons.restaurant,
              '/addMeal', addMealColor),
          _buildMenuButton(context, 'Visualizzare spese', Icons.receipt_long,
              '/viewExpenses', viewExpensesColor),
          _buildMenuButton(context, 'Vedere inventario', Icons.inventory,
              '/inventory', inventoryColor),
          _buildMenuButton(context, 'Visualizzare pasti', Icons.fastfood,
              '/viewMeals', viewMealsColor),
          _buildMenuButton(context, 'Suggerisci ricette',
              Icons.food_bank_outlined, '/recipeTips', recipeTipsColor),
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
