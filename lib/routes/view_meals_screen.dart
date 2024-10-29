import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pie_chart/pie_chart.dart' as pie_chart;

import '../models/custom_barchart.dart';
import '../models/meal.dart';
import '../models/period_selector.dart';

class ViewMealsScreen extends StatefulWidget {
  const ViewMealsScreen({super.key});

  @override
  _ViewMealsScreenState createState() => _ViewMealsScreenState();
}

class _ViewMealsScreenState extends State<ViewMealsScreen> {
  String selectedPeriod = 'week';
  DateTime currentDate = DateTime.now();

  // Cambia il periodo visualizzato
  void _changePeriod(int delta) {
    setState(() {
      switch (selectedPeriod) {
        case 'week':
          currentDate = currentDate.add(Duration(days: 7 * delta));
          break;
        case 'month':
          currentDate = DateTime(currentDate.year, currentDate.month + delta, currentDate.day);
          break;
        case 'year':
          currentDate = DateTime(currentDate.year + delta, currentDate.month, currentDate.day);
          break;
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != currentDate) {
      setState(() {
        currentDate = picked;
      });
    }
  }

  // Funzione per filtrare i pasti in base al periodo
  List<Meal> _filterMealsByPeriod(List<Meal> meals) {
    DateTime now = DateTime.now();
    DateTime startDate;

    switch (selectedPeriod) {
      case 'settimanale':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'mensile':
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case 'annuale':
        startDate = DateTime(now.year - 1, now.month, now.day);
        break;
      default:
        return meals; // Restituisci tutti i pasti se il periodo non è valido
    }

    // Filtra i pasti che rientrano nell'intervallo temporale
    return meals.where((meal) {
      // Converti la stringa `date` in un oggetto DateTime
      List<String> parts = meal.date.split('-');
      DateTime mealDate = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      return mealDate.isAfter(startDate); // Confronta le date
    }).toList();
  }




  // Funzione per preparare i dati del grafico a barre con i costi giornalieri
  Map<String, double> _prepareBarChartData(List<Meal> filteredMeals) {
    Map<String, double> dailyCosts = {};

    for (Meal meal in filteredMeals) {
      String day = '${meal.year}-${meal.month}-${meal.day}';

      if (dailyCosts.containsKey(day)) {
        dailyCosts[day] = dailyCosts[day]! + meal.totalExpense;
      } else {
        dailyCosts[day] = meal.totalExpense;
      }
    }

    return dailyCosts;
  }


  // Funzione per calcolare il totale speso per ogni tipo di pasto
  Map<String, double> _calculateMealTypeExpenses(List<Meal> filteredMeals) {
    final Map<String, double> mealTypeData = {};
    for (var meal in filteredMeals) {
      mealTypeData[meal.mealType] = (mealTypeData[meal.mealType] ?? 0) + meal.totalExpense;
    }
    return mealTypeData.map((type, total) {
      return MapEntry('$type - €${total.toStringAsFixed(2)}', total);
    });
  }

  Future<List<Meal>> _fetchMeals() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final mealsDocRef = FirebaseFirestore.instance.collection('meals').doc(userId);
      final mealsDoc = await mealsDocRef.get();

      if (mealsDoc.data() == null || !mealsDoc.exists) return [];
      return (mealsDoc.data()!['meals'] as List)
          .map((meal) => Meal.fromJson(meal))
          .toList();
    } catch (e) {
      print('Errore durante il recupero dei pasti: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = [Colors.blue, Colors.green, Colors.orange, Colors.red];
    return Scaffold(
      appBar: AppBar(title: const Text('Visualizzare Pasti')),
      body: FutureBuilder<List<Meal>>(
        future: _fetchMeals(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nessun pasto trovato'));
          } else {
            final meals = snapshot.data!;
            final filteredMeals = _filterMealsByPeriod(meals);

            if (filteredMeals.isEmpty) {
              return const Center(child: Text('Nessun pasto trovato per il periodo selezionato'));
            }

            final mealTypeData = _calculateMealTypeExpenses(filteredMeals);
            final periodData = _prepareBarChartData(filteredMeals);

            return SingleChildScrollView(
              child: Column(
                children: [
                  // Selettore del periodo
                  PeriodSelector(
                    selectedPeriod: selectedPeriod,
                    onPeriodChanged: (value) {
                      setState(() {
                        selectedPeriod = value!;
                      });
                    },
                    onPreviousPeriod: () => _changePeriod(-1),
                    onNextPeriod: () => _changePeriod(1),
                    onSelectDate: () => _selectDate(context),
                  ),
                  const SizedBox(height: 8),
                  // Grafico a barre per le spese giornaliere
                  Container(
                    height: 150,
                    child: CustomBarChart(periodData: periodData),
                  ),
                  // Grafico a torta per il totale speso per tipo di pasto
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: pie_chart.PieChart(
                      dataMap: mealTypeData,
                      colorList: colors,
                      chartRadius: MediaQuery.of(context).size.width / 2.2,
                      legendOptions: const pie_chart.LegendOptions(
                        legendPosition: pie_chart.LegendPosition.right,
                      ),
                      chartValuesOptions: const pie_chart.ChartValuesOptions(
                        showChartValuesInPercentage: true,
                        decimalPlaces: 1,
                      ),
                    ),
                  ),
                  // Lista dei pasti
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: filteredMeals.map((meal) {
                        return ListTile(
                          title: Text('${meal.mealType} - €${meal.totalExpense.toStringAsFixed(2)}'),
                          trailing: Text(meal.date),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

