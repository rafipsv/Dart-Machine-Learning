# Roadmap

## Phase Status

| Phase | Name | Status |
|---|---|---|
| 0 | Governance, workspace, and verification foundation | in progress |
| 1 | Formal specifications and pure Dart reference core | planned |
| 2 | Native CPU tensor runtime | planned |
| 3 | Production tensor API | planned |
| 4 | Automatic differentiation | planned |
| 5 | Neural networks and optimization | planned |
| 6 | DataFrame, dataset, and data loading | planned |
| 7 | Classical machine learning | planned |
| 8 | Statistics and scientific computing | planned |
| 9 | Interoperability and model formats | planned |
| 10 | GPU backends | planned |
| 11 | Graph capture, compiler, and optimization | planned |
| 12 | Distributed and parallel training | planned |
| 13 | Tooling, REPL, visualization, and Flutter experience | planned |
| 14 | Security, release engineering, and ecosystem hardening | planned |

## Phase 0 Dependencies

- Dart SDK 3.9 or newer for pub workspace support.
- Git for source control.
- Native compiler toolchain for the later C ABI proof of concept.
- CI hosts for Linux, macOS, and Windows verification.

## Phase 0 Progress

- Deliverable 1: workspace and governance document baseline is complete.
- Deliverable 2: strict analyzer configuration is complete.
- Deliverable 3: file-length checker and fixture tests are complete.
  Review fixes tightened exclusions, generated provenance, line endings,
  portable path handling, symlink behavior, and deterministic error reporting.
- Deliverable 4: root verification runner with honest skip reporting is next.

## Phase 0 Exit Gate

A clean checkout can run one documented verification command on every initially
supported host OS.

## Deferred Items

All ML semantics and implementations are deferred until later phases.

## Compatibility Targets

Initial Phase 0 targets are macOS arm64 locally and Linux, macOS, and Windows
through CI once CI is added.
