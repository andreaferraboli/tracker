import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tracker/l10n/app_localizations.dart';
import 'package:tracker/services/category_services.dart';
import 'dart:io';

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
    selectedCategories = widget.categories;
  }

  void _removeCategory(String category) {
    setState(() {
      selectedCategories.remove(category);
      widget.onCategoriesUpdated!(selectedCategories);
    });
  }

  void _openCustomizeCategoriesDialog() async {
    List<String> availableCategories =
        await CategoryServices.getCategoryNames();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Platform.isIOS
            ? CupertinoAlertDialog(
                title: Text(AppLocalizations.of(context)!.customizeCategories),
                content: SizedBox(
                  width: 200,
                  height: 500,
                  child: CupertinoScrollbar(
                    child: ListView(
                      shrinkWrap: true,
                      children: availableCategories.map((category) {
                        return Row(
                          children: [
                            CupertinoSwitch(
                              value: selectedCategories.contains(category),
                              onChanged: (bool value) {
                                setState(() {
                                  if (value) {
                                    if (selectedCategories.length < 4) {
                                      selectedCategories.add(category);
                                    }
                                  } else {
                                    selectedCategories.remove(category);
                                  }
                                });
                              },
                            ),
                            Text(AppLocalizations.of(context)!
                                .translateCategory(category)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
                actions: <CupertinoDialogAction>[
                  CupertinoDialogAction(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(AppLocalizations.of(context)!.cancel),
                  ),
                  CupertinoDialogAction(
                    onPressed: () {
                      setState(() {
                        widget.onCategoriesUpdated?.call(selectedCategories);
                      });
                      Navigator.of(context).pop();
                    },
                    child: Text(AppLocalizations.of(context)!.save),
                  ),
                ],
              )
            : AlertDialog(
                title: Text(AppLocalizations.of(context)!.customizeCategories),
                content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setDialogState) {
                    return SizedBox(
                      width: 200,
                      height: 500,
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
                      Navigator.of(context).pop();
                    },
                    child: Text(AppLocalizations.of(context)!.cancel),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        widget.onCategoriesUpdated?.call(selectedCategories);
                      });
                      Navigator.of(context).pop();
                    },
                    child: Text(AppLocalizations.of(context)!.save),
                  ),
                ],
              );
      },
    );
  }

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
            runSpacing: 4.0,
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
