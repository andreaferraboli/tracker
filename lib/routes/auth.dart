import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/services/toast_notifier.dart';

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
      } else {
        if (_passwordController.text.trim() !=
            _confirmPasswordController.text.trim()) {
          ToastNotifier.showError(
              AppLocalizations.of(context)!.passwordsDoNotMatch);
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
          "stores": [
            {"name": "fridge", "icon": "kitchen"},
            {"name": "pantry", "icon": "storage"},
            {"name": "freezer", "icon": "ac_unit"}
          ],
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

      ToastNotifier.showSuccess(
        context,
        isLogin
            ? AppLocalizations.of(context)!.loginSuccess
            : AppLocalizations.of(context)!.signupSuccess,
      );
    } on FirebaseAuthException catch (e) {
      ToastNotifier.showError(
        '${AppLocalizations.of(context)!.error}: ${e.message}',
      );
    }
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
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(isLogin
              ? AppLocalizations.of(context)!.login
              : AppLocalizations.of(context)!.signUp),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isLogin)
                    CupertinoTextField(
                      controller: _usernameController,
                      placeholder: AppLocalizations.of(context)!.username,
                      padding: const EdgeInsets.all(12),
                    ),
                  if (!isLogin) const SizedBox(height: 16),
                  CupertinoTextField(
                    controller: _emailController,
                    placeholder: AppLocalizations.of(context)!.email,
                    keyboardType: TextInputType.emailAddress,
                    padding: const EdgeInsets.all(12),
                  ),
                  const SizedBox(height: 16),
                  CupertinoTextField(
                    controller: _passwordController,
                    placeholder: AppLocalizations.of(context)!.password,
                    obscureText: !_isPasswordVisible,
                    suffix: CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Icon(
                        _isPasswordVisible
                            ? CupertinoIcons.eye_slash
                            : CupertinoIcons.eye,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    padding: const EdgeInsets.all(12),
                  ),
                  if (!isLogin) const SizedBox(height: 16),
                  if (!isLogin)
                    CupertinoTextField(
                      controller: _confirmPasswordController,
                      placeholder: AppLocalizations.of(context)!.confirmPassword,
                      obscureText: !_isConfirmPasswordVisible,
                      suffix: CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Icon(
                          _isConfirmPasswordVisible
                              ? CupertinoIcons.eye_slash
                              : CupertinoIcons.eye,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                      padding: const EdgeInsets.all(12),
                    ),
                  const SizedBox(height: 32),
                  CupertinoButton.filled(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _authenticateUser();
                      }
                    },
                    child: Text(
                      isLogin
                          ? AppLocalizations.of(context)!.login
                          : AppLocalizations.of(context)!.signUp,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CupertinoButton(
                    onPressed: () {
                      setState(() {
                        isLogin = !isLogin;
                      });
                    },
                    child: Text(
                      isLogin
                          ? AppLocalizations.of(context)!.noAccount
                          : AppLocalizations.of(context)!.alreadyHaveAccount,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

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
                      _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
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
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !_isConfirmPasswordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.enterPassword;
                    }
                    if (value != _passwordController.text) {
                      return AppLocalizations.of(context)!.passwordsDoNotMatch;
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _authenticateUser();
                  }
                },
                child: Text(
                  isLogin
                      ? AppLocalizations.of(context)!.login
                      : AppLocalizations.of(context)!.signUp,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    isLogin = !isLogin;
                  });
                },
                child: Text(
                  isLogin
                      ? AppLocalizations.of(context)!.noAccount
                      : AppLocalizations.of(context)!.alreadyHaveAccount,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
