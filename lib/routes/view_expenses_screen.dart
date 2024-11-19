import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart' as pie_chart;
import 'package:tracker/l10n/app_localizations.dart';
import 'package:tracker/models/custom_barchart.dart';
import 'package:tracker/models/expense.dart';
import 'package:tracker/routes/expense_detail_screen.dart';
import 'package:tracker/services/app_colors.dart';
import 'package:tracker/services/toast_notifier.dart';

import '../models/period_selector.dart';

class ViewExpensesScreen extends StatefulWidget {
  const ViewExpensesScreen({super.key});

  @override
  _ViewExpensesScreenState createState() => _ViewExpensesScreenState();
}

class _ViewExpensesScreenState extends State<ViewExpensesScreen> {
  String selectedPeriod = 'week';

  DateTime currentDate = DateTime.now();

  // Cambia periodo visualizzato
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

  // Filtra le spese in base al periodo selezionato
  List<Expense> _filterExpensesByPeriod(List<Expense> expenses) {
    List<Expense> filteredExpenses = [];

    if (selectedPeriod == 'week') {
      final startOfWeek = DateTime(currentDate.year, currentDate.month,
          currentDate.day - (currentDate.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 7));

      filteredExpenses = expenses.where((expense) {
        final expenseDate = DateFormat('dd-MM-yyyy').parse(expense.date);
        final isAfterStart =
            expenseDate.isAfter(startOfWeek.subtract(const Duration(days: 1)));
        final isBeforeEnd = expenseDate.isBefore(endOfWeek);
        return isAfterStart && isBeforeEnd;
      }).toList();
    } else if (selectedPeriod == 'month') {
      filteredExpenses = expenses.where((expense) {
        final expenseDate = DateFormat('dd-MM-yyyy').parse(expense.date);
        return expenseDate.month == currentDate.month &&
            expenseDate.year == currentDate.year;
      }).toList();
    } else if (selectedPeriod == 'year') {
      filteredExpenses = expenses.where((expense) {
        final expenseDate = DateFormat('dd-MM-yyyy').parse(expense.date);
        return expenseDate.year == currentDate.year;
      }).toList();
    }

    return filteredExpenses;
  }

  // Aggrega le spese per categoria nel periodo filtrato
  Map<String, double> _calculateCategoryExpenses(
      List<Expense> filteredExpenses) {
    final Map<String, double> categoryData = {};

    for (var expense in filteredExpenses) {
      for (var product in expense.products) {
        categoryData[product.category] = (categoryData[product.category] ?? 0) +
            product.price * product.quantity;
      }
    }

    return categoryData.map((category, total) {
      return MapEntry(
          '${AppLocalizations.of(context)!.translateCategory(category)} - €${total.toStringAsFixed(2)}',
          total);
    });
  }

  // Prepara i dati per il grafico a barre
  Map<String, double> _prepareBarChartData(List<Expense> filteredExpenses) {
    final Map<String, double> periodData = {};

    if (selectedPeriod == 'week') {
      final startOfWeek =
          currentDate.subtract(Duration(days: currentDate.weekday - 1));

      for (var i = 0; i < 7; i++) {
        final day = startOfWeek.add(Duration(days: i));
        periodData[DateFormat('MM-dd').format(day)] = 0;
      }

      for (var expense in filteredExpenses) {
        final expenseDate = DateFormat('dd-MM-yyyy').parse(expense.date);
        final formattedDate = DateFormat('MM-dd').format(expenseDate);
        periodData[formattedDate] =
            (periodData[formattedDate] ?? 0) + expense.totalAmount;
      }
    } else if (selectedPeriod == 'month') {
      for (var i = 1; i <= 4; i++) {
        periodData['$i'] = 0;
      }

      for (var expense in filteredExpenses) {
        final expenseDate = DateFormat('dd-MM-yyyy').parse(expense.date);
        var weekOfMonth = ((expenseDate.day - 1) ~/ 7) + 1;
        weekOfMonth = weekOfMonth > 4 ? 4 : weekOfMonth;
        periodData['$weekOfMonth'] =
            (periodData['$weekOfMonth'] ?? 0) + expense.totalAmount;
      }
    } else if (selectedPeriod == 'year') {
      for (var i = 1; i <= 12; i++) {
        periodData[DateFormat.MMM().format(DateTime(currentDate.year, i))] = 0;
      }

      for (var expense in filteredExpenses) {
        final expenseDate = DateFormat('dd-MM-yyyy').parse(expense.date);
        final monthName = DateFormat.MMM().format(expenseDate);
        periodData[monthName] =
            (periodData[monthName] ?? 0) + expense.totalAmount;
      }
    }
    return periodData;
  }

