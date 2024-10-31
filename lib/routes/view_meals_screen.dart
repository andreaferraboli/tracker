import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
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
          currentDate = DateTime(
              currentDate.year, currentDate.month + delta, currentDate.day);
          break;
        case 'year':
          currentDate = DateTime(
              currentDate.year + delta, currentDate.month, currentDate.day);
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
    List<Meal> filteredMeals = [];
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

    if (selectedPeriod == 'week') {
      final startOfWeek =
          currentDate.subtract(Duration(days: currentDate.weekday - 1));
      final endOfWeek = startOfWeek.add(Duration(days: 6));

      filteredMeals = meals.where((meal) {
        final mealDate = dateFormat.parse(meal.date);
        var subtract = dateFormat
            .parse(dateFormat.format(startOfWeek.subtract(Duration(days: 1))));
        var after = mealDate.isAfter(subtract);
        var add = dateFormat
            .parse(dateFormat.format(endOfWeek.add(Duration(days: 1))));
        var before = mealDate.isBefore(add);
        return after && before;
      }).toList();
    } else if (selectedPeriod == 'month') {
      filteredMeals = meals.where((meal) {
        final mealDate = dateFormat.parse(meal.date);
        return mealDate.month == currentDate.month &&
            mealDate.year == currentDate.year;
      }).toList();
    } else if (selectedPeriod == 'year') {
      filteredMeals = meals.where((meal) {
        final mealDate = dateFormat.parse(meal.date);
        return mealDate.year == currentDate.year;
      }).toList();
    } else {
      // Optionally handle cases where `selectedPeriod` doesn't match known periods
      filteredMeals = meals; // or return an empty list if desired
    }

    return filteredMeals;
  }

  // Funzione per preparare i dati del grafico a barre con i costi giornalieri
  Map<String, double> _prepareBarChartData(List<Meal> filteredMeals) {
    Map<String, double> periodData = {};
    const months = [
      "Gen",
      "Feb",
      "Mar",
      "Apr",
      "Mag",
      "Giu",
      "Lug",
      "Ago",
      "Set",
      "Ott",
      "Nov",
      "Dic"
    ];
    switch (selectedPeriod) {
      case 'week':
        // Aggiungi i 7 giorni della settimana con valore iniziale 0
        for (int i = 0; i < 7; i++) {
          DateTime day =
              currentDate.subtract(Duration(days: currentDate.weekday - 1 - i));
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
          weekOfMonth = weekOfMonth > 4 ? 4 : weekOfMonth;
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
    const months = [
      "Gen",
      "Feb",
      "Mar",
      "Apr",
      "Mag",
      "Giu",
      "Lug",
      "Ago",
      "Set",
      "Ott",
      "Nov",
      "Dic"
    ];

    switch (selectedPeriod) {
      case 'week':
        // Aggiungi i 7 giorni della settimana con valore iniziale 0 kcal
        for (int i = 0; i < 7; i++) {
          DateTime day =
              currentDate.subtract(Duration(days: currentDate.weekday - 1 - i));
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
    Map<String, int> counts =
        {}; // Mappa per tenere conto del numero di pasti per calcolare le medie
    for (Meal meal in filteredMeals) {
      String key;
      DateTime mealDate = DateTime.parse(meal.date);

      switch (selectedPeriod) {
        case 'week':
          key = '${mealDate.day}-${mealDate.month}';
          break;
        case 'month':
          int weekOfMonth = (mealDate.day - 1) ~/ 7 + 1;
          weekOfMonth = weekOfMonth > 4 ? 4 : weekOfMonth;
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
      mealTypeData[meal.mealType] =
          (mealTypeData[meal.mealType] ?? 0) + meal.totalExpense;
    }
    return mealTypeData.map((type, total) {
      return MapEntry('$type - €${total.toStringAsFixed(2)}', total);
    });
  }

  Future<List<Meal>> _fetchMeals() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final mealsDocRef =
          FirebaseFirestore.instance.collection('meals').doc(userId);
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
    final List<Color> colors = [
      Theme.of(context).brightness == Brightness.light
          ? const Color.fromARGB(255, 34, 65, 98)
          : const Color.fromARGB(255, 41, 36, 36),
      Theme.of(context).brightness == Brightness.light
          ? const Color.fromARGB(255, 97, 3, 3)
          : const Color.fromARGB(255, 97, 3, 3),
      Theme.of(context).brightness == Brightness.light
          ? const Color.fromARGB(255, 89, 100, 117)
          : const Color.fromARGB(255, 100, 100, 100),
      Theme.of(context).brightness == Brightness.light
          ? const Color.fromARGB(255, 0, 126, 167)
          : const Color.fromARGB(255, 150, 150, 150),
      Theme.of(context).brightness == Brightness.light
          ? const Color.fromARGB(255, 45, 49, 66)
          : const Color.fromARGB(255, 50, 50, 50),
      Theme.of(context).brightness == Brightness.light
          ? const Color.fromARGB(255, 66, 12, 20)
          : const Color.fromARGB(255, 66, 12, 20),
    ];
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
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                        'Nessun pasto trovata per il periodo selezionato'),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
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
                          Text(
                            selectedPeriod == 'week'
                                ? 'Settimana del ${DateFormat('dd/MM/yyyy').format(currentDate.subtract(Duration(days: currentDate.weekday - 1)))}'
                                : selectedPeriod == 'month'
                                    ? 'Mese di ${DateFormat('MMMM yyyy', 'it_IT').format(currentDate)}'
                                    : '${currentDate.year}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            final mealTypeData = _calculateMealTypeExpenses(filteredMeals);
            final periodData = _prepareBarChartData(filteredMeals);
            //todo::fix questo bug non ha i pasti giusti
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
                          title: Text(
                              '${meal.mealType} - €${meal.totalExpense.toStringAsFixed(2)}'),
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
