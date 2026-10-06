import 'package:flutter/material.dart';

import '../domain/budget.dart';
import 'app_state.dart';
import 'shared_widgets.dart';
import 'strings.dart';

class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key, required this.state});
  final AppState state;
  @override
  Widget build(BuildContext context) {
    final s = MoraStrings(Localizations.localeOf(context));
    final expenses = BudgetMath.total(state.monthEntries, EntryType.expense);
    final categories =
        BudgetCategory.values
            .map(
              (c) =>
                  MapEntry(c, BudgetMath.categoryTotal(state.monthEntries, c)),
            )
            .where((e) => e.value > 0)
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    final maximum = categories.isEmpty ? 0 : categories.first.value;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      children: [
        Text(
          s.get('monthlySummary'),
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                const CircleAvatar(child: Icon(Icons.north_east_rounded)),
                const SizedBox(width: 12),
                Expanded(child: Text(s.get('expense'))),
                Text(
                  s.amount(expenses),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        SectionTitle(title: s.get('weeklySpending'), trailing: s.get('week')),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: WeeklyChart(
              values: BudgetMath.weeklyExpenses(state.entries, DateTime.now()),
              strings: s,
              height: 190,
            ),
          ),
        ),
        const SizedBox(height: 20),
        SectionTitle(title: s.get('spendingByCategory')),
        const SizedBox(height: 10),
        if (categories.isEmpty)
          EmptyCard(label: s.get('noBudgetData'))
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  for (final item in categories)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 92,
                            child: Text(
                              s.category(item.key.name),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Semantics(
                              label:
                                  '${s.category(item.key.name)}: ${s.amount(item.value)}',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: maximum == 0
                                      ? 0
                                      : item.value / maximum,
                                  minHeight: 9,
                                  color: moraGreen,
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            s.amount(item.value),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.state});
  final AppState state;
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
                leading: _SettingIcon(icon: Icons.language_rounded),
                title: Text(s.get('language')),
                subtitle: Text(
                  state.locale.languageCode == 'fr'
                      ? s.get('french')
                      : s.get('english'),
                ),
                trailing: DropdownButton<Locale>(
                  value: state.locale,
                  underline: const SizedBox.shrink(),
                  onChanged: (value) {
                    if (value != null) state.setLanguage(value);
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
                secondary: _SettingIcon(icon: Icons.dark_mode_outlined),
                title: Text(s.get('darkMode')),
                subtitle: Text(s.get('darkModeHint')),
                value: state.themeMode == ThemeMode.dark,
                onChanged: state.setDarkMode,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: _SettingIcon(icon: Icons.currency_exchange_rounded),
                title: Text(s.get('currency')),
                subtitle: const Text('MGA · Ar'),
              ),
              const Divider(height: 1, indent: 68),
              ListTile(
                leading: _SettingIcon(icon: Icons.shield_outlined),
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
