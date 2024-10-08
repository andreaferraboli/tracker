import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ExpenseScreen extends StatelessWidget {
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
            SizedBox(height: 20),
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
        child: Icon(Icons.add),
        backgroundColor: Colors.amber,
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
        titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        color: Colors.blue,
        value: 33,
        title: '33%',
        radius: 50,
        titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        color: Colors.green,
        value: 11,
        title: '11%',
        radius: 50,
        titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ];
  }

  Widget buildExpenseTile(String category, String amount, int percentage, Color color) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color,
        child: Text(
          '${percentage}%',
          style: TextStyle(color: Colors.white),
        ),
      ),
      title: Text(category),
      trailing: Text(amount),
    );
  }
}
