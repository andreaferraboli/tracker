import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  Future<String> getExpensesAsJson() async {
    final expensesJson = state.map((expense) => expense.toJson()).toList();
    return jsonEncode(expensesJson);
  }
Future<void> postExpenses(expensesJson) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    try {
      await FirebaseFirestore.instance
          .collection('expenses')
          .doc(user.uid)
          .set({'expenses': jsonDecode(expensesJson)});
    } catch (e) {
      // Handle error
      print('Error posting expenses: $e');
    }
  }
}
}

final expensesProvider =
    StateNotifierProvider<ExpensesNotifier, List<Expense>>((ref) {
  return ExpensesNotifier();
});
