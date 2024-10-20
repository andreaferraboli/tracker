// Schermata per visualizzare i pasti precedenti
import 'package:flutter/material.dart';

class ViewMealsScreen extends StatelessWidget {
  const ViewMealsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualizzare pasti'),
      ),
      body: const Center(
        child: Text('Schermata per visualizzare i pasti precedenti'),
      ),
    );
  }
}
