import 'package:flutter/material.dart';
import 'package:tracker/models/macronutrientDialog.dart';

class MacronutrientTable extends StatefulWidget {
  final void Function(Map<String, double>) onSave;

  Map<String, double>? macronutrients;

  MacronutrientTable(this.onSave, this.macronutrients);

  @override
  _MacronutrientTableState createState() => _MacronutrientTableState();
}

class _MacronutrientTableState extends State<MacronutrientTable> {
  bool _isEditing = false;
  String editedValue = "";
  late String editedName;
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
      //togli da macronutrientsArray i valori che sono già presenti in macronutrients
      macronutrients.forEach((key, value) {
        macronutrientsArray.remove(key);
      });
    }
    editedName = macronutrientsArray[0];
  }

  // Add a new row
  void _addRow() {
    setState(() {
      macronutrients[editedName] =
          editedValue.isNotEmpty ? double.parse(editedValue) : 0.0;
      macronutrientsArray.remove(editedName);
      editedName = macronutrientsArray[0];
    });
  }

  // Edit a specific row
  void _editRow(String key, String newName, double newValue) {
    setState(() {
      macronutrients.remove(key);
      macronutrients[newName] = newValue;
    });
  }

  // Delete a specific row
  void _deleteRow(String key) {
    setState(() {
      macronutrients.remove(key);
      macronutrientsArray.add(key);
      editedName = macronutrientsArray[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Bottone per aggiungere una riga
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Macronutrient')),
                  DataColumn(label: Text('Value(100g)')),
                  if (_isEditing) DataColumn(label: Text('Actions')),
                ],
                rows: macronutrients.entries.map((entry) {
                  return DataRow(
                    cells: [
                      DataCell(Text(entry.key)),
                      DataCell(Text(entry.value.toString())),
                      if (_isEditing)
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  // Funzionalità di modifica con dialogo
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return MacronutrientDialog(
                                        initialName: entry.key,
                                        initialValue: entry.value.toString(),
                                        macronutrientsArray:
                                            macronutrientsArray,
                                        // L'array di macronutrienti
                                        onSave: (oldName, newName, newValue) {
                                          _editRow(oldName, newName, newValue);
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
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
                    flex: 2, // Aumenta la larghezza del DropdownButtonFormField
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Name',
                      ),
                      value: editedName,
                      items: macronutrientsArray.map((nutrient) {
                        return DropdownMenuItem<String>(
                          value: nutrient,
                          child: Text(
                            nutrient,
                            style: TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          editedName = newValue!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Value(100g)',
                        labelStyle: TextStyle(
                            fontSize: 14), // Diminuisce la dimensione del font
                      ),
                      controller: TextEditingController(text: editedValue),
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: 18),
                      // Diminuisce la dimensione del font
                      onChanged: (value) {
                        value = value.replaceAll(",", ".");
                        editedValue = value;
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
                        icon: Icon(Icons.add, color: Colors.white, size: 20),
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
