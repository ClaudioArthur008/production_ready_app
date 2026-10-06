import 'package:flutter/material.dart';

import '../domain/budget.dart';
import 'app_state.dart';
import 'budget_page.dart';
import 'insights_settings_page.dart';
import 'shared_widgets.dart';
import 'strings.dart';
import 'transaction_page.dart';

class MoraShell extends StatefulWidget {
  const MoraShell({super.key, required this.state});
  final AppState state;
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
      OverviewPage(
        state: widget.state,
        onSeeAll: () => setState(() => tab = 1),
      ),
      TransactionsPage(state: widget.state),
      BudgetsPage(state: widget.state),
      InsightsPage(state: widget.state),
      SettingsPage(state: widget.state),
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
        onPressed: () => showAddEntrySheet(context, widget.state),
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

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key, required this.state, required this.onSeeAll});
  final AppState state;
  final VoidCallback onSeeAll;
  @override
  Widget build(BuildContext context) {
    final s = MoraStrings(Localizations.localeOf(context));
    final weekly = BudgetMath.weeklyExpenses(state.entries, DateTime.now());
    final recent = state.entries.take(4).toList();
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
          balance: state.balance,
          income: state.income,
          expenses: state.expenses,
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
                  EntryTile(entry: recent[i], state: state),
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
