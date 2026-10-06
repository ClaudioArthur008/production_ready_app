import 'package:flutter/material.dart';

import '../data/budget_repository.dart';
import '../domain/budget.dart';

class AppState extends ChangeNotifier {
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

  DateTime get now => _now;
  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;
  List<MoneyEntry> get entries {
    final result = _repository.loadEntries().toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(result);
  }

  int get income => BudgetMath.total(entries, EntryType.income);
  int get expenses => BudgetMath.total(entries, EntryType.expense);
  int get balance => income - expenses;
  List<MoneyEntry> get monthEntries => entries
      .where(
        (entry) =>
            entry.date.year == _now.year && entry.date.month == _now.month,
      )
      .toList(growable: false);

  void setLanguage(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    final next = value ? ThemeMode.dark : ThemeMode.light;
    if (_themeMode == next) return;
    _themeMode = next;
    notifyListeners();
  }

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
    notifyListeners();
    return entry;
  }

  bool removeEntry(String id) {
    final removed = _repository.removeEntry(id);
    if (removed) notifyListeners();
    return removed;
  }
}
