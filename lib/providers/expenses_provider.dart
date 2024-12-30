import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/expense.dart';

class ExpensesNotifier extends StateNotifier<List<Expense>> {
  ExpensesNotifier() : super([]);
  Future<void> _syncToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('expenses')
            .doc(user.uid)
            .set({
          'expenses': state.map((expense) => expense.toJson()).toList(),
        });
      } catch (e) {
        print('Error syncing expenses to Firebase: $e');
      }
    }
  }

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

    String exportToJson() {
      final List<Map<String, dynamic>> jsonList =
          state.map((expense) => expense.toJson()).toList();
      return json.encode(jsonList);
    }

    void importFromJson(String jsonString) {
      try {
        final List<dynamic> jsonList = json.decode(jsonString);
        final List<Expense> expenses =
            jsonList.map((json) => Expense.fromJson(json)).toList();
        state = expenses;
        _syncToFirebase();
      } catch (e) {
        print('Error importing expenses from JSON: $e');
      }
    }

    Future<void> fetchExpenses() async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          final snapshot = await FirebaseFirestore.instance
              .collection('expenses')
              .doc(user.uid)
              .get();

          if (snapshot.exists && snapshot.data() != null) {
            final data = snapshot.data()!;
            if (data['expenses'] != null) {
              final List<dynamic> expensesData = data['expenses'];
              final expenses = expensesData
                  .map((expense) => Expense.fromJson(expense))
                  .toList();
              state = expenses;
            }
          }
        } catch (e) {
          print('Error fetching expenses: $e');
        }
      }
    }
  }



final expensesProvider =
    StateNotifierProvider<ExpensesNotifier, List<Expense>>((ref) {
  return ExpensesNotifier();
});
