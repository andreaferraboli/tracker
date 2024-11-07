import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tracker/l10n/app_localizations.dart';
import 'package:tracker/services/category_services.dart';

import '../models/meal_type.dart';

class CategorySelectionRow extends StatefulWidget {
  final MealType mealType;
  final List<String> categories;
  final Function(List<String>)? onCategoriesUpdated;

  const CategorySelectionRow({
    super.key,
    required this.mealType,
    required this.onCategoriesUpdated,
    required this.categories,
  });

  @override
  _CategorySelectionRowState createState() => _CategorySelectionRowState();
}

class _CategorySelectionRowState extends State<CategorySelectionRow> {
  List<String> selectedCategories = [];

  @override
  void initState() {
    super.initState();
    // Carica le categorie predefinite in base al tipo di pasto selezionato
    selectedCategories = widget.categories;
  }

  void _removeCategory(String category) {
    setState(() {
      selectedCategories.remove(category);
      widget.onCategoriesUpdated!(selectedCategories);
    });
  }

  // Funzione per aprire il dialog di personalizzazione delle categorie
  void _openCustomizeCategoriesDialog() async {
    // Recupera le categorie disponibili
    List<String> availableCategories =
        await CategoryServices.getCategoryNames();

    // Mostra il dialogo
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.customizeCategories),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
              return Container(
                width: 200, // Imposta una larghezza fissa
                height: 500, // Imposta un'altezza fissa
                child: ListView(
                  shrinkWrap: true,
                  children: availableCategories.map((category) {
                    return CheckboxListTile(
                      title: Text(
                        AppLocalizations.of(context)!
                            .translateCategory(category),
                      ),
                      value: selectedCategories.contains(category),
                      onChanged: (bool? value) {
                        setDialogState(() {
                          if (value == true) {
                            if (selectedCategories.length < 4) {
                              selectedCategories.add(category);
                            }
                          } else {
                            selectedCategories.remove(category);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Chiudi il dialogo senza salvare
              },
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                // Aggiorna le categorie selezionate nel widget principale
                setState(() {
                  widget.onCategoriesUpdated?.call(selectedCategories);
                });
                Navigator.of(context).pop(); // Chiudi il dialogo e salva
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        );
      },
    );
  }

  // Funzione per rimuovere tutte le categorie selezionate
  void _clearCategories() {
    setState(() {
      selectedCategories.clear();
      widget.onCategoriesUpdated?.call(selectedCategories);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Wrap(
            spacing: 4.0,
            // Spazio orizzontale tra i Chip
            runSpacing: 4.0,
            // Spazio verticale tra le righe di Chip
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            children: selectedCategories.map((category) {
              return Chip(
                label: Text(
                    AppLocalizations.of(context)!.translateCategory(category)),
                backgroundColor: Colors.blueAccent.withOpacity(0.2),
                onDeleted: () => _removeCategory(category),
              );
            }).toList(),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Theme.of(context).iconTheme.color),
              onPressed: _openCustomizeCategoriesDialog,
              tooltip: AppLocalizations.of(context)!.customizeCategories,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: _clearCategories,
              tooltip: AppLocalizations.of(context)!.removeAllCategories,
            ),
          ],
        ),
      ],
    );
  }
}
