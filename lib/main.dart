import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'app/app_state.dart';
import 'app/shell.dart';
import 'app/theme.dart';

/// Starts Mora with a fresh local demo state.
void main() => runApp(MoraApp(state: AppState()));

/// Application root, exposing [state] to the widget tree.
class MoraApp extends StatelessWidget {
  /// Creates Mora with a supplied [state], useful for tests and previews.
  const MoraApp({super.key, required this.state});

  /// Shared app state provided to descendant screens.
  final AppState state;
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider<AppState>.value(
    value: state,
    child: const _MoraMaterialApp(),
  );
}

class _MoraMaterialApp extends StatelessWidget {
  const _MoraMaterialApp();

  @override
  Widget build(BuildContext context) => Selector<AppState, (Locale, ThemeMode)>(
    selector: (_, state) => (state.locale, state.themeMode),
    builder: (context, preferences, _) => MaterialApp(
      title: 'Mora',
      debugShowCheckedModeBanner: false,
      locale: preferences.$1,
      supportedLocales: const [Locale('fr'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: MoraTheme.light(),
      darkTheme: MoraTheme.dark(),
      themeMode: preferences.$2,
      home: const MoraShell(),
    ),
  );
}
