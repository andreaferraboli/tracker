import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Importa AppLocalizations
import 'package:tracker/l10n/app_localizations.dart';
import 'package:tracker/models/macronutrientDialog.dart';

class MacronutrientTable extends StatefulWidget {
  final void Function(Map<String, double>) onSave;

  Map<String, double>? macronutrients;

  MacronutrientTable(this.onSave, [this.macronutrients]);

  @override
  _MacronutrientTableState createState() => _MacronutrientTableState();
}

class _MacronutrientTableState extends State<MacronutrientTable> {
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

  Map<String, double> macronutrients = {};

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

  @override
  Widget build(BuildContext context) {
    final localizations =
        AppLocalizations.of(context); // Carica le stringhe localizzate

    return SizedBox(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                columnSpacing: 5,
                columns: [
                  DataColumn(
                      label: Center(child: Text(localizations!.macronutrient))),
                  DataColumn(
                      label: Center(child: Text(localizations.valueLabel))),
                  if (_isEditing)
                    DataColumn(
                        label: Center(child: Text(localizations.actions))),
                ],
                rows: macronutrients.entries.map((entry) {
                  return DataRow(
                    cells: [
                      DataCell(Center(
                          child: Text(
                              localizations.getNutrientString(entry.key)))),
                      DataCell(Center(child: Text(entry.value.toString()))),
                      if (_isEditing)
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return MacronutrientDialog(
                                        initialName: entry.key,
                                        initialValue: entry.value.toString(),
                                        macronutrientsArray:
                                            macronutrientsArray,
                                        onSave: (oldName, newName, newValue) {
                                          _editRow(oldName, newName, newValue);
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
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
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                          labelText: localizations.macronutrient),
                      value: macronutrientsArray.contains(editedName)
                          ? editedName
                          : null,
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
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
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
                    ),
                  ),
                  if (_isEditing)
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      child: IconButton(
                        onPressed: _addRow,
                        icon: const Icon(Icons.add,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = !_isEditing;
                          if (!_isEditing) widget.onSave(macronutrients);
                        });
                      },
                      icon: Icon(
                        _isEditing ? Icons.save : Icons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
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
