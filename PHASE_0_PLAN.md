# Phase 0 Plan

## Scope

Phase 0 creates a trustworthy repository skeleton before ML implementation.
This phase must not implement tensors, autograd, neural networks, DataFrames,
classical ML algorithms, or GPU backends.

## Requirements Found

- Create a Dart pub workspace.
- Create package skeletons for the packages listed in `INSTRUCTION.md`.
- Add root analysis rules.
- Add `tool/check_file_length.dart` and tests.
- Add `tool/verify.dart`.
- Add CI for Dart stable on Linux, macOS, and Windows.
- Add status, roadmap, compatibility, benchmark, security, and contribution
  documents.
- Add a native build-hook proof of concept.
- Add a stable C ABI hello/runtime-version call.
- Add a license inventory tool or document.

## Required Tests

- Workspace resolves from a clean checkout.
- Every package can be analyzed.
- Line-limit checker catches an intentional fixture over 80 lines.
- Native library builds and loads.
- C ABI version mismatch returns a typed error.
- Missing native library returns a typed error.
- Verification command reports skipped optional hardware tests accurately.

## Exit Gate

Phase 0 is complete only when a clean checkout can run one documented
verification command on every initially supported host OS.

## Edge Cases To Track

- Path contains spaces.
- Non-ASCII checkout path.
- Offline dependency cache.
- Unsupported architecture.
- Missing compiler.
- Stale native binary.
- Debug versus release build.
- Windows dynamic-library lookup.
- macOS signing/quarantine behavior.
- Linux missing shared dependency.

## Conflicts, Ambiguities, And Gaps

- The repository license is not specified by the owner.
- Flutter can be inspected by file, but `flutter --version` was not executable
  in the sandbox without writing to the SDK cache.
- CMake, Ninja, pkg-config, and Valgrind are not available on PATH.
- Only macOS arm64 has been inspected locally.
- Cross-OS Phase 0 exit-gate verification requires CI or other hosts.

## Deliverable Breakdown

1. Workspace and governance document baseline.
2. Strict analyzer configuration.
3. File-length checker and fixture test.
4. Root verification runner with honest skip reporting.
5. CI workflow for Dart stable on Linux, macOS, and Windows.
6. License inventory document or tool.
7. Native build-hook proof of concept.
8. Stable C ABI runtime-version handshake.
9. Runtime loading error handling for mismatch and missing library.
10. Phase 0 exit-gate verification report.

## Current Deliverable

Deliverable 1: workspace and governance document baseline.
