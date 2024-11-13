import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:tracker/services/app_colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  @override
  void initState() {
    super.initState();
  }

  void _pickColor(Color currentColor, Function(Color) onColorChanged) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.selectColor),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: (color) {
                setState(() {
                  currentColor = color;
                });
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                onColorChanged(currentColor);
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.close),
            ),
          ],
        );
      },
    );
  }

  void _updateThemes() {
    AppColors.saveAllColors();
    widget.onLightThemeChanged(
      widget.lightTheme.copyWith(
        colorScheme: widget.lightTheme.colorScheme.copyWith(
          primary: AppColors.primaryLight,
          onPrimary: AppColors.onPrimaryLight,
          secondary: AppColors.secondaryLight,
        ),
        appBarTheme: widget.lightTheme.appBarTheme.copyWith(
          backgroundColor: AppColors.appBarBackgroundLight,
          foregroundColor: AppColors.appBarForegroundLight,
        ),
        iconTheme: widget.lightTheme.iconTheme.copyWith(
          color: AppColors.primaryLight,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryLight,
            foregroundColor: AppColors.onPrimaryLight,
          ),
        ),
      ),
    );

    widget.onDarkThemeChanged(
      widget.darkTheme.copyWith(
        colorScheme: widget.darkTheme.colorScheme.copyWith(
          primary: AppColors.primaryDark,
          onPrimary: AppColors.onPrimaryDark,
          secondary: AppColors.secondaryDark,
        ),
        appBarTheme: widget.darkTheme.appBarTheme.copyWith(
          backgroundColor: AppColors.appBarBackgroundDark,
          foregroundColor: AppColors.appBarForegroundDark,
        ),
        iconTheme: widget.darkTheme.iconTheme.copyWith(
          color: AppColors.primaryDark,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: AppColors.onPrimaryDark,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.customizeTheme),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              _updateThemes();
              Navigator.of(context).pop('reset');
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            color: Colors.red,
            onPressed: () {
              AppColors.resetAllColors();
              _updateThemes();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Personalizzazione tema chiaro
              Text(AppLocalizations.of(context)!.lightTheme),
              ..._buildColorList(
                light: true,
                colors: {
                  'primary': AppColors.primaryLight,
                  'onPrimary': AppColors.onPrimaryLight,
                  'secondary': AppColors.secondaryLight,
                  'appBarBackground': AppColors.appBarBackgroundLight,
                  'appBarForeground': AppColors.appBarForegroundLight,
                  'shopping': AppColors.shoppingLight,
                  'addMeal': AppColors.addMealLight,
                  'viewExpenses': AppColors.viewExpensesLight,
                  'inventory': AppColors.inventoryLight,
                  'viewMeals': AppColors.viewMealsLight,
                  'recipeTips': AppColors.recipeTipsLight,
                },
              ),
              const Divider(),
              // Personalizzazione tema scuro
              Text(AppLocalizations.of(context)!.darkTheme),
              ..._buildColorList(
                light: false,
                colors: {
                  'primary': AppColors.primaryDark,
                  'onPrimary': AppColors.onPrimaryDark,
                  'secondary': AppColors.secondaryDark,
                  'appBarBackground': AppColors.appBarBackgroundDark,
                  'appBarForeground': AppColors.appBarForegroundDark,
                  'shopping': AppColors.shoppingDark,
                  'addMeal': AppColors.addMealDark,
                  'viewExpenses': AppColors.viewExpensesDark,
                  'inventory': AppColors.inventoryDark,
                  'viewMeals': AppColors.viewMealsDark,
                  'recipeTips': AppColors.recipeTipsDark,
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
          title: Text(AppLocalizations.of(context)!.colorLabel(key)),
          trailing: GestureDetector(
            onTap: () => _pickColor(color, (newColor) {
              setState(() {
                if (light) {
                  _updateLightColor(key, newColor);
                } else {
                  _updateDarkColor(key, newColor);
                }
              });
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
        AppColors.primaryLight = color;
        break;
      case 'onPrimary':
        AppColors.onPrimaryLight = color;
        break;
      case 'secondary':
        AppColors.secondaryLight = color;
        break;
      case 'appBarBackground':
        AppColors.appBarBackgroundLight = color;
        break;
      case 'appBarForeground':
        AppColors.appBarForegroundLight = color;
        break;
      case 'shopping':
        AppColors.shoppingLight = color;
        break;
      case 'addMeal':
        AppColors.addMealLight = color;
        break;
      case 'viewExpenses':
        AppColors.viewExpensesLight = color;
        break;
      case 'inventory':
        AppColors.inventoryLight = color;
        break;
      case 'viewMeals':
        AppColors.viewMealsLight = color;
        break;
      case 'recipeTips':
        AppColors.recipeTipsLight = color;
        break;
    }
  }

  void _updateDarkColor(String key, Color color) {
    switch (key) {
      case 'primary':
        AppColors.primaryDark = color;
        break;
      case 'onPrimary':
        AppColors.onPrimaryDark = color;
        break;
      case 'secondary':
        AppColors.secondaryDark = color;
        break;
      case 'appBarBackground':
        AppColors.appBarBackgroundDark = color;
        break;
      case 'appBarForeground':
        AppColors.appBarForegroundDark = color;
        break;
      case 'shopping':
        AppColors.shoppingDark = color;
        break;
      case 'addMeal':
        AppColors.addMealDark = color;
        break;
      case 'viewExpenses':
        AppColors.viewExpensesDark = color;
        break;
      case 'inventory':
        AppColors.inventoryDark = color;
        break;
      case 'viewMeals':
        AppColors.viewMealsDark = color;
        break;
      case 'recipeTips':
        AppColors.recipeTipsDark = color;
        break;
    }
  }
}
