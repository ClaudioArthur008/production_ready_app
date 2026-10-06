import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app/app_state.dart';
import 'app/shell.dart';
import 'app/theme.dart';

void main() => runApp(MoraApp(state: AppState()));

class MoraApp extends StatelessWidget {
  const MoraApp({super.key, required this.state});
  final AppState state;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: state,
    builder: (context, _) => MaterialApp(
      title: 'Mora',
      debugShowCheckedModeBanner: false,
      locale: state.locale,
      supportedLocales: const [Locale('fr'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: MoraTheme.light(),
      darkTheme: MoraTheme.dark(),
      themeMode: state.themeMode,
      home: MoraShell(state: state),
    ),
  );
}
