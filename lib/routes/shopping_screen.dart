import 'dart:io'; // Aggiunto per rilevare la piattaforma
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Importa le localizzazioni generate
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart'; // Aggiunto per i widget Cupertino

import '../providers/supermarket_provider.dart';
import '../providers/supermarkets_list_provider.dart';
import 'supermarket_screen.dart';

class ShoppingScreen extends ConsumerWidget {
  const ShoppingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSupermarkets = ref.watch(supermarketsListProvider);

    return Platform.isIOS
        ? CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: Text(AppLocalizations.of(context)!.shoppingTitle),
            ),
            child: _buildBody(context, ref, selectedSupermarkets),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.shoppingTitle),
            ),
            body: _buildBody(context, ref, selectedSupermarkets),
          );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, List<String> selectedSupermarkets) {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16.0),
      children: [
        ...selectedSupermarkets.map((name) => _buildSupermarketCard(
            context, name, 'assets/images/$name.png', ref)),
        _buildAddSupermarketCard(context, ref),
      ],
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, String name, WidgetRef ref) {
    Platform.isIOS
        ? showCupertinoDialog(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: Text(AppLocalizations.of(context)!.confirmDelete),
                content: Text(AppLocalizations.of(context)!.confirmDeleteMessage(name)),
                actions: [
                  CupertinoDialogAction(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(AppLocalizations.of(context)!.cancel),
                  ),
                  CupertinoDialogAction(
                    onPressed: () {
                      ref
                          .read(supermarketsListProvider.notifier)
                          .removeSupermarket(name);
                      Navigator.of(context).pop();
                    },
                    isDestructiveAction: true,
                    child: Text(AppLocalizations.of(context)!.delete),
                  ),
                ],
              );
            },
          )
        : showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(AppLocalizations.of(context)!.confirmDelete),
                content: Text(AppLocalizations.of(context)!.confirmDeleteMessage(name)),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(AppLocalizations.of(context)!.cancel),
                  ),
                  TextButton(
                    onPressed: () {
                      ref
                          .read(supermarketsListProvider.notifier)
                          .removeSupermarket(name);
                      Navigator.of(context).pop();
                    },
                    child: Text(AppLocalizations.of(context)!.delete),
                  ),
                ],
              );
            },
          );
  }

  Widget _buildSupermarketCard(
      BuildContext context, String name, String imagePath, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _navigateToSupermarket(context, name, ref),
      onLongPress: () => _showDeleteConfirmationDialog(context, name, ref),
      child: Card(
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 80,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddSupermarketCard(BuildContext context, WidgetRef ref) {
    final supermarkets = [
      "Coop",
      "Conad",
      "Esselunga",
      "Carrefour",
      "Lidl",
      "Penny Market",
      "Eurospin",
      "Aldi",
      "Simply Market",
      "Auchan",
      "Bennet",
      "Pam",
      "Crai",
      "Selex",
      "MD",
      "Tigre",
      "Eataly"
    ];
    final selectedSupermarkets = ref.watch(supermarketsListProvider);
    final addSupermarketArray = supermarkets
        .where((element) => !selectedSupermarkets.contains(element))
        .toList();

    return GestureDetector(
      onTap: () {
        Platform.isIOS
            ? showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context) {
                  return CupertinoActionSheet(
                    title: Text(AppLocalizations.of(context)!.selectSupermarket),
                    actions: addSupermarketArray.map((name) {
                      return CupertinoActionSheetAction(
                        onPressed: () {
                          ref
                              .read(supermarketsListProvider.notifier)
                              .addSupermarket(name);
                          Navigator.of(context).pop();
                        },
                        child: Text(name),
                      );
                    }).toList(),
                    cancelButton: CupertinoActionSheetAction(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(AppLocalizations.of(context)!.cancel),
                    ),
                  );
                },
              )
            : showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    child: SizedBox(
                      height: 400,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              AppLocalizations.of(context)!.selectSupermarket,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: addSupermarketArray.length,
                              itemBuilder: (context, index) {
                                final name = addSupermarketArray[index];
                                return ListTile(
                                  leading: Image.asset('assets/images/$name.png',
                                      width: 50, height: 50),
                                  title: Text(name),
                                  onTap: () {
                                    ref
                                        .read(supermarketsListProvider.notifier)
                                        .addSupermarket(name);
                                    Navigator.of(context).pop();
                                  },
                                );
                              },
                            ),
                          ),
                          TextButton(
                            child: Text(AppLocalizations.of(context)!.close),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
      },
      child: Card(
        elevation: 4,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add,
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.addSupermarket,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToSupermarket(
      BuildContext context, String supermarketName, WidgetRef ref) {
    ref.read(supermarketProvider.notifier).setSupermarket(supermarketName);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SupermarketScreen(),
      ),
    );
  }
}
