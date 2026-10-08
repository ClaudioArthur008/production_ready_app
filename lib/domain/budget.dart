import 'dart:math' as math;

/// Distinguishes money entering the budget from money spent.
enum EntryType { income, expense }

/// Spending group used by transaction entries and monthly budget limits.
enum BudgetCategory {
  food,
  housing,
  transport,
  health,
  leisure,
  shopping,
  other,
}

/// Immutable record of an income or expense in ariary.
class MoneyEntry {
  /// Creates a ledger entry with a unique [id] and positive [amount].
  const MoneyEntry({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
    this.note = '',
  });

  /// Stable identifier used when updating or removing this entry.
  final String id;

  /// Display name supplied for the transaction.
  final String title;

  /// Absolute transaction amount in Malagasy ariary.
  final int amount;

  /// Category used for budgets and spending summaries.
  final BudgetCategory category;

  /// Whether this entry adds to or subtracts from the balance.
  final EntryType type;

  /// Date on which the transaction occurred.
  final DateTime date;

  /// Optional note associated with the transaction.
  final String note;

  /// Returns a copy, replacing only the supplied fields.
  MoneyEntry copyWith({
    String? id,
    String? title,
    int? amount,
    BudgetCategory? category,
    EntryType? type,
    DateTime? date,
    String? note,
  }) => MoneyEntry(
    id: id ?? this.id,
    title: title ?? this.title,
    amount: amount ?? this.amount,
    category: category ?? this.category,
    type: type ?? this.type,
    date: date ?? this.date,
    note: note ?? this.note,
  );
}

/// Pure calculations over a collection of [MoneyEntry] values.
class BudgetMath {
  const BudgetMath._();

  /// Sums entries matching [type].
  static int total(List<MoneyEntry> entries, EntryType type) => entries
      .where((entry) => entry.type == type)
      .fold(0, (sum, entry) => sum + entry.amount);

  /// Returns income less expenses.
  static int balance(List<MoneyEntry> entries) =>
      total(entries, EntryType.income) - total(entries, EntryType.expense);

  /// Sums expenses in [category], optionally limited to [month].
  static int categoryTotal(
    List<MoneyEntry> entries,
    BudgetCategory category, {
    DateTime? month,
  }) => entries
      .where((entry) {
        if (entry.type != EntryType.expense || entry.category != category) {
          return false;
        }
        return month == null ||
            (entry.date.year == month.year && entry.date.month == month.month);
      })
      .fold(0, (sum, entry) => sum + entry.amount);

  /// Returns spent divided by [limit], clamped to the range from zero to one.
  static double progress(int spent, int limit) {
    if (limit <= 0) return spent > 0 ? 1 : 0;
    return math.min(spent / limit, 1).toDouble();
  }

  /// Returns seven daily expense totals for the week containing [now].
  ///
  /// The first value is Monday and the last value is Sunday.
  static List<int> weeklyExpenses(List<MoneyEntry> entries, DateTime now) {
    final monday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    return List<int>.generate(7, (index) {
      final day = monday.add(Duration(days: index));
      return entries
          .where(
            (entry) =>
                entry.type == EntryType.expense &&
                entry.date.year == day.year &&
                entry.date.month == day.month &&
                entry.date.day == day.day,
          )
          .fold(0, (sum, entry) => sum + entry.amount);
    }, growable: false);
  }
}

/// Monthly spending allowance for one [BudgetCategory].
class BudgetLimit {
  /// Creates a limit of [amount] ariary for [category].
  const BudgetLimit(this.category, this.amount);

  /// Category covered by this limit.
  final BudgetCategory category;

  /// Maximum planned monthly spending in ariary.
  final int amount;
}

/// Default monthly category limits shown in the demo.
const defaultBudgetLimits = <BudgetLimit>[
  BudgetLimit(BudgetCategory.food, 600000),
  BudgetLimit(BudgetCategory.housing, 1200000),
  BudgetLimit(BudgetCategory.transport, 300000),
  BudgetLimit(BudgetCategory.health, 250000),
  BudgetLimit(BudgetCategory.leisure, 200000),
  BudgetLimit(BudgetCategory.shopping, 350000),
  BudgetLimit(BudgetCategory.other, 150000),
];
