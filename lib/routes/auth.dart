import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/models/product.dart';
import 'package:tracker/providers/category_provider.dart';
import 'package:tracker/providers/products_provider.dart';
import 'package:tracker/services/category_services.dart';

import '../models/expense.dart';
import '../providers/expenses_provider.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  bool isLogin = true;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();

  Future<void> _authenticateUser() async {
    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        loadUserData();
      } else {
        if (_passwordController.text.trim() !=
            _confirmPasswordController.text.trim()) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.passwordsDoNotMatch),
            ),
          );
          return;
        }

        final userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final userDocRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid);

        // Creazione documento principale dell'utente
        await userDocRef.set({
          "username": _usernameController.text.trim(),
          "supermarkets": [],
        });

// Creazione documento per products
        await FirebaseFirestore.instance
            .collection('products')
            .doc(userCredential.user!.uid)
            .set({"products": []});

// Creazione documento per expenses
        await FirebaseFirestore.instance
            .collection('expenses')
            .doc(userCredential.user!.uid)
            .set({"expenses": []});

// Creazione documento per meals
        await FirebaseFirestore.instance
            .collection('meals')
            .doc(userCredential.user!.uid)
            .set({"meals": []});
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isLogin
                ? AppLocalizations.of(context)!.loginSuccess
                : AppLocalizations.of(context)!.signupSuccess,
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.error}: ${e.message}'),
        ),
      );
    }
  }

  Future<void> loadUserData() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final productsDocRef =
        FirebaseFirestore.instance.collection('products').doc(userId);
    final productsDoc = await productsDocRef.get();
    final products = (productsDoc.data()?['products'] as List?)
            ?.map((product) => Product.fromJson(product))
            .toList() ??
        [];

    final categoriesDocRef =
        FirebaseFirestore.instance.collection('categories').doc(userId);
    final categoriesDoc = await categoriesDocRef.get();
    final categories = (categoriesDoc.data()?['categories'] as List?)
            ?.map((category) => Category.fromJson(category))
            .toList() ??
        [];

    final expensesDocRef =
        FirebaseFirestore.instance.collection('expenses').doc(userId);
    final expensesDoc = await expensesDocRef.get();
    final expenses = (expensesDoc.data()?['expenses'] as List?)
            ?.map((expense) => Expense.fromJson(expense))
            .toList() ??
        [];

    ref.read(productsProvider.notifier).loadProducts(products);
    ref.read(categoriesProvider.notifier).loadCategories(categories);
    ref.read(expensesProvider.notifier).loadExpenses(expenses);
  }

  @override
  void dispose() {
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
        title: Text(isLogin
            ? AppLocalizations.of(context)!.login
            : AppLocalizations.of(context)!.signUp),
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
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.username,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.enterUsername;
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.email,
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.enterEmail;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.password,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isPasswordVisible,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.enterPassword;
                  }
                  return null;
                },
              ),
              if (!isLogin) const SizedBox(height: 16),
              if (!isLogin)
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.confirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !_isConfirmPasswordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.confirmPassword;
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
                child: Text(isLogin
                    ? AppLocalizations.of(context)!.login
                    : AppLocalizations.of(context)!.signUp),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    isLogin = !isLogin;
                  });
                },
                child: Text(isLogin
                    ? AppLocalizations.of(context)!.createAccount
                    : AppLocalizations.of(context)!.alreadyHaveAccount),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
