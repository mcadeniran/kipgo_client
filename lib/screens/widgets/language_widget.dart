import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kipgo/controllers/locale_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/l10n/l10n.dart';

class LanguageWidget extends StatelessWidget {
  const LanguageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.language, size: 26),
      tooltip: AppLocalizations.of(context)!.language,
      onPressed: () => _openLanguageSheet(context),
    );
  }

  void _openLanguageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const _LanguageSheet(),
    );
  }
}

class _LanguageSheet extends StatelessWidget {
  const _LanguageSheet();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context);
    final currentLocale = provider.locale;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppLocalizations.of(context)!.changeLanguage,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          ...L10n.all.map((locale) {
            final flag = L10n.getFlag(locale.languageCode);
            final text = locale.languageCode == 'ru'
                ? AppLocalizations.of(context)!.englishRussian
                : locale.languageCode == 'tr'
                ? AppLocalizations.of(context)!.englishTurkish
                : AppLocalizations.of(context)!.englishEnglish;

            final isSelected = locale == currentLocale;

            return ListTile(
              leading: Text(flag, style: const TextStyle(fontSize: 24)),
              title: Text(text),
              trailing: isSelected
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                provider.setLocale(locale, context);
                Navigator.pop(context); // close sheet
              },
            );
          }),
        ],
      ),
    );
  }
}
