# License Inventory

## Current Dependencies

| Dependency | Purpose | License | Status |
|---|---|---|---|
| `test` | Focused Dart tests for workspace metadata | BSD-3-Clause | dev only |

## Toolchain Observed

- Dart SDK 3.9.2.
- Flutter SDK files report 3.35.3.
- Apple clang and Xcode are installed locally.

## Policy

Before adding a dependency, record its purpose, license, maintenance status,
security history, transitive cost, binary size impact, platform limitations,
and replacement difficulty.

## Dependency Notes

`package:test` is the standard Dart test runner. Standard Dart libraries do not
provide an equivalent test runner with assertions and package integration.
Transitive dependencies are recorded in `pubspec.lock`; a full license and
security audit is still pending.
