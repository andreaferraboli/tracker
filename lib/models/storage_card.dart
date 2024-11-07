import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tracker/l10n/app_localizations.dart';

class StorageCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isAddButton;
  final VoidCallback? onAddPressed;

  const StorageCard({
    super.key,
    required this.icon,
    required this.title,
    this.isAddButton = false,
    this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: isAddButton ? onAddPressed : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.getStorageTitle(title),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
