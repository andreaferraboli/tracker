import 'dart:io'; // Aggiunto per rilevare la piattaforma
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tracker/services/toast_notifier.dart';
import 'package:flutter/cupertino.dart'; // Aggiunto per i widget Cupertino
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/category_provider.dart';
import '../providers/discounted_products_provider.dart';
import '../providers/expenses_provider.dart';
import '../providers/meals_provider.dart';
import '../providers/products_provider.dart';
import '../providers/stores_provider.dart';
import '../providers/supermarket_provider.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/supermarkets_list_provider.dart';
import 'dart:convert';

class UserScreen extends ConsumerStatefulWidget {
  const UserScreen({super.key});

  @override
  ConsumerState<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends ConsumerState<UserScreen> {
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

  void _showOpenFileDialog(File file) {
    final directory = file.parent.path;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Esportazione completata'),
          content: Text('Vuoi aprire la cartella contenente il file in $directory?'),
          actions: <Widget>[
            TextButton(
              child: Text('Annulla'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Apri'),
              onPressed: () {
                Navigator.of(context).pop();
                _openFileExplorer(file);
              },
            ),
          ],
        );
      },
    );
  }

  void _openFileExplorer(File file) async {
    final directory = file.parent.path;
    if (await canLaunch(directory)) {
      await launch(directory);
    } else {
      ToastNotifier.showError('Impossibile aprire il file explorer');
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

  Future<void> exportDataToJson() async {
    try {
      // Ottieni i dati da tutti i provider
      final categories = ref.read(categoriesProvider.notifier).exportToJson();
      final discountedProducts =
          ref.read(discountedProductsProvider.notifier).exportToJson();
      final expenses = ref.read(expensesProvider.notifier).exportToJson();
      final meals = ref.read(mealsProvider.notifier).exportToJson();
      final products = ref.read(productsProvider.notifier).exportToJson();
      final stores = ref.read(storesProvider.notifier).exportToJson();
      final supermarketsList =
          ref.read(supermarketsListProvider.notifier).exportToJson();
      // Crea un oggetto JSON con tutti i dati
      final exportData = {
        'categories': json.decode(categories),
        'discountedProducts': json.decode(discountedProducts),
        'expenses': json.decode(expenses),
        'meals': json.decode(meals),
        'products': json.decode(products),
        'stores': json.decode(stores),
        'supermarketsList': json.decode(supermarketsList),
      };

      // Converti in stringa JSON
      final jsonString = json.encode(exportData);
      final directory = await getExternalStorageDirectory();
      final outputFile = File('${directory!.path}/FSF_food_tracker_data.json');

      await outputFile.writeAsString(jsonString);
      ToastNotifier.showSuccess(
          context, 'Dati esportati con successo');
      _showOpenFileDialog(outputFile);
    } catch (e) {
      print('Errore durante l\'esportazione dei dati: $e');
      ToastNotifier.showError('$e');
    }
  }

  Future<void> importDataFromJson() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        final data = json.decode(jsonString);

        // Importa i dati in ogni provider
        if (data['categories'] != null) {
          ref
              .read(categoriesProvider.notifier)
              .importFromJson(json.encode(data['categories']));
        }
        if (data['discountedProducts'] != null) {
          ref
              .read(discountedProductsProvider.notifier)
              .importFromJson(json.encode(data['discountedProducts']));
        }
        if (data['expenses'] != null) {
          ref
              .read(expensesProvider.notifier)
              .importFromJson(json.encode(data['expenses']));
        }
        if (data['meals'] != null) {
          ref
              .read(mealsProvider.notifier)
              .importFromJson(json.encode(data['meals']));
        }
        if (data['products'] != null) {
          ref
              .read(productsProvider.notifier)
              .importFromJson(json.encode(data['products']));
        }
        if (data['stores'] != null) {
          ref
              .read(storesProvider.notifier)
              .importFromJson(json.encode(data['stores']));
        }
        if (data['supermarketsList'] != null) {
          ref
              .read(supermarketsListProvider.notifier)
              .importFromJson(json.encode(data['supermarketsList']));
        }

        ToastNotifier.showSuccess(context, 'Dati importati con successo');
      }
    } catch (e) {
      print('Errore durante l\'importazione dei dati: $e');
      ToastNotifier.showError('Errore durante l\'importazione dei dati: $e');
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
                    // Bottoni per importare/esportare dati
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: exportDataToJson,
                          icon: const Icon(Icons.file_upload),
                          label: const Text('Esporta dati'),
                        ),
                        ElevatedButton.icon(
                          onPressed: importDataFromJson,
                          icon: const Icon(Icons.file_download),
                          label: const Text('Importa dati'),
                        ),
                      ],
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
                  ],
                )
          : Center(
              child: Text(AppLocalizations.of(context)!.noUserLoggedIn),
            ),
    );
  }
}
