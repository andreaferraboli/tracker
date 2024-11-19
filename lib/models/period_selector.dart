import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Importa Cupertino per iOS
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Importa il file generato con le stringhe

class PeriodSelector extends StatelessWidget {
  final String selectedPeriod;
  final ValueChanged onPeriodChanged;
  final VoidCallback onPreviousPeriod;
  final VoidCallback onNextPeriod;
  final VoidCallback onSelectDate;

  const PeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    required this.onPreviousPeriod,
    required this.onNextPeriod,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    // Verifica la piattaforma per adattare la UI
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Pulsante precedente
        if (isIOS)
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.arrow_left),
            onPressed: onPreviousPeriod,
          )
        else
          ElevatedButton(
            child: const Icon(Icons.arrow_back),
            onPressed: onPreviousPeriod,
          ),

        // Dropdown per selezionare il periodo
        if (isIOS)
          CupertinoPicker(
            itemExtent: 32.0,
            onSelectedItemChanged: (index) {
              onPeriodChanged(['week', 'month', 'year'][index]);
            },
            children: [
              Text(AppLocalizations.of(context)!.week),
              Text(AppLocalizations.of(context)!.month),
              Text(AppLocalizations.of(context)!.year),
            ],
          )
        else
          DropdownButton<String>(
            value: selectedPeriod,
            items: [
              DropdownMenuItem(
                  value: 'week', child: Text(AppLocalizations.of(context)!.week)),
              DropdownMenuItem(
                  value: 'month', child: Text(AppLocalizations.of(context)!.month)),
              DropdownMenuItem(
                  value: 'year', child: Text(AppLocalizations.of(context)!.year)),
            ],
            onChanged: onPeriodChanged,
          ),

        // Pulsante per selezionare la data
        if (isIOS)
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.calendar),
            onPressed: onSelectDate,
          )
        else
          ElevatedButton(
            onPressed: onSelectDate,
            child: const Icon(Icons.calendar_today),
          ),

        // Pulsante successivo
        if (isIOS)
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.arrow_right),
            onPressed: onNextPeriod,
          )
        else
          ElevatedButton(
            child: const Icon(Icons.arrow_forward),
            onPressed: onNextPeriod,
          ),
      ],
    );
  }
}
