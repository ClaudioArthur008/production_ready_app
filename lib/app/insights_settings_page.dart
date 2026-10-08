import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/budget.dart';
import 'app_state.dart';
import 'shared_widgets.dart';
import 'strings.dart';

/// Summarizes monthly expenses and spending by category.
class InsightsPage extends StatelessWidget {
  /// Creates the insights screen.
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) => Selector<AppState, List<MoneyEntry>>(
    selector: (_, state) => state.monthEntries,
    builder: (context, entries, _) => _InsightsContent(entries: entries),
  );
}

class _InsightsContent extends StatelessWidget {
  const _InsightsContent({required this.entries});

  final List<MoneyEntry> entries;

  @override
  Widget build(BuildContext context) {
    final s = MoraStrings(Localizations.localeOf(context));
    final expenses = BudgetMath.total(entries, EntryType.expense);
    final categories =
        BudgetCategory.values
            .map((c) => MapEntry(c, BudgetMath.categoryTotal(entries, c)))
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
              values: BudgetMath.weeklyExpenses(
                entries,
                context.read<AppState>().now,
              ),
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
