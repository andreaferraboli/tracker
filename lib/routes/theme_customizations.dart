import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:tracker/services/app_colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Importa le localizzazioni generate

class ThemeCustomizationScreen extends StatefulWidget {
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  final Function(ThemeData) onLightThemeChanged;
  final Function(ThemeData) onDarkThemeChanged;

  const ThemeCustomizationScreen({
    super.key,
    required this.lightTheme,
    required this.darkTheme,
    required this.onLightThemeChanged,
    required this.onDarkThemeChanged,
  });

  @override
  _ThemeCustomizationScreenState createState() =>
      _ThemeCustomizationScreenState();
}

class _ThemeCustomizationScreenState extends State<ThemeCustomizationScreen> {
  late Color primaryLightColor;
  late Color onPrimaryLightColor;
  late Color secondaryLightColor;
  late Color appBarBackgroundLightColor;
  late Color appBarForegroundLightColor;
  late Color shoppingLight;
  late Color shoppingDark;
  late Color addMealLight;
  late Color addMealDark;
  late Color viewExpensesLight;
  late Color viewExpensesDark;
  late Color inventoryLight;
  late Color inventoryDark;
  late Color viewMealsLight;
  late Color viewMealsDark;
  late Color recipeTipsLight;
  late Color recipeTipsDark;
  late Color primaryDarkColor;
  late Color onPrimaryDarkColor;
  late Color secondaryDarkColor;
  late Color appBarBackgroundDarkColor;
  late Color appBarForegroundDarkColor;

  @override
  void initState() {
    super.initState();
    primaryLightColor = widget.lightTheme.colorScheme.primary;
    onPrimaryLightColor = widget.lightTheme.colorScheme.onPrimary;
    secondaryLightColor = widget.lightTheme.colorScheme.secondary;
    appBarBackgroundLightColor = widget.lightTheme.appBarTheme.backgroundColor!;
    appBarForegroundLightColor = widget.lightTheme.appBarTheme.foregroundColor!;
    shoppingLight = AppColors.shoppingLight;
    shoppingDark = AppColors.shoppingDark;
    addMealLight = AppColors.addMealLight;
    addMealDark = AppColors.addMealDark;
    viewExpensesLight = AppColors.viewExpensesLight;
    viewExpensesDark = AppColors.viewExpensesDark;
    inventoryLight = AppColors.inventoryLight;
    inventoryDark = AppColors.inventoryDark;
    viewMealsLight = AppColors.viewMealsLight;
    viewMealsDark = AppColors.viewMealsDark;
    recipeTipsLight = AppColors.recipeTipsLight;
    recipeTipsDark = AppColors.recipeTipsDark;
    primaryDarkColor = widget.darkTheme.colorScheme.primary;
    onPrimaryDarkColor = widget.darkTheme.colorScheme.onPrimary;
    secondaryDarkColor = widget.darkTheme.colorScheme.secondary;
    appBarBackgroundDarkColor = widget.darkTheme.appBarTheme.backgroundColor!;
    appBarForegroundDarkColor = widget.darkTheme.appBarTheme.foregroundColor!;
  }

