import 'package:flutter_test/flutter_test.dart';
import 'package:production_ready_app/domain/budget.dart';

MoneyEntry entry(
  String id,
  int amount,
  EntryType type, {
  BudgetCategory category = BudgetCategory.food,
  DateTime? date,
}) => MoneyEntry(
  id: id,
  title: id,
  amount: amount,
  category: category,
  type: type,
  date: date ?? DateTime(2026, 10, 6),
);

void main() {
  group('BudgetMath', () {
    final entries = [
      entry('salary', 100000, EntryType.income),
      entry('groceries', 12000, EntryType.expense),
      entry('bus', 3000, EntryType.expense, category: BudgetCategory.transport),
    ];
    test(
      'sums income only',
      () => expect(BudgetMath.total(entries, EntryType.income), 100000),
    );
    test(
      'sums expenses only',
      () => expect(BudgetMath.total(entries, EntryType.expense), 15000),
    );
    test(
      'calculates balance as income less expenses',
      () => expect(BudgetMath.balance(entries), 85000),
    );
    test(
      'calculates a category total',
      () =>
          expect(BudgetMath.categoryTotal(entries, BudgetCategory.food), 12000),
    );
    test(
      'excludes incomes from category spending',
      () => expect(BudgetMath.categoryTotal(entries, BudgetCategory.other), 0),
    );
    test('filters category spending to selected month', () {
      final data = [
        ...entries,
        entry('old', 4000, EntryType.expense, date: DateTime(2026, 9, 30)),
      ];
      expect(
        BudgetMath.categoryTotal(
          data,
          BudgetCategory.food,
          month: DateTime(2026, 10),
        ),
        12000,
      );
    });
    test(
      'returns fractional progress under the limit',
      () => expect(BudgetMath.progress(25, 100), .25),
    );
    test(
      'caps progress at 100 percent',
      () => expect(BudgetMath.progress(150, 100), 1),
    );
    test(
      'returns zero at an empty zero limit',
      () => expect(BudgetMath.progress(0, 0), 0),
    );
    test(
      'returns full progress when spending has no limit',
      () => expect(BudgetMath.progress(1, 0), 1),
    );
    test('groups expenses by weekday starting Monday', () {
      final week = BudgetMath.weeklyExpenses([
        entry('monday', 800, EntryType.expense, date: DateTime(2026, 10, 5)),
        entry(
          'tuesday-income',
          900,
          EntryType.income,
          date: DateTime(2026, 10, 6),
        ),
        entry('tuesday', 200, EntryType.expense, date: DateTime(2026, 10, 6)),
      ], DateTime(2026, 10, 7));
      expect(week, [800, 200, 0, 0, 0, 0, 0]);
    });
    test('ignores entries outside the selected week', () {
      final week = BudgetMath.weeklyExpenses([
        entry('last-week', 300, EntryType.expense, date: DateTime(2026, 9, 28)),
        entry('this-week', 500, EntryType.expense, date: DateTime(2026, 10, 5)),
      ], DateTime(2026, 10, 6));
      expect(week.first, 500);
      expect(week.reduce((a, b) => a + b), 500);
    });
  });
}
