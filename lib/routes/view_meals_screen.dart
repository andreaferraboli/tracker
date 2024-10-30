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
    int rangeDays = 0;

    switch (selectedPeriod) {
      case 'week':
        startDate = now.subtract(const Duration(days: 6)); // Ultimi 7 giorni
        break;
      case 'month':
        startDate = now.subtract(const Duration(days: 28)); // Ultime 4 settimane
        break;
      case 'year':
        startDate = DateTime(now.year - 1, now.month, now.day); // Ultimi 12 mesi
        break;
      default:
        return meals; // Restituisce tutti i pasti se il periodo non è valido
    }

    return meals.where((meal) {
      DateTime mealDate = DateTime.parse(meal.date); // Modifica in base al tuo formato data
      return mealDate.isAfter(startDate) && mealDate.isBefore(now);
    }).toList();
  }





  // Funzione per preparare i dati del grafico a barre con i costi giornalieri
  Map<String, double> _prepareBarChartData(List<Meal> filteredMeals) {
    Map<String, double> periodData = {};
    const months = ["Gen", "Feb", "Mar", "Apr", "Mag", "Giu", "Lug", "Ago", "Set", "Ott", "Nov", "Dic"];
    switch (selectedPeriod) {
      case 'week':
      // Aggiungi i 7 giorni della settimana con valore iniziale 0
        for (int i = 0; i < 7; i++) {
          DateTime day = currentDate.subtract(Duration(days: currentDate.weekday - 1 - i));
          String dayLabel = '${day.day}-${day.month}';
          periodData[dayLabel] = 0.0;
        }
        break;

      case 'month':
      // Aggiungi le 4 settimane con valore iniziale 0
        for (int i = 1; i <= 4; i++) {
          periodData['Settimana $i'] = 0.0;
        }
        break;

      case 'year':
      // Aggiungi i 12 mesi con valore iniziale 0

        for (int i = 0; i < 12; i++) {
          periodData[months[i]] = 0.0;
        }
        break;
    }

    // Aggiorna il valore di `periodData` con le spese effettive
    for (Meal meal in filteredMeals) {
      String key;
      switch (selectedPeriod) {
        case 'week':
          DateTime mealDate = DateTime.parse(meal.date);
          key = '${mealDate.day}-${mealDate.month}';
          break;
        case 'month':
          int weekOfMonth = (DateTime.parse(meal.date).day - 1) ~/ 7 + 1;
          key = 'Settimana $weekOfMonth';
          break;
        case 'year':
          int month = DateTime.parse(meal.date).month - 1;
          key = months[month];
          break;
        default:
          key = '';
      }

      // Aggiorna solo se `key` è valida
      if (key.isNotEmpty) {
        periodData[key] = (periodData[key] ?? 0) + meal.totalExpense;
      }
    }

    return periodData;
  }
  Map<String, double> _prepareCaloriesData(List<Meal> filteredMeals) {
    Map<String, double> caloriesData = {};
    const months = ["Gen", "Feb", "Mar", "Apr", "Mag", "Giu", "Lug", "Ago", "Set", "Ott", "Nov", "Dic"];

    switch (selectedPeriod) {
      case 'week':
      // Aggiungi i 7 giorni della settimana con valore iniziale 0 kcal
        for (int i = 0; i < 7; i++) {
          DateTime day = currentDate.subtract(Duration(days: currentDate.weekday - 1 - i));
          String dayLabel = '${day.day}-${day.month}';
          caloriesData[dayLabel] = 0.0;
        }
        break;

      case 'month':
      // Aggiungi le 4 settimane del mese con valore iniziale 0 kcal
        for (int i = 1; i <= 4; i++) {
          caloriesData['Settimana $i'] = 0.0;
        }
        break;

      case 'year':
      // Aggiungi i 12 mesi con valore iniziale 0 kcal
        for (int i = 0; i < 12; i++) {
          caloriesData[months[i]] = 0.0;
        }
        break;
    }

    // Calcola le kilocalorie effettive per ogni periodo
    Map<String, int> counts = {}; // Mappa per tenere conto del numero di pasti per calcolare le medie
    for (Meal meal in filteredMeals) {
      String key;
      DateTime mealDate = DateTime.parse(meal.date);

      switch (selectedPeriod) {
        case 'week':
          key = '${mealDate.day}-${mealDate.month}';
          break;
        case 'month':
          int weekOfMonth = (mealDate.day - 1) ~/ 7 + 1;
          key = 'Settimana $weekOfMonth';
          break;
        case 'year':
          key = months[mealDate.month - 1];
          break;
        default:
          key = '';
      }

      if (key.isNotEmpty) {
        // Somma le calorie
        caloriesData[key] = (caloriesData[key] ?? 0) + meal.totalCalories;
        counts[key] = (counts[key] ?? 0) + 1;
      }
    }

    // Se necessario, calcola la media settimanale o mensile
    if (selectedPeriod == 'month' || selectedPeriod == 'year') {
      caloriesData.updateAll((key, value) => value / (counts[key] ?? 1));
    }

    return caloriesData;
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
            final caloriesData = _prepareCaloriesData(filteredMeals);

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
                  const SizedBox(height: 8),
                  // Grafico a barre per le calorie giornaliere
                  Container(
                    height: 150,
                    child: CustomBarChart(periodData: caloriesData),
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

