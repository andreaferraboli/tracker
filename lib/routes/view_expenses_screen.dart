import 'package:flutter/material.dart';

class ViewExpensesScreen extends StatelessWidget {
  const ViewExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualizzare spese'),
      ),
      body: const Center(
        child: Text('Schermata per visualizzare le spese precedenti'),
      ),
    );
  }
}
