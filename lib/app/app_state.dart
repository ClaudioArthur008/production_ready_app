import 'package:flutter/material.dart';

import '../data/budget_repository.dart';
import '../domain/budget.dart';

/// Coordinates budget data, locale, appearance, and UI notifications.
class AppState extends ChangeNotifier {
  /// Creates app state backed by [repository] or the local demo ledger.
  AppState({BudgetRepository? repository, DateTime? now})
    : _now = now ?? DateTime.now(),
      _repository =
          repository ??
          InMemoryBudgetRepository(demoEntries(now ?? DateTime.now()));

  final DateTime _now;
  final BudgetRepository _repository;
  Locale _locale = const Locale('fr');
  ThemeMode _themeMode = ThemeMode.light;
  int _nextId = 0;
  List<MoneyEntry>? _entriesCache;
  List<MoneyEntry>? _monthEntriesCache;

  /// Fixed clock used to keep date-based demo calculations deterministic.
  DateTime get now => _now;

  /// Currently selected app language.
  Locale get locale => _locale;

  /// Currently selected light or dark appearance.
  ThemeMode get themeMode => _themeMode;

  /// Immutable ledger snapshot ordered from newest to oldest.
  List<MoneyEntry> get entries => _entriesCache ??= List.unmodifiable(
    _repository.loadEntries().toList()
      ..sort((a, b) => b.date.compareTo(a.date)),
  );

  /// Total income across the ledger.
  int get income => BudgetMath.total(entries, EntryType.income);

  /// Total expenses across the ledger.
  int get expenses => BudgetMath.total(entries, EntryType.expense);

  /// Available balance, calculated as income less expenses.
  int get balance => income - expenses;

  /// Immutable entries dated within the current month.
  List<MoneyEntry> get monthEntries => _monthEntriesCache ??= List.unmodifiable(
    entries.where(
      (entry) => entry.date.year == _now.year && entry.date.month == _now.month,
    ),
  );

  /// Updates the interface language and notifies listeners when it changes.
  void setLanguage(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
  }

  /// Selects dark mode when [value] is true, otherwise light mode.
  void setDarkMode(bool value) {
    final next = value ? ThemeMode.dark : ThemeMode.light;
    if (_themeMode == next) return;
    _themeMode = next;
    notifyListeners();
  }

  /// Validates and saves a transaction, then notifies listeners.
  ///
  /// Throws [ArgumentError] if the title is blank or [amount] is not positive.
  MoneyEntry addEntry({
    required String title,
    required int amount,
    required BudgetCategory category,
    required EntryType type,
    String note = '',
  }) {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) {
      throw ArgumentError.value(title, 'title', 'must not be empty');
    }
    if (amount <= 0) {
      throw ArgumentError.value(amount, 'amount', 'must be positive');
    }
    final entry = MoneyEntry(
      id: 'entry-${_now.microsecondsSinceEpoch}-${_nextId++}',
      title: cleanTitle,
      amount: amount,
      category: category,
      type: type,
      date: _now,
      note: note.trim(),
    );
    _repository.addEntry(entry);
    _invalidateEntries();
    notifyListeners();
    return entry;
  }

  /// Removes the transaction identified by [id].
  bool removeEntry(String id) {
    final removed = _repository.removeEntry(id);
    if (removed) {
      _invalidateEntries();
      notifyListeners();
    }
    return removed;
  }

  void _invalidateEntries() {
    _entriesCache = null;
    _monthEntriesCache = null;
  }
}
