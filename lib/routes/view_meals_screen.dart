import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart' as pie_chart;
import 'package:tracker/l10n/app_localizations.dart';
import 'package:tracker/services/app_colors.dart';
import 'package:tracker/services/toast_notifier.dart';

import '../models/custom_barchart.dart';
import '../models/meal.dart';
import '../models/period_selector.dart';
import 'meal_details_screen.dart';

class ViewMealsScreen extends StatefulWidget {
  const ViewMealsScreen({super.key});

  @override
  _ViewMealsScreenState createState() => _ViewMealsScreenState();
}

class _ViewMealsScreenState extends State<ViewMealsScreen> {
  String selectedPeriod = 'week';
  String selectedMealType = 'All';
  String selectedMacronutrient = 'Energy';
  DateTime currentDate = DateTime.now();

  // Liste di opzioni per tipo di pasto e macronutrienti
  final List<String> mealTypes = [
    'All',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snack'
  ];
  final List<String> macronutrients = [
    "Energy",
    "Fats",
    "Proteins",
    "Carbohydrates",
    "Sugars",
    "Fiber",
    "Saturated Fats",
    "Monounsaturated Fats",
    "Polyunsaturated Fats",
    "Cholesterol",
    "Sodium"
  ];

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
      final endOfWeek = startOfWeek.add(const Duration(days: 6));

      filteredMeals = meals.where((meal) {
        final mealDate = dateFormat.parse(meal.date);
        var subtract = dateFormat.parse(
            dateFormat.format(startOfWeek.subtract(const Duration(days: 1))));
        var after = mealDate.isAfter(subtract);
        var add = dateFormat
            .parse(dateFormat.format(endOfWeek.add(const Duration(days: 1))));
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

  Map<String, double> _prepareBarChartData(List<Meal> filteredMeals) {
    Map<String, double> periodData = {};
    var localizations = AppLocalizations.of(context);
    final months = [
      localizations!.jan,
      localizations.feb,
      localizations.mar,
      localizations.apr,
      localizations.may,
      localizations.jun,
      localizations.jul,
      localizations.aug,
      localizations.sep,
      localizations.oct,
      localizations.nov,
      localizations.dec
    ];

    switch (selectedPeriod) {
      case 'week':
        for (int i = 0; i < 7; i++) {
          DateTime day =
              currentDate.subtract(Duration(days: currentDate.weekday - 1 - i));
          String dayLabel = '${day.day}-${day.month}';
          periodData[dayLabel] = 0.0;
        }
        break;

      case 'month':
        for (int i = 1; i <= 4; i++) {
          periodData['${localizations.week} $i'] = 0.0;
        }
        break;

      case 'year':
        for (int i = 0; i < 12; i++) {
          periodData[months[i]] = 0.0;
        }
        break;
    }

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
          key = '${localizations.week} $weekOfMonth';
          break;
        case 'year':
          int month = DateTime.parse(meal.date).month - 1;
          key = months[month];
          break;
        default:
          key = '';
      }

      if (key.isNotEmpty) {
        periodData[key] = (periodData[key] ?? 0) + meal.totalExpense;
      }
    }

    return periodData;
  }

  Map<String, double> _prepareMacronutrientData(List<Meal> filteredMeals) {
    Map<String, double> macronutrientData = {};
    var localizations = AppLocalizations.of(context);
    final months = [
      localizations!.jan,
      localizations.feb,
      localizations.mar,
      localizations.apr,
      localizations.may,
      localizations.jun,
      localizations.jul,
      localizations.aug,
      localizations.sep,
      localizations.oct,
      localizations.nov,
      localizations.dec
    ];

    switch (selectedPeriod) {
      case 'week':
        for (int i = 0; i < 7; i++) {
          DateTime day =
              currentDate.subtract(Duration(days: currentDate.weekday - 1 - i));
          String dayLabel = '${day.day}-${day.month}';
          macronutrientData[dayLabel] = 0.0;
        }
        break;

      case 'month':
        for (int i = 1; i <= 4; i++) {
          macronutrientData['${localizations.week} $i'] = 0.0;
        }
        break;

      case 'year':
        for (int i = 0; i < 12; i++) {
          macronutrientData[months[i]] = 0.0;
        }
        break;
    }

    Map<String, int> counts = {};
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
          key = '${localizations.week} $weekOfMonth';
          break;
        case 'year':
          key = months[mealDate.month - 1];
          break;
        default:
          key = '';
      }

