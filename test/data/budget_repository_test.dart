import 'package:flutter_test/flutter_test.dart';
import 'package:production_ready_app/data/budget_repository.dart';
import 'package:production_ready_app/domain/budget.dart';

MoneyEntry item(String id, {int amount = 100}) => MoneyEntry(
  id: id,
  title: 'Item',
  amount: amount,
  category: BudgetCategory.food,
  type: EntryType.expense,
  date: DateTime(2026, 10, 6),
);
void main() {
  group('InMemoryBudgetRepository', () {
    test(
      'starts empty by default',
      () => expect(InMemoryBudgetRepository().loadEntries(), isEmpty),
    );
    test('returns an unmodifiable list', () {
      final repo = InMemoryBudgetRepository([item('a')]);
      expect(() => repo.loadEntries().clear(), throwsUnsupportedError);
      expect(repo.loadEntries(), hasLength(1));
    });
    test('adds entries', () {
      final repo = InMemoryBudgetRepository()..addEntry(item('a'));
      expect(repo.loadEntries().single.id, 'a');
    });
    test('rejects duplicate ids', () {
      final repo = InMemoryBudgetRepository([item('a')]);
      expect(() => repo.addEntry(item('a')), throwsArgumentError);
    });
    test('removes an existing entry and reports success', () {
      final repo = InMemoryBudgetRepository([item('a')]);
      expect(repo.removeEntry('a'), isTrue);
      expect(repo.loadEntries(), isEmpty);
    });
    test(
      'reports when a requested id does not exist',
      () => expect(InMemoryBudgetRepository().removeEntry('unknown'), isFalse),
    );
    test('builds a varied sample ledger', () {
      final entries = demoEntries(DateTime(2026, 10, 6));
      expect(entries.length, greaterThanOrEqualTo(5));
      expect(entries.any((e) => e.type == EntryType.income), isTrue);
      expect(entries.any((e) => e.type == EntryType.expense), isTrue);
    });
  });
}
