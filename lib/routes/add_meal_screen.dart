import 'package:flutter/material.dart';

class AddMealScreen extends StatelessWidget {
  const AddMealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inserire un pasto'),
      ),
      body: const Center(
        child: Text('Schermata per inserire un pasto'),
      ),
    );
  }
}
