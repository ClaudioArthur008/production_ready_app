import '../domain/budget.dart';

abstract interface class BudgetRepository {
  List<MoneyEntry> loadEntries();
  void addEntry(MoneyEntry entry);
  bool removeEntry(String id);
}

class InMemoryBudgetRepository implements BudgetRepository {
  InMemoryBudgetRepository([Iterable<MoneyEntry> initialEntries = const []])
    : _entries = List<MoneyEntry>.of(initialEntries);
  final List<MoneyEntry> _entries;
  @override
  List<MoneyEntry> loadEntries() => List<MoneyEntry>.unmodifiable(_entries);
  @override
  void addEntry(MoneyEntry entry) {
    if (_entries.any((item) => item.id == entry.id)) {
      throw ArgumentError.value(entry.id, 'entry.id', 'must be unique');
    }
    _entries.add(entry);
  }

  @override
  bool removeEntry(String id) {
    final length = _entries.length;
    _entries.removeWhere((entry) => entry.id == id);
    return _entries.length != length;
  }
}

List<MoneyEntry> demoEntries(DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  return [
    MoneyEntry(
      id: 'demo-1',
      title: 'Salaire',
      amount: 3200000,
      category: BudgetCategory.other,
      type: EntryType.income,
      date: today.subtract(const Duration(days: 1)),
    ),
    MoneyEntry(
      id: 'demo-2',
      title: 'Courses Analakely',
      amount: 87500,
      category: BudgetCategory.food,
      type: EntryType.expense,
      date: today,
    ),
    MoneyEntry(
      id: 'demo-3',
      title: 'Loyer',
      amount: 750000,
      category: BudgetCategory.housing,
      type: EntryType.expense,
      date: today.subtract(const Duration(days: 2)),
    ),
    MoneyEntry(
      id: 'demo-4',
      title: 'Taxi-be',
      amount: 5000,
      category: BudgetCategory.transport,
      type: EntryType.expense,
      date: today.subtract(const Duration(days: 1)),
    ),
    MoneyEntry(
      id: 'demo-5',
      title: 'Pharmacie',
      amount: 32500,
      category: BudgetCategory.health,
      type: EntryType.expense,
      date: today.subtract(const Duration(days: 3)),
    ),
    MoneyEntry(
      id: 'demo-6',
      title: 'Dîner entre amis',
      amount: 68000,
      category: BudgetCategory.leisure,
      type: EntryType.expense,
      date: today.subtract(const Duration(days: 4)),
    ),
    MoneyEntry(
      id: 'demo-7',
      title: 'Salaire',
      amount: 3200000,
      category: BudgetCategory.other,
      type: EntryType.income,
      date: DateTime(now.year, now.month, 1),
    ),
    MoneyEntry(
      id: 'demo-8',
      title: 'Courses',
      amount: 124000,
      category: BudgetCategory.food,
      type: EntryType.expense,
      date: DateTime(now.year, now.month, 2),
    ),
  ];
}
