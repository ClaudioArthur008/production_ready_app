# Changelog

All notable changes to Mora are recorded here. Dates use ISO 8601.

## [Unreleased]
- Replaced broad state-driven page rebuilds with Provider selectors and cached immutable ledger snapshots.
- Separated settings into its own screen file and added Dartdoc to public app and domain APIs.
- Expanded verified coverage to 28 unit tests, 6 widget tests, and 2 integration tests; documented the per-file counts in the README.

## [1.0.0] - 2026-10-06
### Added
- First production-readiness milestone with five localized screens, a searchable ledger, monthly category limits, weekly insights, and accessible transaction entry.
- GitHub Actions checks for static analysis, tests, Windows integration flows, and Android release builds.
- French-first Malagasy ariary experience with English language and dark appearance settings.

### Verified
- At the 1.0.0 milestone, the project included business-logic, repository, widget, and integration test suites.

## [0.2.0] - 2026-09-15
### Added
- Local budget domain model, transaction categories, monthly envelope calculations, and dashboard chart prototype.
- French and English copy inventory for the core budgeting flow.

## [0.1.0] - 2026-08-30
### Added
- Mora's initial offline budget concept with a balance, income and expense tracking, and an ariary-first interface.
