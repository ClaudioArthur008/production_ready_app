import 'package:flutter/material.dart';

import '../domain/budget.dart';
import 'strings.dart';

const moraGreen = Color(0xff078B65);
const moraMuted = Color(0xff78847D);

/// Presents available balance, total income, and total expenses.
class BalanceCard extends StatelessWidget {
  /// Creates a card from the supplied amounts in ariary.
  const BalanceCard({
    super.key,
    required this.balance,
    required this.income,
    required this.expenses,
  });
  /// Current available amount in ariary.
  final int balance;

  /// Total income in ariary.
  final int income;

  /// Total expenses in ariary.
  final int expenses;
  @override
  Widget build(BuildContext context) {
    final s = MoraStrings(Localizations.localeOf(context));
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff057D5B), Color(0xff07533F)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.white70,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                s.get('balance'),
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              s.amount(balance),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _BalanceMini(
                  label: s.get('income'),
                  amount: income,
                  icon: Icons.south_west_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _BalanceMini(
                  label: s.get('expense'),
                  amount: expenses,
                  icon: Icons.north_east_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceMini extends StatelessWidget {
  const _BalanceMini({
    required this.label,
    required this.amount,
    required this.icon,
  });
  final String label;
  final int amount;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Row(
      children: [
        Icon(icon, color: Colors.white, size: 17),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
              Text(
                MoraStrings(Localizations.localeOf(context)).amount(amount),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Renders one ledger entry with its category, date, amount, and delete action.
class EntryTile extends StatelessWidget {
  /// Creates an entry row using [onDelete] for its delete button.
  const EntryTile({
    super.key,
    required this.entry,
    required this.now,
    required this.onDelete,
  });
  /// Entry shown by this row.
  final MoneyEntry entry;

  /// Reference date used to display today and yesterday labels.
  final DateTime now;

  /// Called when the user chooses to remove the entry.
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) {
    final s = MoraStrings(Localizations.localeOf(context));
    final isIncome = entry.type == EntryType.income;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      leading: CategoryIcon(category: entry.category, size: 44),
      title: Text(
        entry.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${s.category(entry.category.name)} · ${_dateText(entry.date, s, now)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${isIncome ? '+' : '−'}${s.amount(entry.amount)}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isIncome
                  ? moraGreen
                  : Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          IconButton(
            tooltip: '${s.get('delete')} ${entry.title}',
            icon: const Icon(Icons.close_rounded, size: 17),
            visualDensity: VisualDensity.compact,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

String _dateText(DateTime date, MoraStrings s, DateTime now) {
  if (date.year == now.year && date.month == now.month && date.day == now.day) {
    return s.get('today');
  }
  final y = DateTime(
    now.year,
    now.month,
    now.day,
  ).subtract(const Duration(days: 1));
  if (date.year == y.year && date.month == y.month && date.day == y.day) {
    return s.get('yesterday');
  }
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
}

/// Decorative icon and color associated with a budget category.
class CategoryIcon extends StatelessWidget {
  /// Creates a category icon at [size].
  const CategoryIcon({super.key, required this.category, this.size = 46});
  final BudgetCategory category;
  final double size;
  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (category) {
      BudgetCategory.food => (
        Icons.restaurant_rounded,
        const Color(0xffDF9B3C),
      ),
      BudgetCategory.housing => (
        Icons.home_work_outlined,
        const Color(0xff6689D8),
      ),
      BudgetCategory.transport => (
        Icons.directions_bus_rounded,
        const Color(0xff5C9CB8),
      ),
      BudgetCategory.health => (
        Icons.medical_services_outlined,
        const Color(0xffD87272),
      ),
      BudgetCategory.leisure => (Icons.spa_outlined, const Color(0xff9B77C7)),
      BudgetCategory.shopping => (
        Icons.shopping_bag_outlined,
        const Color(0xffD078A1),
      ),
      BudgetCategory.other => (
        Icons.more_horiz_rounded,
        const Color(0xff6FA88E),
      ),
    };
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: .13),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(icon, color: color, size: size * .48),
      ),
    );
  }
}

/// Section heading with an optional trailing label and tap action.
class SectionTitle extends StatelessWidget {
  /// Creates a section heading.
  const SectionTitle({
    super.key,
    required this.title,
    this.trailing,
    this.onTap,
  });
  final String title;
  final String? trailing;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      if (trailing != null)
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Text(
              trailing!,
              style: TextStyle(
                color: onTap == null ? moraMuted : moraGreen,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
    ],
  );
}

/// Card used to explain why a list or chart currently has no data.
class EmptyCard extends StatelessWidget {
  /// Creates an empty state with the supplied [label].
  const EmptyCard({super.key, required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Center(child: Text(label, textAlign: TextAlign.center)),
    ),
  );
}

/// Bar chart of daily expenses with a screen-reader summary.
class WeeklyChart extends StatelessWidget {
  /// Creates a weekly chart from seven daily values.
  const WeeklyChart({
    super.key,
    required this.values,
    required this.strings,
    this.height = 150,
  });
  final List<int> values;
  final MoraStrings strings;
  final double height;
  @override
  Widget build(BuildContext context) {
    final maxValue = values.fold<int>(0, (a, b) => a > b ? a : b);
    return Semantics(
      label:
          '${strings.get('weeklySpending')}: ${values.map(strings.amount).join(', ')}',
      child: ExcludeSemantics(
        child: SizedBox(
          height: height,
          child: Column(
            children: [
              Expanded(
                child: CustomPaint(
                  painter: _WeeklyPainter(
                    values: values,
                    maxValue: maxValue,
                    color: Theme.of(context).colorScheme.primary,
                    grid: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  for (var day = 1; day <= 7; day++)
                    Expanded(
                      child: Center(
                        child: Text(
                          strings.dayLabel(day),
                          style: const TextStyle(
                            fontSize: 10,
                            color: moraMuted,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeeklyPainter extends CustomPainter {
  const _WeeklyPainter({
    required this.values,
    required this.maxValue,
    required this.color,
    required this.grid,
  });
  final List<int> values;
  final int maxValue;
  final Color color, grid;
  @override
  void paint(Canvas canvas, Size size) {
    final gp = Paint()
      ..color = grid
      ..strokeWidth = 1;
    final bp = Paint()..color = color;
    for (var r = 0; r < 3; r++) {
      final y = size.height * r / 2;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gp);
    }
    final slot = size.width / values.length;
    for (var i = 0; i < values.length; i++) {
      final fraction = maxValue == 0 ? 0.0 : values[i] / maxValue;
      final h = (size.height - 8) * fraction;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(slot * i + slot * .27, size.height - h, slot * .46, h),
          const Radius.circular(6),
        ),
        bp,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WeeklyPainter old) =>
      old.values != values ||
      old.maxValue != maxValue ||
      old.color != color ||
      old.grid != grid;
}
