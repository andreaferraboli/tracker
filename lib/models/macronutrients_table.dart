import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tracker/l10n/app_localizations.dart';
import 'package:tracker/models/macronutrient_dialog.dart';

class MacronutrientTable extends StatefulWidget {
  final void Function(Map<String, double>) onSave;
  final Map<String, double>? macronutrients;

  const MacronutrientTable(this.onSave, [this.macronutrients]);

  @override
  MacronutrientTableState createState() => MacronutrientTableState();
}

class MacronutrientTableState extends State<MacronutrientTable> {
  bool _isEditing = false;
  String editedValue = "";
  late String editedName;
  late TextEditingController valueController;

  List<String> macronutrientsArray = [
    "Energy",
    "Fats",
    "Proteins",
    "Carbohydrates",
    "Sugars",
    "Fiber",
    "Saturated Fats",
    "Monounsaturated Fats",
    "Polyunsaturated Fats",
    "Cholesterol",
    "Sodium"
  ];

  Map<String, double> macronutrients = <String, double>{};

  @override
  void initState() {
    super.initState();
    if (widget.macronutrients != null) {
      macronutrients = widget.macronutrients!;
      macronutrients.forEach((key, value) {
        macronutrientsArray.remove(key);
      });
    }
    editedName = macronutrientsArray.isNotEmpty ? macronutrientsArray[0] : '';
    valueController = TextEditingController(text: editedValue);
  }

  @override
  void dispose() {
    valueController.dispose();
    super.dispose();
  }

  void _addRow() {
    if (editedName.isNotEmpty && editedValue.isNotEmpty) {
      setState(() {
        macronutrients[editedName] = double.tryParse(editedValue) ?? 0.0;
        macronutrientsArray.remove(editedName);
        if (macronutrientsArray.isNotEmpty) {
          editedName = macronutrientsArray[0];
        }
        editedValue = '';
        valueController.clear();
      });
    }
  }

  void _editRow(String key, String newName, double newValue) {
    setState(() {
      macronutrients.remove(key);
      macronutrients[newName] = newValue;
      macronutrientsArray.add(key);
      macronutrientsArray.remove(newName);
      editedName = macronutrientsArray.isNotEmpty ? macronutrientsArray[0] : '';
    });
  }

  void _deleteRow(String key) {
    setState(() {
      macronutrients.remove(key);
      macronutrientsArray.add(key);
      if (macronutrientsArray.isNotEmpty) {
        editedName = macronutrientsArray[0];
      }
    });
  }

  Widget _buildPlatformTextField(AppLocalizations localizations) {
    if (Platform.isIOS) {
      return CupertinoTextField(
        controller: valueController,
        keyboardType: TextInputType.number,
        placeholder: localizations.valueLabel,
        style: const TextStyle(fontSize: 18),
        onChanged: (value) {
          editedValue = value.replaceAll(",", ".");
        },
      );
    } else {
      return TextField(
        decoration: InputDecoration(
          labelText: localizations.valueLabel,
          labelStyle: const TextStyle(fontSize: 14),
        ),
        controller: valueController,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 18),
        onChanged: (value) {
          editedValue = value.replaceAll(",", ".");
        },
      );
    }
  }

  Widget _buildPlatformDropdown(AppLocalizations localizations) {
    if (Platform.isIOS) {
      return SizedBox(
        height: 40,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            showCupertinoModalPopup(
              context: context,
              builder: (BuildContext context) {
                return Container(
                  height: 200,
                  color: CupertinoColors.systemBackground.resolveFrom(context),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CupertinoButton(
                              child: Text(localizations.cancel),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            CupertinoButton(
                              child: Text(localizations.save),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: CupertinoPicker(
                          itemExtent: 32,
                          onSelectedItemChanged: (index) {
                            setState(() {
                              editedName = macronutrientsArray[index];
                            });
                          },
                          children: macronutrientsArray.map((nutrient) {
                            return Text(
                              localizations.getNutrientString(nutrient),
                              style: const TextStyle(fontSize: 14),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          child: Text(
            localizations.getNutrientString(editedName),
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    } else {
      return DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: localizations.macronutrient),
        value: macronutrientsArray.contains(editedName) ? editedName : null,
        items: macronutrientsArray.map((nutrient) {
          return DropdownMenuItem<String>(
            value: nutrient,
            child: Text(
              localizations.getNutrientString(nutrient),
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            editedName = newValue ?? '';
          });
        },
      );
    }
  }

  Widget _buildActionButton(
      IconData icon, VoidCallback onPressed, Color color) {
    if (Platform.isIOS) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: Icon(icon, color: color),
      );
    } else {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.primary,
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white, size: 20),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return SizedBox(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Platform.isIOS
                  ? CupertinoListSection(
                      children: macronutrients.entries.map((entry) {
                        return CupertinoListTile(
                          title:
                              Text(localizations!.getNutrientString(entry.key)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(entry.value.toString()),
                              if (_isEditing) ...[
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    showCupertinoDialog(
                                      context: context,
                                      builder: (context) => MacronutrientDialog(
                                        initialName: entry.key,
                                        initialValue: entry.value.toString(),
                                        macronutrientsArray:
                                            macronutrientsArray,
                                        onSave: (oldName, newName, newValue) {
                                          _editRow(oldName, newName, newValue);
                                        },
                                      ),
                                    );
                                  },
                                  child: const Icon(CupertinoIcons.pencil,
                                      color: CupertinoColors.activeBlue),
                                ),
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () => _deleteRow(entry.key),
                                  child: const Icon(CupertinoIcons.delete,
                                      color: CupertinoColors.destructiveRed),
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    )
                  : DataTable(
                      columnSpacing: 5,
                      columns: [
                        DataColumn(
                            label: Center(
                                child: Text(localizations!.macronutrient))),
                        DataColumn(
                            label:
                                Center(child: Text(localizations.valueLabel))),
                        if (_isEditing)
                          DataColumn(
                              label:
                                  Center(child: Text(localizations.actions))),
                      ],
                      rows: macronutrients.entries.map((entry) {
                        return DataRow(
                          cells: [
                            DataCell(Center(
                                child: Text(localizations
                                    .getNutrientString(entry.key)))),
                            DataCell(
                                Center(child: Text(entry.value.toString()))),
                            if (_isEditing)
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return MacronutrientDialog(
                                              initialName: entry.key,
                                              initialValue:
                                                  entry.value.toString(),
                                              macronutrientsArray:
                                                  macronutrientsArray,
                                              onSave:
                                                  (oldName, newName, newValue) {
                                                _editRow(
                                                    oldName, newName, newValue);
                                              },
                                            );
                                          },
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () {
                                        _deleteRow(entry.key);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        );
                      }).toList(),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildPlatformDropdown(localizations!),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPlatformTextField(localizations),
                  ),
                  if (_isEditing)
                    _buildActionButton(
                      Platform.isIOS ? CupertinoIcons.add : Icons.add,
                      _addRow,
                      Platform.isIOS
                          ? CupertinoColors.activeBlue
                          : Theme.of(context).colorScheme.primary,
                    ),
                  _buildActionButton(
                    Platform.isIOS
                        ? (_isEditing
                            ? CupertinoIcons.check_mark
                            : CupertinoIcons.pencil)
                        : (_isEditing ? Icons.save : Icons.edit),
                    () {
                      setState(() {
                        _isEditing = !_isEditing;
                        if (!_isEditing) widget.onSave(macronutrients);
                      });
                    },
                    Platform.isIOS
                        ? CupertinoColors.activeBlue
                        : Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
