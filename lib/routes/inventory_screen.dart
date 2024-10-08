 import 'package:flutter/material.dart';
// Schermata per vedere l'inventario
class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vedere inventario'),
      ),
      body: const Center(
        child: Text('Schermata per vedere l\'inventario'),
      ),
    );
  }
}