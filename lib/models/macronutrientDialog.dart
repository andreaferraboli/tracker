import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tracker/l10n/app_localizations.dart';

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
    final localizations = AppLocalizations.of(context)!;

    return Platform.isIOS
        ? CupertinoAlertDialog(
      title: Text(localizations.edit_macronutrient),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoPicker(
            itemExtent: 40.0,
            onSelectedItemChanged: (index) {
              setState(() {
                editedName = widget.macronutrientsArray[index];
              });
            },
            children: widget.macronutrientsArray.map((nutrient) {
              return Text(localizations.getNutrientString(nutrient));
            }).toList(),
          ),
          CupertinoTextField(
            placeholder: localizations.edit_value_100g,
            controller: _valueController,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              editedValue = value;
            },
          ),
        ],
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(localizations.cancel),
        ),
        CupertinoDialogAction(
          onPressed: () {
            widget.onSave(
              widget.initialName,
              editedName,
              double.tryParse(editedValue) ?? 0.0,
            );
            Navigator.of(context).pop();
          },
          child: Text(localizations.save),
        ),
      ],
    )
        : AlertDialog(
      title: Text(localizations.edit_macronutrient),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: localizations.change_name_to,
            ),
            value: widget.macronutrientsArray.contains(editedName)
                ? editedName
                : widget.macronutrientsArray[0],
            items: widget.macronutrientsArray.map((nutrient) {
              return DropdownMenuItem<String>(
                value: nutrient,
                child: Text(localizations.getNutrientString(nutrient)),
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
              labelText: localizations.edit_value_100g,
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
          child: Text(localizations.cancel),
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
          child: Text(localizations.save),
        ),
      ],
    );
  }
}
