import 'package:flutter/material.dart';

class MacronutrientDialog extends StatefulWidget {
  final String initialName;
  final String initialValue;
  final List<String> macronutrientsArray;
  final Function(String oldName, String newName, double newValue) onSave;

  const MacronutrientDialog({
    Key? key,
    required this.initialName,
    required this.initialValue,
    required this.macronutrientsArray,
    required this.onSave,
  }) : super(key: key);

  @override
  _MacronutrientDialogState createState() => _MacronutrientDialogState();
}

class _MacronutrientDialogState extends State<MacronutrientDialog> {
  late String editedName;
  late String editedValue;

  @override
  void initState() {
    super.initState();
    editedName = widget.initialName;
    editedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Edit Macronutrient"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Name',
            ),
            value: editedName,
            items: widget.macronutrientsArray.map((nutrient) {
              return DropdownMenuItem<String>(
                value: nutrient,
                child: Text(nutrient),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                editedName = newValue!;
              });
            },
          ),
          TextField(
            decoration: InputDecoration(
              labelText: 'Value(100g)',
            ),
            controller: TextEditingController(text: editedValue),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              editedValue = value;
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(
              widget.initialName,
              editedName,
              double.tryParse(editedValue) ?? 0.0,
            );
            Navigator.of(context).pop();
          },
          child: Text("Save"),
        ),
      ],
    );
  }
}
