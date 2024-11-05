import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import di Riverpod
import 'package:tracker/providers/products_provider.dart';
import 'package:tracker/providers/category_provider.dart';
import 'package:tracker/models/product.dart';
import 'package:tracker/services/category_services.dart';

import '../models/expense.dart';
import '../providers/expenses_provider.dart';

class AuthPage extends ConsumerStatefulWidget {
  // ConsumerStatefulWidget per Riverpod
  const AuthPage({super.key});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  // ConsumerState per Riverpod
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();

  // Funzione per autenticare l'utente
  Future<void> _authenticateUser() async {
    try {
      if (isLogin) {
        loadUserData(); // Caricamento dati utente
      } else {
        //todo: continua da qua a tradurre
        if (_passwordController.text.trim() !=
            _confirmPasswordController.text.trim()) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Passwords do not match')),
          );
          return;
        }

        DocumentReference userDocRef = FirebaseFirestore.instance
            .collection('products')
            .doc(FirebaseAuth.instance.currentUser!.uid);
        userDocRef.set({
          "products": [],
        });
        userDocRef = FirebaseFirestore.instance
            .collection('expenses')
            .doc(FirebaseAuth.instance.currentUser!.uid);
        userDocRef.set({
          "expenses": [],
        });
        userDocRef = FirebaseFirestore.instance
            .collection('meals')
            .doc(FirebaseAuth.instance.currentUser!.uid);
        userDocRef.set({
          "meals": [],
        });
        userDocRef = FirebaseFirestore.instance
            .collection('categories')
            .doc(FirebaseAuth.instance.currentUser!.uid);
        userDocRef.set({
          "categories": await CategoryServices.getAndLoadCategoriesData(),
        });
      }
      // Mostra messaggio di successo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(isLogin ? 'Login successful' : 'Sign up successful')),
      );
    } on FirebaseAuthException catch (e) {
      print("errore${e.message}");
      // Gestisce gli errori di autenticazione
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    }
  }

  Future<void> loadUserData() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final productsDocRef =
        FirebaseFirestore.instance.collection('products').doc(userId);

    final productsDoc = await productsDocRef.get();
    final products = (productsDoc.data()!['products'] as List)
        .map((product) => Product.fromJson(product))
        .toList();
    final categoriesDocRef =
        FirebaseFirestore.instance.collection('categories').doc(userId);
    final categoriesDoc = await categoriesDocRef.get();
    final categories = (categoriesDoc.data()!['categories'] as List)
        .map((category) => Category.fromJson(category))
        .toList();
    final expensesDocRef =
        FirebaseFirestore.instance.collection('expenses').doc(userId);
    final expensesDoc = await expensesDocRef.get();
    final expenses = (expensesDoc.data()!['expenses'] as List)
        .map((expense) => Expense.fromJson(expense))
        .toList();
    // final mealsDocRef = FirebaseFirestore.instance.collection('meals').doc(userId);
    // final mealsDoc = await mealsDocRef.get();
    // final meals = (mealsDoc.data()!['meals'] as List)
    //     .map((meal) => Meal.fromJson(meal))
    //     .toList();

    ref
        .read(productsProvider.notifier)
        .loadProducts(products); // ref.read per Riverpod
    ref.read(categoriesProvider.notifier).loadCategories(categories);
    ref.read(expensesProvider.notifier).loadExpenses(expenses);
    // ref.read(mealsProvider.notifier).state = meals;
  }

  @override
  void dispose() {
    // Rilascia i controller quando non sono più necessari
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLogin ? 'Login' : 'Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isLogin)
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                textCapitalization: TextCapitalization.none,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              if (!isLogin) const SizedBox(height: 16),
              if (!isLogin)
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration:
                      const InputDecoration(labelText: 'Confirm Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _authenticateUser();
                  }
                },
                child: Text(isLogin ? 'Login' : 'Sign Up'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    isLogin = !isLogin;
                  });
                },
                child: Text(isLogin
                    ? 'Create an account'
                    : 'Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
