import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:tracker/routes/auth.dart';

class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text("Totale 60 €"),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.login),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AuthPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Sezione del grafico
            Expanded(
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 40,
                  sections: showingSections(),
                ),
              ),
            ),
            // Lista delle spese
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  buildExpenseTile('Famiglia', '50 €', 56, Colors.red),
                  buildExpenseTile('Alimentari', '30 €', 33, Colors.blue),
                  buildExpenseTile('Attività fisica', '10 €', 11, Colors.green),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return [
      PieChartSectionData(
        color: Colors.red,
        value: 56,
        title: '56%',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        color: Colors.blue,
        value: 33,
        title: '33%',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        color: Colors.green,
        value: 11,
        title: '11%',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ];
  }

  Widget buildExpenseTile(String category, String amount, int percentage, Color color) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color,
        child: Text(
          '$percentage%',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(category),
      trailing: Text(amount),
    );
  }
}
