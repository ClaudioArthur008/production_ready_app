import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/budget.dart';
import 'app_state.dart';
import 'budget_page.dart';
import 'insights_settings_page.dart';
import 'shared_widgets.dart';
import 'settings_page.dart';
import 'strings.dart';
import 'transaction_page.dart';

/// Hosts Mora's five top-level destinations and shared transaction action.
class MoraShell extends StatefulWidget {
  /// Creates the main navigation shell.
  const MoraShell({super.key});
  @override
  State<MoraShell> createState() => _MoraShellState();
}

class _MoraShellState extends State<MoraShell> {
  int tab = 0;
  @override
  Widget build(BuildContext context) {
    final s = MoraStrings(Localizations.localeOf(context));
    final labels = [
      s.get('app'),
      s.get('transactions'),
      s.get('budgets'),
      s.get('insights'),
      s.get('settings'),
    ];
    final pages = [
      OverviewPage(onSeeAll: () => setState(() => tab = 1)),
      const TransactionsPage(),
      const BudgetsPage(),
      const InsightsPage(),
      const SettingsPage(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(labels[tab]),
        actions: [
          if (tab == 0)
            Padding(
              padding: const EdgeInsets.only(right: 18),
              child: CircleAvatar(
                radius: 17,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.person_outline,
                  size: 19,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
      body: IndexedStack(index: tab, children: pages),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddEntrySheet(context),
        tooltip: s.get('addTransaction'),
        icon: const Icon(Icons.add_rounded),
        label: Text(s.get('add')),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (value) => setState(() => tab = value),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: s.get('home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long_rounded),
            label: s.get('transactions'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.pie_chart_outline_rounded),
            selectedIcon: const Icon(Icons.pie_chart_rounded),
            label: s.get('budgets'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.insights_outlined),
            selectedIcon: const Icon(Icons.insights_rounded),
            label: s.get('insights'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.tune_rounded),
            selectedIcon: const Icon(Icons.tune_rounded),
            label: s.get('settings'),
          ),
        ],
      ),
    );
  }
}

/// Displays the current balance, recent entries, and weekly spending chart.
class OverviewPage extends StatelessWidget {
  /// Creates the overview and calls [onSeeAll] when recent activity is opened.
  const OverviewPage({super.key, required this.onSeeAll});

  /// Callback that opens the transaction history screen.
  final VoidCallback onSeeAll;
  @override
  Widget build(BuildContext context) => Selector<AppState, List<MoneyEntry>>(
    selector: (_, state) => state.entries,
    builder: (context, entries, _) => _OverviewContent(
      entries: entries,
      now: context.read<AppState>().now,
      onSeeAll: onSeeAll,
    ),
  );
}

class _OverviewContent extends StatelessWidget {
  const _OverviewContent({
    required this.entries,
    required this.now,
    required this.onSeeAll,
  });

  final List<MoneyEntry> entries;
  final DateTime now;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final s = MoraStrings(Localizations.localeOf(context));
    final weekly = BudgetMath.weeklyExpenses(entries, now);
    final recent = entries.take(4).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      children: [
        Text(
          s.get('hello'),
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 3),
        Text(
          s.get('overview'),
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: const Color(0xff78847D)),
        ),
        const SizedBox(height: 18),
        BalanceCard(
          balance: BudgetMath.balance(entries),
          income: BudgetMath.total(entries, EntryType.income),
          expenses: BudgetMath.total(entries, EntryType.expense),
        ),
        const SizedBox(height: 22),
        SectionTitle(title: s.get('weeklySpending'), trailing: s.get('week')),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 18, 14, 12),
            child: WeeklyChart(values: weekly, strings: s),
          ),
        ),
        const SizedBox(height: 22),
        SectionTitle(
          title: s.get('recent'),
          trailing: s.get('seeAll'),
          onTap: onSeeAll,
        ),
        const SizedBox(height: 8),
        if (recent.isEmpty)
          EmptyCard(label: s.get('noTransactions'))
        else
          Card(
            child: Column(
              children: [
                for (var i = 0; i < recent.length; i++) ...[
                  EntryTile(
                    entry: recent[i],
                    now: now,
                    onDelete: () =>
                        context.read<AppState>().removeEntry(recent[i].id),
                  ),
                  if (i < recent.length - 1)
                    const Divider(height: 1, indent: 70),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
