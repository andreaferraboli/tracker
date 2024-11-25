import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tracker/main.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.language),
      ),
      body: ListView(
        children: [
          _buildLanguageOption(
            context,
            'Italiano',
            'it',
            const AssetImage('assets/flags/it.png'),
          ),
          _buildLanguageOption(
            context,
            'English',
            'en',
            const AssetImage('assets/flags/en.png'),
          ),
          _buildLanguageOption(
            context,
            'Français',
            'fr',
            const AssetImage('assets/flags/fr.png'),
          ),
          _buildLanguageOption(
            context,
            'Español',
            'es',
            const AssetImage('assets/flags/es.png'),
          ),
          _buildLanguageOption(
            context,
            'Deutsch',
            'de',
            const AssetImage('assets/flags/de.png'),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String languageName,
    String languageCode,
    ImageProvider flagImage,
  ) {
    final currentLocale = Localizations.localeOf(context);
    final isSelected = currentLocale.languageCode == languageCode;

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: flagImage,
      ),
      title: Text(languageName),
      trailing: isSelected
          ? const Icon(Icons.check, color: Colors.green)
          : null,
      onTap: () {
        MyApp.setLocale(context, Locale(languageCode));
        Navigator.pop(context);
      },
    );
  }
}