  void _pickColor(Color currentColor, Function(Color) onColorChanged) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text(AppLocalizations.of(context)!.selectColor), // Localizzazione
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: (color) {
                // Aggiorniamo la variabile 'currentColor' con il colore selezionato
                setState(() {
                  currentColor = color; // Salviamo il colore selezionato
                });
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                onColorChanged(currentColor); // Passiamo il colore selezionato
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.save), // Localizzazione
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.close), // Localizzazione
            ),
          ],
        );
      },
    );
  }

  void _updateThemes() {
    AppColors.shoppingLight = shoppingLight;
    AppColors.shoppingDark = shoppingDark;
    AppColors.addMealLight = addMealLight;
    AppColors.addMealDark = addMealDark;
    AppColors.viewExpensesLight = viewExpensesLight;
    AppColors.viewExpensesDark = viewExpensesDark;
    AppColors.inventoryLight = inventoryLight;
    AppColors.inventoryDark = inventoryDark;
    AppColors.viewMealsLight = viewMealsLight;
    AppColors.viewMealsDark = viewMealsDark;
    AppColors.recipeTipsLight = recipeTipsLight;
    AppColors.recipeTipsDark = recipeTipsDark;
    AppColors.saveAllColors();
    widget.onLightThemeChanged(
      widget.lightTheme.copyWith(
        colorScheme: widget.lightTheme.colorScheme.copyWith(
          primary: primaryLightColor,
          onPrimary: onPrimaryLightColor,
          secondary: secondaryLightColor,
        ),
        appBarTheme: widget.lightTheme.appBarTheme.copyWith(
          backgroundColor: appBarBackgroundLightColor,
          foregroundColor: appBarForegroundLightColor,
        ),
        iconTheme: widget.lightTheme.iconTheme.copyWith(
          color: primaryLightColor,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryLightColor,
            foregroundColor: onPrimaryLightColor,
          ),
        ),
      ),
    );

    widget.onDarkThemeChanged(
      widget.darkTheme.copyWith(
        colorScheme: widget.darkTheme.colorScheme.copyWith(
          primary: primaryDarkColor,
          onPrimary: onPrimaryDarkColor,
          secondary: secondaryDarkColor,
        ),
        appBarTheme: widget.darkTheme.appBarTheme.copyWith(
          backgroundColor: appBarBackgroundDarkColor,
          foregroundColor: appBarForegroundDarkColor,
        ),
        iconTheme: widget.darkTheme.iconTheme.copyWith(
          color: primaryDarkColor,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryDarkColor,
            foregroundColor: onPrimaryDarkColor,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.customizeTheme,
          style:
              TextStyle(color: Theme.of(context).appBarTheme.foregroundColor),
        ), // Localizzazione
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Light Theme Customization
              Text(
                AppLocalizations.of(context)!.lightTheme, // Localizzazione
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary),
              ),
              ..._buildColorList(
                light: true,
                colors: {
                  'primary': primaryLightColor,
                  'onPrimary': onPrimaryLightColor,
                  'secondary': secondaryLightColor,
                  'appBarBackground': appBarBackgroundLightColor,
                  'appBarForeground': appBarForegroundLightColor,
                  'shopping': shoppingLight,
                  'addMeal': addMealLight,
                  'viewExpenses': viewExpensesLight,
                  'inventory': inventoryLight,
                  'viewMeals': viewMealsLight,
                  'recipeTips': recipeTipsLight,
                },
              ),
              const Divider(),

              // Dark Theme Customization
              Text(
                AppLocalizations.of(context)!.darkTheme, // Localizzazione
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary),
              ),
              ..._buildColorList(
                light: false,
                colors: {
                  'primary': primaryDarkColor,
                  'onPrimary': onPrimaryDarkColor,
                  'secondary': secondaryDarkColor,
                  'appBarBackground': appBarBackgroundDarkColor,
                  'appBarForeground': appBarForegroundDarkColor,
                  'shopping': shoppingDark,
                  'addMeal': addMealDark,
                  'viewExpenses': viewExpensesDark,
                  'inventory': inventoryDark,
                  'viewMeals': viewMealsDark,
                  'recipeTips': recipeTipsDark,
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildColorList(
      {required bool light, required Map<String, Color> colors}) {
    List<Widget> colorWidgets = [];
    colors.forEach((key, color) {
      colorWidgets.add(
        ListTile(
          title: Text(AppLocalizations.of(context)!
              .colorLabel(key)), // Localizzazione dinamica
          trailing: GestureDetector(
            onTap: () => _pickColor(color, (newColor) {
              setState(() {
                if (light) {
                  _updateLightColor(key, newColor);
                } else {
                  _updateDarkColor(key, newColor);
                }
              });
              _updateThemes();
            }),
            child: CircleAvatar(backgroundColor: color),
          ),
        ),
      );
    });
    return colorWidgets;
  }

  void _updateLightColor(String key, Color color) {
    switch (key) {
      case 'primary':
        primaryLightColor = color;
        break;
      case 'onPrimary':
        onPrimaryLightColor = color;
        break;
      case 'secondary':
        secondaryLightColor = color;
        break;
      case 'appBarBackground':
        appBarBackgroundLightColor = color;
      case 'appBarForeground':
        appBarForegroundLightColor = color;
      case 'shopping':
        shoppingLight = color;
      case 'addMeal':
        addMealLight = color;
      case 'viewExpenses':
        viewExpensesLight = color;
      case 'inventory':
        inventoryLight = color;
      case 'viewMeals':
        viewMealsLight = color;
      case 'recipeTips':
        recipeTipsLight = color;
        break;
    }
  }

  void _updateDarkColor(String key, Color color) {
    switch (key) {
      case 'primary':
        primaryDarkColor = color;
        break;
      case 'onPrimary':
        onPrimaryDarkColor = color;
        break;
      case 'secondary':
        secondaryDarkColor = color;
        break;
      case 'appBarBackground':
        appBarBackgroundDarkColor = color;
      case 'appBarForeground':
        appBarForegroundDarkColor = color;
      case 'shopping':
        shoppingDark = color;
      case 'addMeal':
        addMealDark = color;
      case 'viewExpenses':
        viewExpensesDark = color;
      case 'inventory':
        inventoryDark = color;
      case 'viewMeals':
        viewMealsDark = color;
      case 'recipeTips':
        recipeTipsDark = color;
        break;
    }
  }
}
