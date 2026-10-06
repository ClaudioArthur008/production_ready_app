import 'package:flutter/material.dart';

import '../domain/budget.dart';
import 'app_state.dart';
import 'shared_widgets.dart';
import 'strings.dart';

class BudgetsPage extends StatelessWidget {
  const BudgetsPage({super.key, required this.state});
  final AppState state;
  @override
  Widget build(BuildContext context) {
    final s = MoraStrings(Localizations.localeOf(context));
    final month = state.monthEntries;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      children: [
        Text(
          s.get('budgetTip'),
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: moraMuted),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.get('budgetOverview'),
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  '${s.get('expense')} · ${s.amount(BudgetMath.total(month, EntryType.expense))}',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: moraMuted),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        for (final limit in defaultBudgetLimits)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _BudgetCard(
              limit: limit,
              spent: BudgetMath.categoryTotal(month, limit.category),
              strings: s,
            ),
          ),
      ],
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.limit,
    required this.spent,
    required this.strings,
  });
  final BudgetLimit limit;
  final int spent;
  final MoraStrings strings;
  @override
  Widget build(BuildContext context) {
    final ratio = BudgetMath.progress(spent, limit.amount);
    final exceeded = spent > limit.amount;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CategoryIcon(category: limit.category, size: 42),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    strings.category(limit.category.name),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  strings.amount(spent),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: exceeded
                        ? Theme.of(context).colorScheme.error
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Semantics(
              label:
                  '${strings.category(limit.category.name)}: ${(ratio * 100).round()}%',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 8,
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
                  color: exceeded
                      ? Theme.of(context).colorScheme.error
                      : moraGreen,
                ),
              ),
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                Text(
                  '${strings.get('limit')}: ${strings.amount(limit.amount)}',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: moraMuted),
                ),
                const Spacer(),
                Text(
                  exceeded
                      ? '+${strings.amount(spent - limit.amount)}'
                      : '${strings.amount(limit.amount - spent)} ${strings.get('left')}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: exceeded
                        ? Theme.of(context).colorScheme.error
                        : moraMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
