import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:production_ready_app/app/app_state.dart';
import 'package:production_ready_app/data/budget_repository.dart';
import 'package:production_ready_app/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('navigates the five sections and changes language', (
    tester,
  ) async {
    final state = AppState(repository: InMemoryBudgetRepository());
    await tester.pumpWidget(MoraApp(state: state));
    for (final label in ['Transactions', 'Budgets', 'Analyses', 'Réglages']) {
      await tester.tap(find.text(label).last);
      await tester.pumpAndSettle();
      expect(find.text(label).first, findsWidgets);
    }
    state.setLanguage(const Locale('en'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsWidgets);
  });

  testWidgets('creates a transaction visible in history', (tester) async {
    final state = AppState(repository: InMemoryBudgetRepository());
    await tester.pumpWidget(MoraApp(state: state));
    await tester.tap(find.byTooltip('Nouvelle opération'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Libellé'),
      'Transport',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Montant en ariary'),
      '14000',
    );
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(state.entries, hasLength(1));
    await tester.tap(find.text('Transactions').last);
    await tester.pumpAndSettle();
    expect(find.text('Transport'), findsOneWidget);
    expect(find.textContaining('14 000 Ar'), findsOneWidget);
  });
}
