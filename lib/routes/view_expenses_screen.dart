import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart' as pie_chart;
import 'package:tracker/models/expense.dart';
import 'package:tracker/models/product_bought.dart';

class ViewExpensesScreen extends StatefulWidget {
  const ViewExpensesScreen({super.key});

  @override
  _ViewExpensesScreenState createState() => _ViewExpensesScreenState();
}


class _ViewExpensesScreenState extends State<ViewExpensesScreen> {
  String selectedPeriod = 'week'; // default view
  DateTime currentDate = DateTime.now();
  // Funzione per cambiare periodo visualizzato
  void _changePeriod(int delta) {
    setState(() {
      if (selectedPeriod == 'week') {
        currentDate = currentDate.add(Duration(days: 7 * delta));
      } else if (selectedPeriod == 'month') {
        currentDate = DateTime(currentDate.year, currentDate.month + delta, currentDate.day);
      } else if (selectedPeriod == 'year') {
        currentDate = DateTime(currentDate.year + delta, currentDate.month, currentDate.day);
      }
    });
  }

  Map<String, double> _filterExpensesByPeriod(List<Expense> expenses) {
    final Map<String, double> periodData = {};

    if (selectedPeriod == 'week') {
      final startOfWeek = currentDate.subtract(Duration(days: currentDate.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));

      for (var i = 0; i < 7; i++) {
        final day = startOfWeek.add(Duration(days: i));
        final formattedDate = DateFormat('yyyy-MM-dd').format(day);
        periodData[formattedDate] = 0;
      }

      for (var expense in expenses) {
        final expenseDate = DateFormat('dd-MM-yyyy').parse(expense.date);
        if (expenseDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
            expenseDate.isBefore(endOfWeek.add(const Duration(days: 1)))) {
          final formattedDate = DateFormat('yyyy-MM-dd').format(expenseDate);
          periodData[formattedDate] = (periodData[formattedDate] ?? 0) + expense.totalAmount;
        }
      }
    } else if (selectedPeriod == 'month') {
      for (var i = 1; i <= 4; i++) {
        periodData['Settimana $i'] = 0;
      }

      for (var expense in expenses) {
        final expenseDate = DateFormat('dd-MM-yyyy').parse(expense.date);
        if (expenseDate.month == currentDate.month && expenseDate.year == currentDate.year) {
          final weekOfMonth = ((expenseDate.day - 1) ~/ 7) + 1;
          periodData['Settimana $weekOfMonth'] = (periodData['Settimana $weekOfMonth'] ?? 0) + expense.totalAmount;
        }
      }
    } else if (selectedPeriod == 'year') {
      for (var i = 1; i <= 12; i++) {
        periodData[DateFormat.MMMM().format(DateTime(currentDate.year, i))] = 0;
      }

      for (var expense in expenses) {
        final expenseDate = DateFormat('dd-MM-yyyy').parse(expense.date);
        if (expenseDate.year == currentDate.year) {
          final monthName = DateFormat.MMMM().format(expenseDate);
          periodData[monthName] = (periodData[monthName] ?? 0) + expense.totalAmount;
        }
      }
    }
    return periodData;
  }

  // Recupera la lista di spese dal documento dell'utente su Firestore
  Future<List<Expense>> _fetchExpenses() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final expensesDocRef = FirebaseFirestore.instance.collection('expenses').doc(userId);
      final expensesDoc = await expensesDocRef.get();

      if (expensesDoc.data() == null || !expensesDoc.exists) {
        return [];
      }

      final expenses = (expensesDoc.data()!['expenses'] as List)
          .map((expense) => Expense.fromJson(expense))
          .toList();
      return expenses;
    } catch (e) {
      print('Errore durante il recupero delle spese: $e');
      return [];
    }
  }

  // Aggrega le spese per categoria, formattando il nome della categoria con il totale speso
  Map<String, double> _calculateCategoryExpenses(List<Expense> expenses) {
    final Map<String, double> categoryData = {};

    for (var expense in expenses) {
      for (var product in expense.products) {
        if (categoryData.containsKey(product.category)) {
          categoryData[product.category] = categoryData[product.category]! + product.price;
        } else {
          categoryData[product.category] = product.price;
        }
      }
    }

    // Crea una nuova mappa con il nome della categoria e il totale formattati
    final Map<String, double> formattedCategoryData = categoryData.map((category, total) {
      final formattedCategory = '$category - €${total.toStringAsFixed(2)}';
      return MapEntry(formattedCategory, total);
    });

    return formattedCategoryData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualizzare spese'),
      ),
      body: FutureBuilder<List<Expense>>(
        future: _fetchExpenses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nessuna spesa trovata'));
          } else {
            final expenses = snapshot.data!;
            final periodData = _filterExpensesByPeriod(expenses);

            final categoryData = _calculateCategoryExpenses(expenses);

            return Column(
              children: [
                // Grafico a torta per le categorie di spesa
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: pie_chart.PieChart(
                    dataMap: categoryData,
                    chartRadius: MediaQuery.of(context).size.width / 2.2,
                    legendOptions: const pie_chart.LegendOptions(
                      legendPosition: pie_chart.LegendPosition.right,
                      showLegendsInRow: false,
                    ),
                    chartValuesOptions: const pie_chart.ChartValuesOptions(
                      showChartValuesInPercentage: true,
                      decimalPlaces: 1,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => _changePeriod(-1),
                      ),
                      DropdownButton<String>(
                        value: selectedPeriod,
                        items: const [
                          DropdownMenuItem(value: 'week', child: Text('Settimana')),
                          DropdownMenuItem(value: 'month', child: Text('Mese')),
                          DropdownMenuItem(value: 'year', child: Text('Anno')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedPeriod = value!;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () => _changePeriod(1),
                      ),
                    ],
                  ),
                ),
                // Grafico a barre
                Expanded(
                  child: BarChart(
                    BarChartData(
                      barGroups: periodData.entries
                          .map(
                            (entry) => BarChartGroupData(
                          x: periodData.keys.toList().indexOf(entry.key),
                          barRods: [
                            BarChartRodData(toY: entry.value, color: Colors.blue),
                          ],
                        ),
                      )
                          .toList(),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(periodData.keys.toList()[value.toInt()]);
                            },
                          ),
                        ),
                      ),
                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
                const Divider(),
                // Lista di spese
                Expanded(
                  child: ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text('Supermercato: ${expense.supermarket}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Data: ${expense.date}'),
                              Text('Totale: €${expense.totalAmount.toStringAsFixed(2)}'),
                              const SizedBox(height: 5),
                              Text('Prodotti:'),
                              ...expense.products.map((product) => Text(
                                '- ${product.productName} (x${product.quantita}): €${product.price.toStringAsFixed(2)}',
                                style: TextStyle(color: Colors.grey[700]),
                              )),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
