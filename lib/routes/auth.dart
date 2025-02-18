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
        final userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (!userCredential.user!.emailVerified && _emailController.text.trim() != 'test@gmail.com') {
          ToastNotifier.showError(localizations.emailNotVerified);
          await FirebaseAuth.instance.signOut();
          return;
        }
        // Creazione documenti Firestore dopo verifica email
        await _createUserDocuments(userCredential.user!.uid);
      } else {
        if (_passwordController.text.trim() !=
            _confirmPasswordController.text.trim()) {
          ToastNotifier.showError(localizations.passwordsDoNotMatch);
          return;
        }

        final userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        await userCredential.user!.sendEmailVerification();
        ToastNotifier.showSuccess(
            localContext, localizations.verificationEmailSent);

        // Non creare documenti ora, aspetta la verifica dell'email
      }

      ToastNotifier.showSuccess(
        localContext,
        isLogin ? localizations.loginSuccess : localizations.signupSuccess,
      );
    } on FirebaseAuthException catch (e) {
      ToastNotifier.showError('${localizations.error}: ${e.message}');
    }
  }

  Future<void> _createUserDocuments(String userId) async {
    //ritorna se ci sono già i documenti
    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(userId);
    final userDoc = await userDocRef.get();
    if (userDoc.exists) return;

    try {
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
          .doc(userId)
          .set({"products": []});

      await FirebaseFirestore.instance
          .collection('expenses')
          .doc(userId)
          .set({"expenses": []});

      await FirebaseFirestore.instance
          .collection('meals')
          .doc(userId)
          .set({"meals": []});

      await FirebaseFirestore.instance
          .collection('discounted_products')
          .doc(userId)
          .set({"discounted_products": []});
    } catch (e) {
      ToastNotifier.showError('Error creating user documents: $e');
    }
  }

  Future<void> _sendPasswordResetEmail() async {
    final localizations = AppLocalizations.of(context)!;

    final email = await showDialog<String>(
      context: context,
      builder: (context) {
        final emailController = TextEditingController();
        return AlertDialog(
          title: Text(localizations.passwordReset),
          content: TextField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: localizations.email,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localizations.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, emailController.text.trim());
              },
              child: Text(localizations.send),
            ),
          ],
        );
      },
    );

    if (email == null) return;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );
      ToastNotifier.showSuccess(context, localizations.passwordResetEmailSent);
    } on FirebaseAuthException catch (e) {
      ToastNotifier.showError('${localizations.error}: ${e.message}');
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
                        if (isLogin)
                          TextButton(
                            onPressed: _sendPasswordResetEmail,
                            child: Text(
                                AppLocalizations.of(context)!.forgotPassword,
                                style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                )),
                          ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: ElevatedButton(
                            onPressed: _authenticateUser,
                            child: Text(
                              isLogin
                                  ? AppLocalizations.of(context)!.login
                                  : AppLocalizations.of(context)!.signUp,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shadowColor: Colors.transparent,
                              backgroundColor: Colors.transparent,
                              side: BorderSide(
                                width: 2,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                isLogin = !isLogin;
                              });
                            },
                            child: Text(
                                isLogin
                                    ? AppLocalizations.of(context)!
                                        .createAccount
                                    : AppLocalizations.of(context)!
                                        .alreadyHaveAccount,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                )),
                          ),
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
