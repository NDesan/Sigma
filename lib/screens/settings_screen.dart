import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/translation_service.dart';
import '../services/tr.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('settings')),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Text(context.tr('language'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Consumer<TranslationService>(
            builder: (context, ts, _) {
              final locales = [
                (const Locale('fr'), '🇫🇷', 'Français'),
                (const Locale('en'), '🇬🇧', 'English'),
                (const Locale('de'), '🇩🇪', 'Deutsch'),
                (const Locale('es'), '🇪🇸', 'Español'),
                (const Locale('it'), '🇮🇹', 'Italiano'),
              ];
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: locales.map((l) {
                  final selected = ts.locale.languageCode == l.$1.languageCode;
                  return ChoiceChip(
                    selected: selected,
                    label: Text('${l.$2} ${l.$3}'),
                    onSelected: (_) => ts.setLocale(l.$1),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
