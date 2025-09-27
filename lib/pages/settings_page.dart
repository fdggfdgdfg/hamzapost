import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/feed_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.onLocaleChanged, required this.currentLocale});

  final ValueChanged<Locale> onLocaleChanged;
  final Locale currentLocale;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _keywordController = TextEditingController();

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final supportedLocales = AppLocalizations.supportedLocales;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('settings')),
      ),
      body: Consumer<FeedProvider>(
        builder: (context, provider, _) {
          final keywords = provider.keywords;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(loc.translate('selectLanguage'), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...supportedLocales.map(
                (locale) => RadioListTile<Locale>(
                  value: locale,
                  groupValue: widget.currentLocale,
                  onChanged: (value) {
                    if (value != null) {
                      widget.onLocaleChanged(value);
                      setState(() {});
                    }
                  },
                  title: Text(locale.languageCode.toUpperCase()),
                ),
              ),
              const Divider(height: 32),
              Text(loc.translate('selectSources'), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...provider.sources.map(
                (source) => SwitchListTile(
                  value: provider.selectedSourceIds.contains(source.id),
                  onChanged: (value) => provider.toggleSource(source.id, value),
                  title: Text(source.name),
                  subtitle: Text(source.topic),
                ),
              ),
              const Divider(height: 32),
              SwitchListTile(
                value: provider.notificationsEnabled,
                onChanged: (value) => provider.setNotificationsEnabled(value),
                title: Text(loc.translate('notifications')),
              ),
              const SizedBox(height: 8),
              Text(loc.translate('notificationKeywords'), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _keywordController,
                      decoration: InputDecoration(hintText: loc.translate('addKeywordHint')),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final value = _keywordController.text.trim();
                      if (value.isNotEmpty) {
                        provider.setKeywords([...keywords, value]);
                        _keywordController.clear();
                      }
                    },
                    child: Text(loc.translate('add')),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (keywords.isEmpty)
                Text(loc.translate('keywordListEmpty'))
              else
                Wrap(
                  spacing: 8,
                  children: keywords
                      .map(
                        (keyword) => Chip(
                          label: Text(keyword),
                          onDeleted: () {
                            final updated = [...keywords]..remove(keyword);
                            provider.setKeywords(updated);
                          },
                        ),
                      )
                      .toList(),
                ),
              const SizedBox(height: 24),
              Text(loc.translate('privacyPolicy'), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(loc.translate('privacyContent')),
              const SizedBox(height: 16),
              Text(loc.translate('legalNotice'), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(loc.translate('legalContent')),
            ],
          );
        },
      ),
    );
  }
}
