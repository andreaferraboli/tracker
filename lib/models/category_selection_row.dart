import 'package:flutter/material.dart';
import 'package:tracker/services/category_services.dart';
import '../models/meal_type.dart';

class CategorySelectionRow extends StatefulWidget {
  final MealType mealType;
  final List<String> categories;
  final Function(List<String>)? onCategoriesUpdated;

  const CategorySelectionRow({
    Key? key,
    required this.mealType,
    required this.onCategoriesUpdated,
    required this.categories,
  }) : super(key: key);

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
    List<String> availableCategories =
        await CategoryServices.getCategoryNames();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Personalizza categorie'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: availableCategories.map((category) {
                  return CheckboxListTile(
                    title: Text(category),
                    value: selectedCategories.contains(category),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          // Aggiungi categoria
                          if (selectedCategories.length < 4) {
                            selectedCategories.add(category);
                          }
                        } else {
                          // Rimuovi categoria
                          selectedCategories.remove(category);
                        }
                      });
                    },
                  );
                }).toList(),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  widget.onCategoriesUpdated?.call(selectedCategories);
                });
                Navigator.of(context).pop();
              },
              child: const Text('Salva'),
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
            spacing: 4.0, // Spazio orizzontale tra i Chip
            runSpacing: 4.0, // Spazio verticale tra le righe di Chip
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            children: selectedCategories.map((category) {
              return Chip(
                label: Text(category),
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
              tooltip: 'Personalizza Categorie',
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.redAccent),
              onPressed: _clearCategories,
              tooltip: 'Rimuovi tutte le categorie',
            ),
          ],
        ),
      ],
    );
  }
}
