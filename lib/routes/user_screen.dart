import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    print(user);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.userProfile),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: user != null
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppLocalizations.of(context)!.name}: ${user.displayName}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '${AppLocalizations.of(context)!.email}: ${user.email}',
            ),
          ],
        )
            : Center(
          child: Text(AppLocalizations.of(context)!.noUserLoggedIn),
        ),
      ),
    );
  }
}
