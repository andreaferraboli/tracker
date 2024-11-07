import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/expense.dart';

class ExpensesNotifier extends StateNotifier<List<Expense>> {
  ExpensesNotifier() : super([]);

  void loadExpenses(List<Expense> expenses) {
    state = expenses;
  }

  void addExpense(Expense expense) {
    state = [...state, expense];
  }

  void removeExpense(String id) {
    state = state.where((expense) => expense.id != id).toList();
  }
}

final expensesProvider =
    StateNotifierProvider<ExpensesNotifier, List<Expense>>((ref) {
  return ExpensesNotifier();
});
