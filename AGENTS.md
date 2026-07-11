# DartML Repository Instructions

## Mandatory first action

Before planning, creating, modifying, or deleting project files, read
`INSTRUCTION.md` completely from beginning to end.

`INSTRUCTION.md` is the canonical engineering specification for this
repository. Follow its phase order, architecture, testing rules, file-size
limits, documentation requirements, benchmark protocol, and honesty rules.

## Current work scope

* Start with Phase 0 only.
* Do not begin Phase 1.
* Do not implement tensors, autograd, neural networks, DataFrames, or ML
  algorithms during Phase 0.
* Divide Phase 0 into small, independently verifiable deliverables.
* Complete and verify one deliverable before beginning another.
* Keep every handwritten source, test, script, native, and configuration file
  at or below 80 physical lines.
* Write tests and specifications before implementation where practical.
* Run formatting, analysis, tests, and applicable verification commands.
* Fix failures caused by the current change.
* Never claim that a test, benchmark, platform, or hardware backend passed
  unless it was actually executed.
* Mark unavailable checks as `SKIPPED` or `NOT VERIFIED` and state the reason.
* Never invent benchmark values, compatibility claims, command results, or
  hardware evidence.
* Do not install system-wide software, publish packages, push remote branches,
  modify files outside this repository, or use unrestricted permissions
  without explicit owner approval.
* Update `ROADMAP.md`, `STATUS.md`, `COMPATIBILITY.md`, and relevant
  documentation after each completed deliverable.
* Create Git checkpoints only after applicable verification passes.

## Completion report

At the end of each deliverable, report:

1. Files created or changed.
2. Requirements implemented.
3. Commands actually executed.
4. Exact pass, fail, and skipped results.
5. Known limitations and blockers.
6. Current Phase 0 status.
7. The next smallest deliverable.
