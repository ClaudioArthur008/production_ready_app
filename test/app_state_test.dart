import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:production_ready_app/app/app_state.dart';
import 'package:production_ready_app/data/budget_repository.dart';
import 'package:production_ready_app/domain/budget.dart';

void main() {
  group('AppState', () {
    late InMemoryBudgetRepository repository;
    late AppState state;
    setUp(() {
      repository = InMemoryBudgetRepository();
      state = AppState(repository: repository, now: DateTime(2026, 10, 6));
    });
    test('adds an entry and trims its title', () {
      final entry = state.addEntry(
        title: '  Market  ',
        amount: 12000,
        category: BudgetCategory.food,
        type: EntryType.expense,
      );
      expect(entry.title, 'Market');
      expect(state.entries.single.amount, 12000);
    });
    test(
      'rejects a blank title',
      () => expect(
        () => state.addEntry(
          title: '  ',
          amount: 1,
          category: BudgetCategory.food,
          type: EntryType.expense,
        ),
        throwsArgumentError,
      ),
    );
    test('rejects zero and negative amounts', () {
      for (final amount in [0, -5]) {
        expect(
          () => state.addEntry(
            title: 'Water',
            amount: amount,
            category: BudgetCategory.other,
            type: EntryType.expense,
          ),
          throwsArgumentError,
        );
      }
    });
    test('derives balance from its ledger', () {
      state.addEntry(
        title: 'Pay',
        amount: 90000,
        category: BudgetCategory.other,
        type: EntryType.income,
      );
      state.addEntry(
        title: 'Food',
        amount: 10000,
        category: BudgetCategory.food,
        type: EntryType.expense,
      );
      expect(state.balance, 80000);
    });
    test('only notifies listeners for successful deletion', () {
      var notifications = 0;
      state.addListener(() => notifications++);
      expect(state.removeEntry('missing'), isFalse);
      expect(notifications, 0);
      state.addEntry(
        title: 'Food',
        amount: 1,
        category: BudgetCategory.food,
        type: EntryType.expense,
      );
      expect(state.removeEntry(state.entries.first.id), isTrue);
      expect(notifications, 2);
    });
    test('updates the selected locale', () {
      state.setLanguage(const Locale('en'));
      expect(state.locale.languageCode, 'en');
    });
    test('does not notify for unchanged locale', () {
      var notifications = 0;
      state.addListener(() => notifications++);
      state.setLanguage(const Locale('fr'));
      expect(notifications, 0);
    });
    test('toggles dark appearance', () {
      state.setDarkMode(true);
      expect(state.themeMode, ThemeMode.dark);
      state.setDarkMode(false);
      expect(state.themeMode, ThemeMode.light);
    });
  });
}
