
import 'package:flutter/material.dart';

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
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}