import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:production_ready_app/app/app_state.dart';
import 'package:production_ready_app/data/budget_repository.dart';
import 'package:production_ready_app/domain/budget.dart';
import 'package:production_ready_app/main.dart';

void main() {
  late AppState state;
  setUp(() {
    state = AppState(
      repository: InMemoryBudgetRepository([
        MoneyEntry(
          id: 'one',
          title: 'Groceries',
          amount: 18000,
          category: BudgetCategory.food,
          type: EntryType.expense,
          date: DateTime(2026, 10, 6),
        ),
        MoneyEntry(
          id: 'income',
          title: 'Pay',
          amount: 150000,
          category: BudgetCategory.other,
          type: EntryType.income,
          date: DateTime(2026, 10, 5),
        ),
      ]),
      now: DateTime(2026, 10, 6),
    );
  });
  testWidgets('home shows balance and recent activity', (tester) async {
    await tester.pumpWidget(MoraApp(state: state));
    expect(find.text('Solde disponible'), findsOneWidget);
    expect(find.text('Accueil'), findsWidgets);
    expect(find.textContaining('132 000 Ar'), findsOneWidget);
  });
  testWidgets('bottom navigation opens all five screens', (tester) async {
    await tester.pumpWidget(MoraApp(state: state));
    for (final label in ['Transactions', 'Budgets', 'Analyses', 'Réglages']) {
      await tester.tap(find.text(label).last);
      await tester.pumpAndSettle();
      expect(find.text(label).first, findsWidgets);
    }
  });
  testWidgets('transaction history filters by search query', (tester) async {
    await tester.pumpWidget(MoraApp(state: state));
    await tester.tap(find.text('Transactions').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Groceries');
    await tester.pumpAndSettle();
    expect(find.text('Accueil'), findsWidgets);
    expect(find.text('Pay'), findsNothing);
  });
  testWidgets('new transaction form validates required title', (tester) async {
    await tester.pumpWidget(MoraApp(state: state));
    await tester.tap(find.byTooltip('Nouvelle opération'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Montant en ariary'),
      '1200',
    );
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(find.text('Ajoutez un libellé.'), findsOneWidget);
    expect(state.entries, hasLength(2));
  });
  testWidgets('saving a transaction updates balance and history', (
    tester,
  ) async {
    await tester.pumpWidget(MoraApp(state: state));
    await tester.tap(find.byTooltip('Nouvelle opération'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Libellé'),
      'Café',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Montant en ariary'),
      '2500',
    );
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(state.entries, hasLength(3));
    expect(state.entries.any((entry) => entry.title == 'Café'), isTrue);
    expect(state.balance, 129500);
    expect(find.textContaining('129 500 Ar'), findsOneWidget);
  });
  testWidgets('settings updates language to English', (tester) async {
    await tester.pumpWidget(MoraApp(state: state));
    await tester.tap(find.text('Réglages').last);
    await tester.pumpAndSettle();
    state.setLanguage(const Locale('en'));
    await tester.pumpAndSettle();
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Your data stays on this device.'), findsOneWidget);
  });
}
