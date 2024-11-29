import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/models/storage_card.dart';
import 'package:tracker/routes/storage_screen.dart';

import '../providers/stores_provider.dart';
import '../services/icons_helper.dart';
import 'edit_storage_screen.dart'; // Assicurati di importare il file del provider

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    final stores = ref.watch(storesProvider);

    return Scaffold(
      appBar: isIOS
          ? CupertinoNavigationBar(
              middle: Text(AppLocalizations.of(context)!.inventory),
            )
          : AppBar(
              titleSpacing: 0,
              centerTitle: true,
              title: Text(AppLocalizations.of(context)!.inventory),
            ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            ...stores.asMap().entries.map((entry) {
              final index = entry.key;
              final store = entry.value;
              return GestureDetector(
                onLongPress: () =>
                    _navigateToEditStorageScreen(context, ref, index, store),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StorageScreen(
                        name: store['name'],
                      ),
                    ),
                  );
                },
                child: StorageCard(
                  icon: IconsHelper.iconMap[store['icon']] ?? Icons.home,
                  title: store['name'],
                  isAddButton: false,
                ),
              );
            }),
            StorageCard(
              icon: Icons.add,
              title: AppLocalizations.of(context)!.addStorage,
              // Traduci se necessario
              isAddButton: true,
              onAddPressed: () =>
                  _navigateToEditStorageScreen(context, ref, -1, null),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEditStorageScreen(
    BuildContext context,
    WidgetRef ref,
    int index,
    Map<String, dynamic>? store,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditStorageScreen(
          initialName: store?['name'] ?? '',
          initialIcon: store?['icon'] ?? 'home',
          onNameChanged: (newName) {
            if (index >= 0) {
              ref.read(storesProvider.notifier).updateStore(index, newName,
                  IconsHelper.iconMap[store?['icon']] ?? Icons.home);
            } else {
              ref.read(storesProvider.notifier).addStore(newName, Icons.home);
            }
          },
          onIconChanged: (newIcon) {
            if (index >= 0) {
              ref
                  .read(storesProvider.notifier)
                  .updateStore(index, store?['name'] ?? '', newIcon);
            } else {
              // Aggiorna l'ultimo storage aggiunto con l'icona scelta
              final newName = ref.read(storesProvider).last['name'];
              ref.read(storesProvider.notifier).updateStore(
                    ref.read(storesProvider).length - 1,
                    newName,
                    newIcon,
                  );
            }
          },
        ),
      ),
    );
  }
}
