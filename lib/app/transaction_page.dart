import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/budget.dart';
import 'app_state.dart';
import 'shared_widgets.dart';
import 'strings.dart';

/// Shows a searchable, filterable, lazily built transaction ledger.
class TransactionsPage extends StatefulWidget {
  /// Creates the transaction history screen.
  const TransactionsPage({super.key});
  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  String query = '';
  EntryType? type;
  @override
  Widget build(BuildContext context) => Selector<AppState, List<MoneyEntry>>(
    selector: (_, state) => state.entries,
    builder: (context, entries, _) => _TransactionsContent(
      entries: entries,
      query: query,
      type: type,
      onQueryChanged: (value) => setState(() => query = value),
      onTypeChanged: (value) => setState(() => type = value),
    ),
  );
}

class _TransactionsContent extends StatelessWidget {
  const _TransactionsContent({
    required this.entries,
    required this.query,
    required this.type,
    required this.onQueryChanged,
    required this.onTypeChanged,
  });

  final List<MoneyEntry> entries;
  final String query;
  final EntryType? type;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<EntryType?> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    final s = MoraStrings(Localizations.localeOf(context));
    final filtered = entries
        .where(
          (entry) =>
              (type == null || entry.type == type) &&
              entry.title.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
          child: TextField(
            onChanged: onQueryChanged,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: s.get('search'),
            ),
            textInputAction: TextInputAction.search,
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _Filter(
                label: s.get('all'),
                selected: type == null,
                onTap: () => onTypeChanged(null),
              ),
              const SizedBox(width: 8),
              _Filter(
                label: s.get('incomeType'),
                selected: type == EntryType.income,
                onTap: () => onTypeChanged(EntryType.income),
              ),
              const SizedBox(width: 8),
              _Filter(
                label: s.get('expenseType'),
                selected: type == EntryType.expense,
                onTap: () => onTypeChanged(EntryType.expense),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: filtered.isEmpty
              ? Center(child: Text(s.get('noTransactions')))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Card(
                      child: EntryTile(
                        entry: filtered[index],
                        now: context.read<AppState>().now,
                        onDelete: () => context.read<AppState>().removeEntry(
                          filtered[index].id,
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _Filter extends StatelessWidget {
  const _Filter({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ChoiceChip(
    label: Text(label),
    selected: selected,
    onSelected: (_) => onTap(),
  );
}

/// Opens the form used to add a transaction to the shared app state.
Future<void> showAddEntrySheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => const AddEntrySheet(),
    );

/// Form for creating a validated income or expense entry.
class AddEntrySheet extends StatefulWidget {
  /// Creates the add transaction form.
  const AddEntrySheet({super.key});
  @override
  State<AddEntrySheet> createState() => _AddEntrySheetState();
}

class _AddEntrySheetState extends State<AddEntrySheet> {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  EntryType type = EntryType.expense;
  BudgetCategory category = BudgetCategory.food;
  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void save() {
    if (!formKey.currentState!.validate()) return;
    context.read<AppState>().addEntry(
      title: titleController.text,
      amount: int.parse(amountController.text.trim()),
      category: category,
      type: type,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = MoraStrings(Localizations.localeOf(context));
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                s.get('addTransaction'),
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 17),
              SegmentedButton<EntryType>(
                segments: [
                  ButtonSegment(
                    value: EntryType.expense,
                    label: Text(s.get('expenseType')),
                    icon: const Icon(Icons.north_east_rounded),
                  ),
                  ButtonSegment(
                    value: EntryType.income,
                    label: Text(s.get('incomeType')),
                    icon: const Icon(Icons.south_west_rounded),
                  ),
                ],
                selected: {type},
                onSelectionChanged: (value) =>
                    setState(() => type = value.first),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: s.get('title'),
                  prefixIcon: const Icon(Icons.edit_outlined),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? s.get('invalidTitle')
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: s.get('amount'),
                  prefixIcon: const Icon(Icons.payments_outlined),
                ),
                validator: (value) {
                  final amount = int.tryParse((value ?? '').trim());
                  return amount == null || amount <= 0
                      ? s.get('invalidAmount')
                      : null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<BudgetCategory>(
                initialValue: category,
                decoration: InputDecoration(
                  labelText: s.get('category'),
                  prefixIcon: const Icon(Icons.category_outlined),
                ),
                items: [
                  for (final item in BudgetCategory.values)
                    DropdownMenuItem(
                      value: item,
                      child: Text(s.category(item.name)),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => category = value);
                },
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: save,
                  icon: const Icon(Icons.check_rounded),
                  label: Text(s.get('save')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