  Map<String, double> _calculateSupermarketExpenses(
      List<Expense> filteredExpenses) {
    final Map<String, double> supermarketData = {};

    for (var expense in filteredExpenses) {
      if (supermarketData.containsKey(expense.supermarket)) {
        supermarketData[expense.supermarket] =
            supermarketData[expense.supermarket]! + expense.totalAmount;
      } else {
        supermarketData[expense.supermarket] = expense.totalAmount;
      }
    }

    // Mappare i dati per includere il totale della spesa con il formato desiderato
    return supermarketData.map((supermarket, total) {
      return MapEntry('$supermarket - €${total.toStringAsFixed(2)}', total);
    });
  }

  Future<List<Expense>> _fetchExpenses() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final expensesDocRef =
          FirebaseFirestore.instance.collection('expenses').doc(userId);
      final expensesDoc = await expensesDocRef.get();

      if (expensesDoc.data() == null || !expensesDoc.exists) return [];
      return (expensesDoc.data()!['expenses'] as List)
          .map((expense) => Expense.fromJson(expense))
          .toList();
    } catch (e) {
      ToastNotifier.showError('Errore durante il recupero delle spese: $e');
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
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.viewExpenses),
      ),
      body: FutureBuilder<List<Expense>>(
        future: _fetchExpenses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                  '${AppLocalizations.of(context)!.error}: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(AppLocalizations.of(context)!.noExpensesFound),
            );
          } else {
            final expenses = snapshot.data!;
            var filteredExpenses = _filterExpensesByPeriod(expenses);
            //sort filtered expenses by date
            filteredExpenses.sort((a, b) {
              final aDate = DateFormat('dd-MM-yyyy').parse(a.date);
              final bDate = DateFormat('dd-MM-yyyy').parse(b.date);
              return aDate.compareTo(bDate);
            });
            if (filteredExpenses.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppLocalizations.of(context)!.noExpensesForPeriod),
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

            final categoryData = _calculateCategoryExpenses(filteredExpenses);
            final supermarketData =
                _calculateSupermarketExpenses(filteredExpenses);
            final periodData = _prepareBarChartData(filteredExpenses);

            return SingleChildScrollView(
              child: Column(
                children: [
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
                          '${selectedPeriod == 'week' ? '${AppLocalizations.of(context)!.weekOf} ${DateFormat('dd/MM/yyyy').format(currentDate.subtract(Duration(days: currentDate.weekday - 1)))}' : selectedPeriod == 'month' ? '${AppLocalizations.of(context)!.monthOf} ${DateFormat('MMMM yyyy', 'it_IT').format(currentDate)}' : '${currentDate.year}'} : ${filteredExpenses.map((expenses) => expenses.totalAmount).reduce((value, element) => value + element).toStringAsFixed(2)} €',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 150,
                    child: CustomBarChart(periodData: periodData),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: pie_chart.PieChart(
                      dataMap: categoryData,
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
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: pie_chart.PieChart(
                      dataMap: supermarketData,
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
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: filteredExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = filteredExpenses[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6.0, horizontal: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ExpenseDetailScreen(expense: expense),
                              ),
                            ).then((returnedExpense) {
                              if (returnedExpense != null) {
                                _fetchExpenses().then((expenses) {
                                  setState(() {
                                    filteredExpenses =
                                        _filterExpensesByPeriod(expenses);
                                  });
                                });
                              }
                            });
                          },
                          child: Card(
                            color: Theme.of(context).primaryColor,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 12.0),
                              child: ListTile(
                                textColor:
                                    Theme.of(context).colorScheme.onPrimary,
                                title: Text(
                                  '${AppLocalizations.of(context)!.supermarket}: ${expense.supermarket}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                        '${AppLocalizations.of(context)!.date}: ${expense.date}'),
                                    Text(
                                        '${AppLocalizations.of(context)!.total}: €${expense.totalAmount.toStringAsFixed(2)}'),
                                  ],
                                ),
                                trailing: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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
