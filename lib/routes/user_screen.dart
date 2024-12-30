import 'dart:convert';
import 'dart:io'; // Aggiunto per rilevare la piattaforma
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tracker/services/toast_notifier.dart';
import 'package:flutter/cupertino.dart';

import '../models/discounted_product.dart';
import '../models/expense.dart';
import '../models/meal.dart';
import '../models/product.dart';
import '../providers/category_provider.dart';
import '../providers/meals_provider.dart';
import '../providers/products_provider.dart';
import '../providers/discounted_products_provider.dart';
import '../providers/expenses_provider.dart'; // Aggiunto per i widget Cupertino

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final user = FirebaseAuth.instance.currentUser;
  String? username;
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = true;

  // Variabili di stato per la visibilità delle password
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  Future<void> _importDatabase() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    // Accesso al ref del provider
    final ref = ProviderContainer();

    try {
      // Seleziona il file dal dispositivo
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/database.json');

      if (!await file.exists()) {
        ToastNotifier.showError('File database.json non trovato');
        return;
      }

      // Leggi il file JSON
      final jsonString = await file.readAsString();
      final Map<String, dynamic> importedData = jsonDecode(jsonString);

      final List<dynamic> mealsData = importedData['meals'];
      final List<dynamic> productsData = importedData['products'];
      final List<dynamic> expensesData = importedData['expenses'];
      final List<dynamic> discountedProductsData =
          importedData['discounted_products'];
      final List<dynamic> categoriesData = importedData['categories'];

      // Aggiorna i dati nei provider Riverpod
      ref
          .read(mealsProvider.notifier)
          .loadMeals(mealsData.map((data) => Meal.fromJson(data)).toList());
      ref.read(productsProvider.notifier).loadProducts(
          productsData.map((data) => Product.fromJson(data)).toList());
      ref.read(expensesProvider.notifier).loadExpenses(
          expensesData.map((data) => Expense.fromJson(data)).toList());
      ref.read(discountedProductsProvider.notifier).loadDiscountedProducts(
          discountedProductsData
              .map((data) => DiscountedProduct.fromJson(data))
              .toList());
      ref.read(categoriesProvider.notifier).loadCategories(
          categoriesData.map((data) => Category.fromJson(data)).toList());

      // Aggiorna il documento utente in Firestore (opzionale)

      // Notifica di successo
      ToastNotifier.showSuccess(context, 'Database importato con successo');
    } catch (e) {
      ToastNotifier.showError(
           'Errore durante l\'importazione del database: $e');
    }
  }

  Future<void> _exportDatabase() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    // Accesso al ref del provider
    final ref = ProviderContainer();

    try {
      // Fetch user data

      // Fetch dati dai provider Riverpod
      final mealsJson = await ref.read(mealsProvider.notifier).getMealsAsJson();
      final productsJson =
          await ref.read(productsProvider.notifier).getProductsAsJson();
      final expensesJson =
          await ref.read(expensesProvider.notifier).getExpensesAsJson();
      final discountedProductsJson = await ref
          .read(discountedProductsProvider.notifier)
          .getDiscountedProductsAsJson();
      final categoriesJson =
          await ref.read(categoriesProvider.notifier).getCategoriesAsJson();

      // Combina i dati in un singolo oggetto JSON
      final combinedData = {
        'products': jsonDecode(productsJson),
        'meals': jsonDecode(mealsJson),
        'expenses': jsonDecode(expensesJson),
        'discounted_products': jsonDecode(discountedProductsJson),
        'categories': jsonDecode(categoriesJson),
      };

      // Converte i dati combinati in una stringa JSON
      final json = jsonEncode(combinedData);

      // Salva il file
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/database.json');
      await file.writeAsString(json);

      // Notifica di successo
      ToastNotifier.showSuccess(context, 'Database esportato con successo');
    } catch (e) {
      ToastNotifier.showError(
          'Errore durante l\'esportazione del database: $e');
    }
  }

  Future<void> _fetchUsername() async {
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();
        setState(() {
          username = userDoc.data()?['username'] ?? 'No Username';
          _isLoading = false;
        });
      } catch (e) {
        ToastNotifier.showError("Errore nel caricamento del nome utente: $e");
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _reauthenticateAndChangePassword() async {
    if (_currentPasswordController.text.isNotEmpty &&
        _newPasswordController.text.isNotEmpty &&
        _newPasswordController.text == _confirmPasswordController.text) {
      try {
        // Tentativo di ri-autenticazione
        final credential = EmailAuthProvider.credential(
          email: user!.email!,
          password: _currentPasswordController.text,
        );
        await user!.reauthenticateWithCredential(credential);

        // Aggiornamento della password
        await user!.updatePassword(_newPasswordController.text);
        if (!mounted) return;
        ToastNotifier.showSuccess(
            context, AppLocalizations.of(context)!.passwordUpdated);

        // Pulisce i campi di testo
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      } catch (e) {
        if (e is FirebaseAuthException && e.code == 'invalid-credential') {
          ToastNotifier.showError(
              AppLocalizations.of(context)!.incorrectCurrentPassword);
        } else {
          ToastNotifier.showError(
              AppLocalizations.of(context)!.errorUpdatingPassword);
        }
      }
    } else {
      ToastNotifier.showError(
          AppLocalizations.of(context)!.passwordsDoNotMatch);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS && false
        ? CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: Text(AppLocalizations.of(context)!.userProfile),
            ),
            child: _buildBody(),
          )
        : Scaffold(
            appBar: AppBar(
              titleSpacing: 0,
              centerTitle: true,
              title: Text(AppLocalizations.of(context)!.userProfile),
            ),
            body: _buildBody(),
          );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: user != null
          ? _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Campo nome utente
                    Text(
                      '${AppLocalizations.of(context)!.name}: $username',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    // Campo email
                    Text(
                      '${AppLocalizations.of(context)!.email}: ${user?.email}',
                    ),
                    const SizedBox(height: 16),
                    // Campo per la password corrente
                    Platform.isIOS && false
                        ? CupertinoTextField(
                            controller: _currentPasswordController,
                            obscureText: !_isCurrentPasswordVisible,
                            placeholder:
                                AppLocalizations.of(context)!.currentPassword,
                            suffix: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isCurrentPasswordVisible =
                                      !_isCurrentPasswordVisible;
                                });
                              },
                              child: Icon(
                                _isCurrentPasswordVisible
                                    ? CupertinoIcons.eye
                                    : CupertinoIcons.eye_slash,
                              ),
                            ),
                          )
                        : TextField(
                            controller: _currentPasswordController,
                            obscureText: !_isCurrentPasswordVisible,
                            decoration: InputDecoration(
                              labelText:
                                  AppLocalizations.of(context)!.currentPassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isCurrentPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isCurrentPasswordVisible =
                                        !_isCurrentPasswordVisible;
                                  });
                                },
                              ),
                            ),
                          ),
                    const SizedBox(height: 8),
                    // Campo per la nuova password
                    Platform.isIOS && false
                        ? CupertinoTextField(
                            controller: _newPasswordController,
                            obscureText: !_isNewPasswordVisible,
                            placeholder:
                                AppLocalizations.of(context)!.newPassword,
                            suffix: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isNewPasswordVisible =
                                      !_isNewPasswordVisible;
                                });
                              },
                              child: Icon(
                                _isNewPasswordVisible
                                    ? CupertinoIcons.eye
                                    : CupertinoIcons.eye_slash,
                              ),
                            ),
                          )
                        : TextField(
                            controller: _newPasswordController,
                            obscureText: !_isNewPasswordVisible,
                            decoration: InputDecoration(
                              labelText:
                                  AppLocalizations.of(context)!.newPassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isNewPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isNewPasswordVisible =
                                        !_isNewPasswordVisible;
                                  });
                                },
                              ),
                            ),
                          ),
                    const SizedBox(height: 8),
                    // Campo per confermare la nuova password
                    Platform.isIOS && false
                        ? CupertinoTextField(
                            controller: _confirmPasswordController,
                            obscureText: !_isConfirmPasswordVisible,
                            placeholder: AppLocalizations.of(context)!
                                .confirmNewPassword,
                            suffix: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible;
                                });
                              },
                              child: Icon(
                                _isConfirmPasswordVisible
                                    ? CupertinoIcons.eye
                                    : CupertinoIcons.eye_slash,
                              ),
                            ),
                          )
                        : TextField(
                            controller: _confirmPasswordController,
                            obscureText: !_isConfirmPasswordVisible,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!
                                  .confirmNewPassword,
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
                          ),
                    const SizedBox(height: 8),
                    // Bottone per aggiornare la password
                    Platform.isIOS && false
                        ? CupertinoButton.filled(
                            onPressed: _reauthenticateAndChangePassword,
                            child: Text(
                                AppLocalizations.of(context)!.updatePassword),
                          )
                        : ElevatedButton(
                            onPressed: _reauthenticateAndChangePassword,
                            child: Text(
                                AppLocalizations.of(context)!.updatePassword),
                          ),
// Bottone per esportare il database
                    Platform.isIOS && false
                        ? CupertinoButton.filled(
                            onPressed: _exportDatabase,
                            child: Text(
                                AppLocalizations.of(context)!.exportDatabase),
                          )
                        : ElevatedButton(
                            onPressed: _exportDatabase,
                            child: Text(
                                AppLocalizations.of(context)!.exportDatabase),
                          ),
                    const SizedBox(height: 8),
// Bottone per importare il database
                    Platform.isIOS && false
                        ? CupertinoButton.filled(
                            onPressed: _importDatabase,
                            child: Text(
                                AppLocalizations.of(context)!.importDatabase),
                          )
                        : ElevatedButton(
                            onPressed: _importDatabase,
                            child: Text(
                                AppLocalizations.of(context)!.importDatabase),
                          ),
                    //Bottone che richiama le funzioni di export dei providers
                  ],
                )
          : Center(
              child: Text(AppLocalizations.of(context)!.noUserLoggedIn),
            ),
    );
  }
}
