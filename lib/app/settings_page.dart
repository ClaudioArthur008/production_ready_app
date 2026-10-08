import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'shared_widgets.dart';
import 'strings.dart';

/// Screen for changing Mora's language and visual appearance.
class SettingsPage extends StatelessWidget {
  /// Creates the settings screen.
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => Selector<AppState, (Locale, ThemeMode)>(
    selector: (_, state) => (state.locale, state.themeMode),
    builder: (context, preferences, _) =>
        _SettingsContent(locale: preferences.$1, themeMode: preferences.$2),
  );
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent({required this.locale, required this.themeMode});

  final Locale locale;
  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    final s = MoraStrings(Localizations.localeOf(context));
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      children: [
        Text(
          s.get('settings'),
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const _SettingIcon(icon: Icons.language_rounded),
                title: Text(s.get('language')),
                subtitle: Text(
                  locale.languageCode == 'fr'
                      ? s.get('french')
                      : s.get('english'),
                ),
                trailing: DropdownButton<Locale>(
                  value: locale,
                  underline: const SizedBox.shrink(),
                  onChanged: (value) {
                    if (value != null) {
                      context.read<AppState>().setLanguage(value);
                    }
                  },
                  items: [
                    DropdownMenuItem(
                      value: const Locale('fr'),
                      child: Text(s.get('french')),
                    ),
                    DropdownMenuItem(
                      value: const Locale('en'),
                      child: Text(s.get('english')),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, indent: 68),
              SwitchListTile(
                secondary: const _SettingIcon(icon: Icons.dark_mode_outlined),
                title: Text(s.get('darkMode')),
                subtitle: Text(s.get('darkModeHint')),
                value: themeMode == ThemeMode.dark,
                onChanged: context.read<AppState>().setDarkMode,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const _SettingIcon(
                  icon: Icons.currency_exchange_rounded,
                ),
                title: Text(s.get('currency')),
                subtitle: const Text('MGA · Ar'),
              ),
              const Divider(height: 1, indent: 68),
              ListTile(
                leading: const _SettingIcon(icon: Icons.shield_outlined),
                title: Text(s.get('privacy')),
                subtitle: Text(s.get('offline')),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Center(
          child: Text(
            'Mora · 1.0.0',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: moraMuted),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            '${s.get('sampleData')}: ${s.get('sampleHint')}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: moraMuted),
          ),
        ),
      ],
    );
  }
}

class _SettingIcon extends StatelessWidget {
  const _SettingIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: 20,
    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    child: Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
  );
}
