import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Importa il file generato con le stringhe

class PeriodSelector extends StatelessWidget {
  final String selectedPeriod;
  final ValueChanged<String?> onPeriodChanged;
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          child: const Icon(Icons.arrow_back),
          onPressed: onPreviousPeriod,
        ),
        DropdownButton<String>(
          value: selectedPeriod,
          items: [
            DropdownMenuItem(value: 'week', child: Text(AppLocalizations.of(context)!.week)),
            DropdownMenuItem(value: 'month', child: Text(AppLocalizations.of(context)!.month)),
            DropdownMenuItem(value: 'year', child: Text(AppLocalizations.of(context)!.year)),
          ],
          onChanged: onPeriodChanged,
        ),
        ElevatedButton(
          onPressed: onSelectDate,
          child: const Icon(Icons.calendar_today),
        ),
        ElevatedButton(
          child: const Icon(Icons.arrow_forward),
          onPressed: onNextPeriod,
        ),
      ],
    );
  }
}
