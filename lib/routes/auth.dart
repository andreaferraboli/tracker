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
  AuthPageState createState() => AuthPageState();
}

class AuthPageState extends ConsumerState<AuthPage> {
  bool isLogin = true;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();

  Future<void> _authenticateUser() async {
    if (!mounted) return;

    final localContext = context;
    final localizations = AppLocalizations.of(localContext)!;

    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        if (_passwordController.text.trim() !=
            _confirmPasswordController.text.trim()) {
          if (!mounted) return;
          ToastNotifier.showError(localizations.passwordsDoNotMatch);
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

        await userDocRef.set({
          "username": _usernameController.text.trim(),
          "supermarkets": [],
          "stores": [
            {"name": "fridge", "icon": "kitchen"},
            {"name": "pantry", "icon": "storage"},
            {"name": "freezer", "icon": "ac_unit"}
          ],
        });

        await FirebaseFirestore.instance
            .collection('products')
            .doc(userCredential.user!.uid)
            .set({"products": []});

        await FirebaseFirestore.instance
            .collection('expenses')
            .doc(userCredential.user!.uid)
            .set({"expenses": []});

        await FirebaseFirestore.instance
            .collection('meals')
            .doc(userCredential.user!.uid)
            .set({"meals": []});

        await FirebaseFirestore.instance
            .collection('discounted_products')
            .doc(userCredential.user!.uid)
            .set({"discounted_products": []});
      }

      if (!mounted) return;
      ToastNotifier.showSuccess(
        localContext,
        isLogin ? localizations.loginSuccess : localizations.signupSuccess,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ToastNotifier.showError(
        '${localizations.error}: ${e.message}',
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
    return Platform.isIOS && false
        ? CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: Text(isLogin
                  ? AppLocalizations.of(context)!.login
                  : AppLocalizations.of(context)!.signUp),
            ),
            child: _buildBody(context),
          )
        : Scaffold(
            appBar: AppBar(
              titleSpacing: 0,
              centerTitle: true,
              title: Text(isLogin
                  ? AppLocalizations.of(context)!.login
                  : AppLocalizations.of(context)!.signUp),
            ),
            body: _buildBody(context),
          );
  }

  Widget _buildBody(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Platform.isIOS && false
                  ? CupertinoTextField(
                      controller: _emailController,
                      placeholder: AppLocalizations.of(context)!.email,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.black),
                    )
                  : TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.email,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            !value.contains('@')) {
                          return AppLocalizations.of(context)!.enterValidEmail;
                        }
                        return null;
                      },
                    ),
              const SizedBox(height: 12),
              Platform.isIOS && false
                  ? CupertinoTextField(
                      controller: _passwordController,
                      placeholder: AppLocalizations.of(context)!.password,
                      obscureText: !_isPasswordVisible,
                      style: const TextStyle(color: Colors.black),
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
                      suffixMode: OverlayVisibilityMode.editing,
                    )
                  : TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.password,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
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
              if (!isLogin) ...[
                const SizedBox(height: 12),
                Platform.isIOS && false
                    ? CupertinoTextField(
                        controller: _confirmPasswordController,
                        placeholder:
                            AppLocalizations.of(context)!.confirmPassword,
                        obscureText: !_isConfirmPasswordVisible,
                        style: const TextStyle(color: Colors.black),
                        suffix: CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: Icon(
                            _isConfirmPasswordVisible
                                ? CupertinoIcons.eye_slash
                                : CupertinoIcons.eye,
                          ),
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible;
                            });
                          },
                        ),
                        suffixMode: OverlayVisibilityMode.editing,
                      )
                    : TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText:
                              AppLocalizations.of(context)!.confirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
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
                          if (value != _passwordController.text) {
                            return AppLocalizations.of(context)!
                                .passwordsDoNotMatch;
                          }
                          return null;
                        },
                      ),
                const SizedBox(height: 12),
                Platform.isIOS && false
                    ? CupertinoTextField(
                        controller: _usernameController,
                        placeholder: AppLocalizations.of(context)!.username,
                        style: const TextStyle(color: Colors.black),
                      )
                    : TextFormField(
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
              ],
              const SizedBox(height: 12),
              Platform.isIOS && false
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CupertinoButton(
                          onPressed: _authenticateUser,
                          child: Text(isLogin
                              ? AppLocalizations.of(context)!.login
                              : AppLocalizations.of(context)!.signUp),
                        ),
                        CupertinoButton(
                          child: Text(isLogin
                              ? AppLocalizations.of(context)!.createAccount
                              : AppLocalizations.of(context)!
                                  .alreadyHaveAccount),
                          onPressed: () {
                            setState(() {
                              isLogin = !isLogin;
                            });
                          },
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        ElevatedButton(
                          onPressed: _authenticateUser,
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
                              : AppLocalizations.of(context)!
                                  .alreadyHaveAccount),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
