import 'dart:math' as math;

enum EntryType { income, expense }

enum BudgetCategory {
  food,
  housing,
  transport,
  health,
  leisure,
  shopping,
  other,
}

class MoneyEntry {
  const MoneyEntry({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
    this.note = '',
  });
  final String id;
  final String title;
  final int amount;
  final BudgetCategory category;
  final EntryType type;
  final DateTime date;
  final String note;

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

class BudgetMath {
  const BudgetMath._();
  static int total(List<MoneyEntry> entries, EntryType type) => entries
      .where((entry) => entry.type == type)
      .fold(0, (sum, entry) => sum + entry.amount);
  static int balance(List<MoneyEntry> entries) =>
      total(entries, EntryType.income) - total(entries, EntryType.expense);
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
  static double progress(int spent, int limit) {
    if (limit <= 0) return spent > 0 ? 1 : 0;
    return math.min(spent / limit, 1).toDouble();
  }

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

class BudgetLimit {
  const BudgetLimit(this.category, this.amount);
  final BudgetCategory category;
  final int amount;
}

const defaultBudgetLimits = <BudgetLimit>[
  BudgetLimit(BudgetCategory.food, 600000),
  BudgetLimit(BudgetCategory.housing, 1200000),
  BudgetLimit(BudgetCategory.transport, 300000),
  BudgetLimit(BudgetCategory.health, 250000),
  BudgetLimit(BudgetCategory.leisure, 200000),
  BudgetLimit(BudgetCategory.shopping, 350000),
  BudgetLimit(BudgetCategory.other, 150000),
];
