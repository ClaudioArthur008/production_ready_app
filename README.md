# Mora

[![Flutter CI](https://github.com/ClaudioArthur008/production_ready_app/actions/workflows/flutter.yml/badge.svg)](https://github.com/ClaudioArthur008/production_ready_app/actions/workflows/flutter.yml)
![Flutter](https://img.shields.io/badge/Flutter-3.47%2B-02569B?logo=flutter)
![License](https://img.shields.io/badge/license-MIT-green)

Mora is a calm, offline-first personal budget companion for Malagasy ariary (Ar). It starts in French and also supports English.

> This is a local demo. Entries live in memory and reset when the app restarts; connect a durable encrypted store before using it for real financial records.

## Screens

1. **Home** — balance, income, expenses, recent activity, and weekly spending.
2. **Transactions** — searchable and filterable ledger with remove controls.
3. **Budgets** — monthly category limits and over-limit states.
4. **Insights** — month-to-date spending and category comparisons.
5. **Settings** — language, appearance, currency and privacy information.

Mora uses Material icons and drawn charts instead of remote images, so it makes no image network requests. Lists that can grow use lazy builders.

## Architecture

```
lib/
  app/       AppState, locale copy, theme, screens and shared widgets
  data/      BudgetRepository contract, in-memory adapter and demo ledger
  domain/    MoneyEntry, categories, limits and pure calculations
  main.dart  Flutter entry point
test/        Unit, repository, state and widget tests
integration_test/  End-to-end user flows
```

The UI depends on a `BudgetRepository` through `AppState`, and financial calculations live in pure `BudgetMath` functions. The repository contract lets a durable local store replace the demo adapter.

## Requirements and setup

Flutter stable with Dart 3.13.4 or later. Android Studio / Android SDK is required for Android builds; Xcode is required for iOS builds on macOS.

```sh
flutter pub get
flutter run
```

## Verify

```sh
flutter analyze --fatal-infos
flutter test
```

Integration tests can run on Windows desktop or an Android emulator:

```sh
flutter test integration_test
```

## Android demo

```sh
flutter build apk --release
```

The APK is created at `build/app/outputs/flutter-apk/app-release.apk`. GitHub Actions checks analysis, unit/widget tests, Windows desktop integration tests, and a release APK build, then uploads the APK as a workflow artifact.

## Accessibility and performance

Interactive controls use labels or semantic tooltips. Category icons are decorative because adjacent text names each category. Growing transaction history uses `ListView.builder`; screen updates use immutable widgets and local state. No remote image payloads are downloaded.

## Screenshots

Device-captured screenshots still need to be added under `docs/screenshots/` before release.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for the 0.1.0, 0.2.0, and 1.0.0 milestones.

## License

MIT
