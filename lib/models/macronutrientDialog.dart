import 'package:flutter/material.dart';

class MacronutrientDialog extends StatefulWidget {
  final String initialName;
  final String initialValue;
  final List<String> macronutrientsArray;
  final Function(String oldName, String newName, double newValue) onSave;

  const MacronutrientDialog({
    super.key,
    required this.initialName,
    required this.initialValue,
    required this.macronutrientsArray,
    required this.onSave,
  });

  @override
  _MacronutrientDialogState createState() => _MacronutrientDialogState();
}

class _MacronutrientDialogState extends State<MacronutrientDialog> {
  late String editedName;
  late String editedValue;
  late TextEditingController _valueController;

  @override
  void initState() {
    super.initState();
    editedName = widget.initialName;
    editedValue = widget.initialValue;
    _valueController = TextEditingController(text: editedValue);
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Macronutrient"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'cambia nome in',
            ),
            value: widget.macronutrientsArray.contains(editedName)
                ? editedName
                : widget.macronutrientsArray[0],
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
            decoration: const InputDecoration(
              labelText: 'modifica value (100g)',
            ),
            controller: _valueController,
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
          child: const Text("Cancel"),
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
          child: const Text("Save"),
        ),
      ],
    );
  }
}