      if (key.isNotEmpty) {
        macronutrientData[key] = (macronutrientData[key] ?? 0) +
            (meal.macronutrients[selectedMacronutrient] ?? 0);
        counts[key] = (counts[key] ?? 0) + 1;
      }
    }

    if (selectedPeriod == 'month' || selectedPeriod == 'year') {
      macronutrientData.updateAll((key, value) => value / (counts[key] ?? 1));
    }

    return macronutrientData;
  }

  // Funzione per calcolare il totale speso per ogni tipo di pasto
  Map<String, double> _calculateMealTypeExpenses(List<Meal> filteredMeals) {
    final Map<String, double> mealTypeData = {};
    for (var meal in filteredMeals) {
      mealTypeData[meal.mealType] =
          (mealTypeData[meal.mealType] ?? 0) + meal.totalExpense;
    }
    return mealTypeData.map((type, total) {
      return MapEntry(
          '${AppLocalizations.of(context)!.mealString(type)} - €${total.toStringAsFixed(2)}',
          total);
    });
  }

  List<Meal> _filterMeals(List<Meal> meals) {
    List<Meal> filteredMeals = _filterMealsByPeriod(meals);

    if (selectedMealType != 'All') {
      filteredMeals = filteredMeals
          .where((meal) => meal.mealType == selectedMealType)
          .toList();
    }

    return filteredMeals;
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
      ToastNotifier.showError('Errore durante il recupero dei pasti: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = [
      Theme.of(context).brightness == Brightness.light
          ? AppColors.shoppingLight
          : AppColors.shoppingDark,
      Theme.of(context).brightness == Brightness.light
          ? AppColors.addMealLight
          : AppColors.addMealDark,
      Theme.of(context).brightness == Brightness.light
          ? AppColors.viewExpensesLight
          : AppColors.viewExpensesDark,
      Theme.of(context).brightness == Brightness.light
          ? AppColors.inventoryLight
          : AppColors.inventoryDark,
      Theme.of(context).brightness == Brightness.light
          ? AppColors.viewMealsLight
          : AppColors.viewMealsDark,
      Theme.of(context).brightness == Brightness.light
          ? AppColors.recipeTipsLight
          : AppColors.recipeTipsDark,
    ];
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.viewMeals)),
      body: FutureBuilder<List<Meal>>(
        future: _fetchMeals(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
                    '${AppLocalizations.of(context)!.error}: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text(AppLocalizations.of(context)!.noMealsFound));
          } else {
            final meals = snapshot.data!;
            final filteredMeals = _filterMeals(meals);
            filteredMeals.sort((a, b) {
              final aDate = DateFormat('dd-MM-yyyy').parse(a.date);
              final bDate = DateFormat('dd-MM-yyyy').parse(b.date);
              return aDate.compareTo(bDate);
            });
            if (filteredMeals.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppLocalizations.of(context)!.noMealsForPeriod),
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
                                ? '${AppLocalizations.of(context)!.weekOf} ${DateFormat('dd/MM/yyyy').format(currentDate.subtract(Duration(days: currentDate.weekday - 1)))}'
                                : selectedPeriod == 'month'
                                    ? '${AppLocalizations.of(context)!.monthOf} ${DateFormat('MMMM yyyy', 'it_IT').format(currentDate)}'
                                    : '${currentDate.year}',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // Dropdown per il tipo di pasto
                              DropdownButton<String>(
                                value: selectedMealType,
                                items: mealTypes.map((String type) {
                                  return DropdownMenuItem<String>(
                                    value: type,
                                    child: Text(type),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedMealType = value!;
                                  });
                                },
                              ),
                              // Dropdown per il macronutriente
                              DropdownButton<String>(
                                value: selectedMacronutrient,
                                items: macronutrients.map((String nutrient) {
                                  return DropdownMenuItem<String>(
                                    value: nutrient,
                                    child: Text(nutrient),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedMacronutrient = value!;
                                  });
                                },
                              ),
                            ],
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
            final macronutrientData = _prepareMacronutrientData(filteredMeals);

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
                  Text(
                    '${selectedPeriod == 'week' ? '${AppLocalizations.of(context)!.weekOf} ${DateFormat('dd/MM/yyyy').format(currentDate.subtract(Duration(days: currentDate.weekday - 1)))}' : selectedPeriod == 'month' ? '${AppLocalizations.of(context)!.monthOf} ${DateFormat('MMMM yyyy', 'it_IT').format(currentDate)}' : '${currentDate.year}'} : ${filteredMeals.map((meal) => meal.totalExpense).reduce((value, element) => value + element).toStringAsFixed(2)} €',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Dropdown per il tipo di pasto
                      DropdownButton<String>(
                        value: selectedMealType,
                        items: mealTypes.map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(
                                AppLocalizations.of(context)!.mealString(type)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedMealType = value!;
                          });
                        },
                      ),
                      // Dropdown per il macronutriente
                      DropdownButton<String>(
                        value: selectedMacronutrient,
                        items: macronutrients.map((String nutrient) {
                          return DropdownMenuItem<String>(
                            value: nutrient,
                            child: Text(AppLocalizations.of(context)!
                                .getNutrientString(nutrient)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedMacronutrient = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  // Grafico a barre per le spese giornaliere
                  SizedBox(
                    height: 150,
                    child: CustomBarChart(periodData: periodData),
                  ),
                  const SizedBox(height: 8),
                  // Grafico a barre per le calorie giornaliere
                  SizedBox(
                    height: 150,
                    child: CustomBarChart(periodData: macronutrientData),
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
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: ListTile(
                              title: Text(
                                '${AppLocalizations.of(context)!.mealString(meal.mealType)} - €${meal.totalExpense.toStringAsFixed(2)}',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary),
                              ),
                              trailing: Text(
                                meal.date,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MealDetailScreen(meal: meal),
                                  ),
                                ).then((returnedMeal) {
                                  if (returnedMeal != null) {
                                    // Chiama la funzione desiderata, ad esempio updateMeal
                                    _fetchMeals().then((meals) {
                                      setState(() {
                                        filteredMeals.clear();
                                        filteredMeals
                                            .addAll(_filterMeals(meals));
                                      });
                                    });
                                  }
                                });
                              },
                            ),
                          ),
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
