import 'dart:io'; // Aggiunto per rilevare la piattaforma
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tracker/services/toast_notifier.dart';
import 'package:flutter/cupertino.dart'; // Aggiunto per i widget Cupertino

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
    return Platform.isIOS
        ? CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: Text(AppLocalizations.of(context)!.userProfile),
            ),
            child: _buildBody(),
          )
        : Scaffold(
            appBar: AppBar(
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
                    Platform.isIOS
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
                    Platform.isIOS
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
                    Platform.isIOS
                        ? CupertinoTextField(
                            controller: _confirmPasswordController,
                            obscureText: !_isConfirmPasswordVisible,
                            placeholder:
                                AppLocalizations.of(context)!.confirmNewPassword,
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
                              labelText:
                                  AppLocalizations.of(context)!.confirmNewPassword,
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
                    Platform.isIOS
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
