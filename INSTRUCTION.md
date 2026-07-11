# INSTRUCTION.md

## Autonomous AI Engineering Specification for DartML

> **Canonical instruction file:** Every AI coding agent working in this repository must read this file completely before modifying code.
>
> **Mission:** Build a production-grade, open-source machine learning ecosystem for Dart that can compete with Python ML tooling through verified correctness, high-performance native backends, excellent Dart APIs, interoperability, documentation, and reproducible benchmarks.
>
> **Reality constraint:** “Head-to-head with Python” is a measurable target, not a marketing claim. Never claim parity unless the relevant compatibility, correctness, and performance gates in this document have passed on published hardware and reproducible test data.

---

## 1. Primary Objectives

Build one Dart pub workspace containing a family of tightly integrated packages:

1. A NumPy-like tensor and numerical computing layer.
2. A PyTorch-like automatic differentiation and neural-network layer.
3. A scikit-learn-like classical machine-learning layer.
4. A Pandas-like tabular data layer.
5. Native CPU and GPU execution backends.
6. ONNX, DLPack, Apache Arrow, SafeTensors, and common data-format interoperability.
7. Model training, evaluation, serialization, inference, and deployment tooling.
8. Flutter-friendly on-device inference and optional training.
9. A graph optimizer/compiler for operation fusion and deployment.
10. Reproducible benchmarks against relevant Python libraries.

The final public experience should feel natural to a Dart developer:

```dart
final x = Tensor.randn([128, 784], device: Device.bestAvailable);
final model = Sequential([
  Linear(784, 256),
  ReLU(),
  Linear(256, 10),
]);

final optimizer = Adam(model.parameters, learningRate: 1e-3);
final logits = model(x);
```

---

## 2. Non-Negotiable Engineering Rules

### 2.1 Correctness before feature count

- Never add a public feature without tests.
- Never merge placeholder implementations that silently return fake values.
- Never convert an unsupported case into a successful no-op.
- Throw a typed, documented exception for unsupported behavior.
- Never suppress a failing test to make CI green.
- Never loosen numeric tolerances without a documented reason and comparison evidence.
- Never copy an algorithm from an unverified source.
- For mathematical algorithms, record the authoritative paper, specification, or established implementation used as reference.

### 2.2 File-size rule

All handwritten source and test files must follow:

- **Target:** 40–70 physical lines.
- **Hard limit:** 80 physical lines.
- Count imports, comments, blank lines, declarations, and closing braces.
- Split files before they exceed the hard limit.
- Prefer one public type or one focused concern per file.
- Generated files may exceed 80 lines only when:
  - stored under a clearly named `generated/` directory;
  - marked as generated at the top;
  - reproducible from a checked-in generator;
  - excluded from manual editing;
  - excluded from the handwritten line-limit check.
- Markdown specifications and generated API documentation are not subject to the code-line limit.
- Native C, C++, Rust, CUDA, Metal, and shader files are also limited to 80 handwritten lines. Split kernels and helpers aggressively.
- The repository must contain an automated line-limit checker.
- CI must fail when a handwritten code file exceeds 80 lines.

### 2.3 Small, composable changes

- Implement one coherent vertical slice at a time.
- Keep each change independently testable.
- Avoid giant refactors mixed with new features.
- Public APIs require a specification before implementation.
- Internal APIs may evolve, but changes must preserve testability.
- Do not begin the next phase until the current phase exit gate passes.

### 2.4 No hidden Python runtime dependency

Python may be used for:

- reference-result generation;
- differential testing;
- compatibility testing;
- benchmark comparison;
- model export fixtures.

Production Dart packages must not require Python unless a package is explicitly named and documented as a development bridge.

### 2.5 Native acceleration strategy

Do not attempt to win performance using large pure-Dart loops alone.

Use this architecture:

```text
Dart public API
    ↓
Backend-neutral operation dispatcher
    ↓
Stable C ABI
    ↓
Native runtime
    ├── CPU kernels / BLAS / SIMD
    ├── CUDA
    ├── ROCm
    ├── Metal
    └── WebGPU
```

Pure Dart reference kernels are still required for:

- correctness oracles;
- debugging;
- unsupported-platform fallback;
- small tensors;
- education;
- conformance testing.

### 2.6 Honest status reporting

Every feature must have one status:

- `planned`
- `experimental`
- `preview`
- `stable`
- `deprecated`

Never label an API stable until:

- behavior is specified;
- tests cover normal and edge cases;
- error behavior is documented;
- serialization compatibility is considered;
- benchmark results exist where performance matters;
- the API has passed at least one release-candidate cycle.

---

## 3. AI Agent Operating Mode

The AI agent is the primary implementer, reviewer, tester, documenter, and release-preparation assistant.

### 3.1 Mandatory autonomous loop

For every task, execute this loop:

1. Read `INSTRUCTION.md`.
2. Read `STATUS.md`, `ROADMAP.md`, and relevant specifications.
3. Inspect existing implementation and tests.
4. Identify the smallest complete deliverable.
5. Write or update the specification first.
6. Write failing tests first when practical.
7. Implement the minimum correct solution.
8. Format all changed files.
9. Run static analysis.
10. Run focused tests.
11. Run the complete affected-package test suite.
12. Run cross-package integration tests.
13. Run differential tests against the Python reference where applicable.
14. Run property, fuzz, gradient, serialization, or memory tests as applicable.
15. Run relevant benchmarks.
16. Review the diff for duplication, oversized files, unsafe memory, and API inconsistency.
17. Update documentation, examples, changelog, compatibility matrix, and `STATUS.md`.
18. Run the repository-wide verification command.
19. Report exactly what passed, failed, was skipped, and why.

### 3.2 Self-review questions

Before declaring a task complete, the agent must answer internally:

- Is the behavior mathematically correct?
- Does the implementation handle empty and scalar inputs?
- Are shape, dtype, device, ownership, and error semantics explicit?
- Does any native allocation leak?
- Can any view outlive its storage?
- Can any arithmetic overflow a shape or byte-count calculation?
- Are NaN, infinity, signed zero, and subnormal values handled intentionally?
- Is the API idiomatic Dart?
- Is the same concept implemented twice?
- Can the code be simplified without hiding behavior?
- Are all handwritten files at most 80 lines?
- Did every relevant test actually run?
- Is any claim stronger than the evidence?

### 3.3 When blocked

Do not fabricate a solution.

When a task is blocked:

1. Record the blocker in `STATUS.md`.
2. Add a minimal reproducer under `repro/`.
3. Preserve failing tests when they express correct expected behavior.
4. Implement a typed `UnsupportedError` only when the unsupported state is intentional.
5. Mark the feature status accurately.
6. Continue with independent work that does not bypass the blocker.

### 3.4 Prohibited agent behavior

The agent must never:

- invent benchmark results;
- claim GPU support without running on that GPU backend;
- claim numerical parity based only on a few examples;
- delete failing tests without replacing their coverage;
- disable analyzer rules to hide defects;
- commit secrets, credentials, private datasets, or proprietary models;
- publish to pub.dev or create a public release without explicit owner authorization;
- silently change public behavior;
- use generated code as a dumping ground for handwritten logic;
- add dependencies without checking license, maintenance, security, and necessity;
- accept code merely because it compiles.

---

## 4. Repository Shape

Use one Dart pub workspace and one repository.

```text
dart_ml/
├── INSTRUCTION.md
├── README.md
├── ROADMAP.md
├── STATUS.md
├── CHANGELOG.md
├── LICENSE
├── SECURITY.md
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
├── COMPATIBILITY.md
├── BENCHMARKS.md
├── analysis_options.yaml
├── pubspec.yaml
├── packages/
│   ├── dart_ml/
│   ├── dart_ml_core/
│   ├── dart_ml_tensor/
│   ├── dart_ml_autograd/
│   ├── dart_ml_nn/
│   ├── dart_ml_optim/
│   ├── dart_ml_data/
│   ├── dart_ml_stats/
│   ├── dart_ml_learn/
│   ├── dart_ml_io/
│   ├── dart_ml_onnx/
│   ├── dart_ml_runtime/
│   ├── dart_ml_flutter/
│   └── dart_ml_cli/
├── native/
│   ├── include/
│   ├── core/
│   ├── cpu/
│   ├── cuda/
│   ├── rocm/
│   ├── metal/
│   ├── webgpu/
│   └── tests/
├── specs/
│   ├── tensors/
│   ├── autograd/
│   ├── operators/
│   ├── dtypes/
│   ├── serialization/
│   └── public_api/
├── python_reference/
│   ├── requirements.lock
│   ├── generators/
│   ├── differential/
│   └── fixtures/
├── conformance/
│   ├── tensor/
│   ├── onnx/
│   ├── dlpack/
│   └── arrow/
├── benchmarks/
│   ├── dart/
│   ├── python/
│   ├── datasets/
│   └── reports/
├── examples/
│   ├── tensor_basics/
│   ├── linear_regression/
│   ├── image_classifier/
│   └── flutter_inference/
├── integration_test/
├── fuzz/
├── repro/
├── tool/
│   ├── verify.dart
│   ├── check_file_length.dart
│   ├── check_public_api.dart
│   ├── generate_fixtures.dart
│   └── benchmark.dart
└── .github/
    ├── workflows/
    ├── ISSUE_TEMPLATE/
    └── pull_request_template.md
```

### Package responsibility rules

- `dart_ml_core`: shared errors, result types, device descriptors, common contracts.
- `dart_ml_tensor`: tensors, shapes, strides, dtypes, indexing, operations.
- `dart_ml_autograd`: graph recording, backward engine, gradient rules.
- `dart_ml_nn`: modules, layers, losses, initialization.
- `dart_ml_optim`: optimizers and learning-rate schedulers.
- `dart_ml_data`: DataFrame, Series, datasets, transforms, data loaders.
- `dart_ml_stats`: distributions, descriptive statistics, statistical tests.
- `dart_ml_learn`: classical ML estimators, pipelines, preprocessing, metrics.
- `dart_ml_io`: CSV, JSON, NPY, NPZ, Parquet, model serialization.
- `dart_ml_onnx`: ONNX import, export, validation, operator mapping.
- `dart_ml_runtime`: FFI bindings, backend loading, native asset hooks.
- `dart_ml_flutter`: Flutter integration and platform-specific helpers.
- `dart_ml_cli`: model inspection, conversion, benchmarking, diagnostics.
- `dart_ml`: curated top-level exports only.

No package may import a higher-level package and create a dependency cycle.

---

## 5. Required Project Control Files

### `ROADMAP.md`

Must contain:

- phase list;
- phase status;
- dependencies;
- exit gates;
- deferred items;
- compatibility targets.

### `STATUS.md`

Update after every completed task:

```markdown
## Current Phase

## Completed

## In Progress

## Blocked

## Verification Results

## Known Limitations

## Next Smallest Deliverable
```

### `COMPATIBILITY.md`

Track support by:

- Dart SDK;
- operating system;
- CPU architecture;
- device backend;
- dtype;
- operator;
- training/inference;
- stable/experimental status.

### `BENCHMARKS.md`

Track:

- hardware;
- OS;
- compiler/toolchain;
- Dart version;
- native library versions;
- dataset;
- tensor shape;
- warm-up;
- repetitions;
- median;
- p90/p95;
- memory usage;
- comparison methodology;
- raw report path.

### Architecture Decision Records

Store decisions in:

```text
docs/decisions/0001-stable-c-abi.md
docs/decisions/0002-native-memory-ownership.md
```

Each record must include:

- context;
- decision;
- alternatives;
- consequences;
- migration considerations.

---

## 6. Universal Quality Gates

Every phase must satisfy all applicable gates.

### 6.1 Formatting and analysis

Required commands:

```bash
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
```

No warnings, infos, or ignored errors in stable code.

### 6.2 Tests

At minimum:

```bash
dart test
```

Flutter packages:

```bash
flutter test
```

The root must provide one command:

```bash
dart run tool/verify.dart --all
```

It must orchestrate:

- dependency resolution;
- formatting check;
- file-length check;
- static analysis;
- unit tests;
- integration tests;
- conformance tests;
- documentation generation check;
- selected smoke benchmarks;
- native tests when toolchains are available.

### 6.3 Documentation

For every public symbol:

- one-sentence summary;
- parameter semantics;
- return semantics;
- shape rules;
- dtype rules;
- device rules;
- exceptions;
- numerical notes;
- at least one example for non-trivial APIs.

Run:

```bash
dart doc
```

Documentation warnings fail CI.

### 6.4 Coverage

Coverage is a diagnostic, not proof of correctness.

Minimum targets:

- Core shape/dtype/error logic: 95% line coverage.
- Tensor operations: 90% line coverage plus differential tests.
- Autograd rules: 95% line coverage plus gradient checks.
- Native memory/FFI wrappers: 90% line coverage plus sanitizer runs.
- High-level ML estimators: 90% line coverage plus Python comparisons.
- Generated bindings are excluded.

Never add meaningless tests solely to increase coverage.

### 6.5 Public API compatibility

- Generate a public API snapshot.
- CI must detect accidental additions, removals, and signature changes.
- Breaking changes require:
  - decision record;
  - migration guide;
  - major-version plan;
  - deprecation period when feasible.

---

## 7. Testing Doctrine

No single testing style is sufficient.

### 7.1 Unit tests

Test one behavior at a time:

- valid inputs;
- invalid inputs;
- boundary inputs;
- typed errors;
- immutability or mutation guarantees.

### 7.2 Property-based tests

Generate many shapes and values.

Examples:

- `reshape(x, originalShape) == x`
- `transpose(transpose(x)) == x`
- `x + 0 == x`
- `x * 1 == x`
- `sum(concat(parts)) == sum(parts)` within tolerance
- `matmul(A, I) == A`
- serialization round-trip preserves shape, dtype, and values
- sorting output is ordered and is a permutation of input

Use deterministic seeds and print the seed on failure.

### 7.3 Differential tests

Compare Dart results with trusted Python implementations:

- NumPy for tensor and linear algebra operations.
- PyTorch for autograd and neural-network operations.
- scikit-learn for classical ML.
- Pandas or Arrow implementations for tabular behavior.
- ONNX Runtime for ONNX operator execution.

Differential workflow:

1. Generate a deterministic case.
2. Save inputs and metadata.
3. Compute Python reference output.
4. Compute Dart output.
5. Compare shape, dtype, values, warnings, and error class.
6. Save minimized failing fixture.

Production tests should consume checked-in fixtures.
A separate CI lane may regenerate fixtures and detect reference drift.

### 7.4 Metamorphic tests

Use relationships that remain true without a direct oracle:

- adding a constant then subtracting it restores finite values;
- standardized finite data has approximately zero mean;
- duplicated training samples should not change a deterministic mean-based estimator;
- permuting independent samples should not change deterministic batch metrics;
- model save/load preserves predictions.

### 7.5 Gradient tests

Every differentiable operation requires:

- analytic backward test;
- finite-difference gradient check;
- non-scalar output test with upstream gradient;
- broadcasting gradient test;
- repeated-use accumulation test;
- detached/no-grad test;
- higher-order test when supported;
- undefined-gradient behavior test.

Use central finite differences where suitable:

```text
f'(x) ≈ (f(x + ε) - f(x - ε)) / (2ε)
```

Choose epsilon by dtype and scale.
Do not use one universal epsilon.

### 7.6 Fuzz tests

Fuzz:

- shape parsing;
- indexing;
- slicing;
- serialized model parsing;
- CSV/JSON/NPY/ONNX parsing;
- C ABI argument validation;
- tensor byte-size calculations;
- malformed graphs;
- cyclic graph attempts;
- invalid UTF-8 metadata;
- truncated buffers.

A fuzz failure must create a minimized reproducible input under `repro/`.

### 7.7 Native memory tests

Run native tests with applicable tools:

- AddressSanitizer;
- UndefinedBehaviorSanitizer;
- LeakSanitizer;
- ThreadSanitizer where supported;
- Valgrind as an optional secondary check.

Test:

- double free;
- use after free;
- allocation failure;
- null handles;
- invalid device handles;
- misalignment;
- reference-count races;
- finalizer timing;
- view lifetime;
- shutdown with live tensors.

### 7.8 Concurrency tests

Test:

- parallel read-only operations;
- concurrent backend initialization;
- independent isolate use;
- cancellation;
- error propagation;
- no shared mutable Dart state without explicit synchronization;
- deterministic seeded operations under documented deterministic mode.

### 7.9 Performance regression tests

Do not fail CI on noisy microseconds alone.

Use:

- warm-up;
- enough repetitions;
- median and percentile reporting;
- fixed CPU affinity when available;
- relative thresholds with a noise budget;
- dedicated benchmark runners for release decisions.

---

## 8. Numeric Policy

Create a formal numeric specification before implementing many operations.

### 8.1 Required dtypes

Initial:

- `bool`
- `int8`
- `uint8`
- `int16`
- `uint16`
- `int32`
- `uint32`
- `int64`
- `float16`
- `bfloat16`
- `float32`
- `float64`

Later:

- complex dtypes;
- quantized dtypes;
- float8 variants where backend support is verified;
- 4-bit and lower packed formats for specialized inference.

### 8.2 Dtype promotion

Define and test:

- binary promotion table;
- scalar-to-tensor promotion;
- integer division behavior;
- reduction accumulator dtype;
- comparison result dtype;
- overflow behavior;
- safe and unsafe cast behavior;
- platform-independent integer semantics.

Do not copy NumPy, PyTorch, or another framework accidentally.
Choose a policy, document compatibility differences, and test it exhaustively.

### 8.3 Default tolerance guidance

These are starting points, not automatic truth:

| DType | Typical `rtol` | Typical `atol` |
|---|---:|---:|
| float64 | 1e-10 | 1e-12 |
| float32 | 1e-5 | 1e-6 |
| float16 | 5e-3 | 5e-3 |
| bfloat16 | 1e-2 | 1e-2 |

Each numerically sensitive operation must define its own tolerance.
Document backend-dependent variation.

### 8.4 Required floating-point edge cases

Every relevant operation must consider:

- `NaN`;
- positive and negative infinity;
- positive and negative zero;
- smallest normal values;
- subnormal values;
- maximum finite values;
- overflow;
- underflow;
- cancellation;
- repeated accumulation;
- non-associativity;
- empty reductions;
- all-NaN reductions;
- mixed finite and non-finite values.

### 8.5 Shape safety

All shape arithmetic must:

- reject negative dimensions;
- detect element-count overflow;
- detect byte-count overflow;
- support zero-sized dimensions;
- distinguish scalar shape `[]` from one-element shape `[1]`;
- validate strides;
- validate storage bounds for every view.

---

## 9. Error Model

Create typed exceptions in `dart_ml_core`.

Minimum classes:

- `DartMlException`
- `ShapeException`
- `DTypeException`
- `DeviceException`
- `BackendException`
- `AllocationException`
- `IndexException`
- `SerializationException`
- `OperatorNotSupportedException`
- `GradientException`
- `ConvergenceException`
- `DataValidationException`
- `ModelNotFittedException`

Rules:

- Error messages must contain actionable context.
- Never expose raw native pointers.
- Preserve native error codes internally.
- Do not use assertions for user-input validation.
- Assertions may enforce internal invariants in debug mode.
- Public failure semantics must be tested.

---

## 10. Phase 0: Governance, Workspace, and Verification Foundation

### Goal

Create a trustworthy repository skeleton before ML implementation.

### Deliverables

- Dart pub workspace.
- Package skeletons.
- Root analysis rules.
- `tool/verify.dart`.
- `tool/check_file_length.dart`.
- CI workflows.
- status, roadmap, compatibility, benchmark, security, and contribution documents.
- Native build-hook proof of concept.
- Stable C ABI “hello/runtime version” call.
- License inventory tool or document.

### Required tests

- Workspace resolves from a clean checkout.
- Every package can be analyzed.
- Line-limit checker catches an intentional fixture over 80 lines.
- Native library builds and loads.
- C ABI version mismatch returns a typed error.
- Missing native library returns a typed error.
- Verification command reports skipped optional hardware tests accurately.

### Edge cases

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

### Exit gate

Phase 0 is complete only when a clean checkout can run one documented verification command on every initially supported host OS.

---

## 11. Phase 1: Formal Specifications and Pure Dart Reference Core

### Goal

Define semantics before optimizing.

### Deliverables

- Tensor shape specification.
- Dtype specification.
- Device specification.
- Broadcasting specification.
- Indexing and slicing specification.
- Error specification.
- Pure Dart reference storage and kernels for a minimal dtype set.
- Deterministic random-number interface.
- Golden fixture format.

### Initial operations

- creation: zeros, ones, full, arange;
- reshape;
- flatten;
- transpose;
- contiguous copy;
- indexing;
- slicing;
- add, subtract, multiply, divide;
- sum, mean, min, max;
- matmul for rank-2 tensors.

### Required tests

- unit tests for each semantic rule;
- property tests for shapes and broadcasting;
- differential tests against NumPy;
- malformed-shape tests;
- deterministic random-seed tests;
- serialization of basic fixture metadata.

### Edge cases

- scalar tensor;
- empty tensor;
- zero-sized dimension;
- one-element tensor;
- rank mismatch;
- incompatible broadcasting;
- division by zero;
- integer overflow;
- reshape with inferred dimension;
- non-contiguous transpose;
- repeated dimension of size one;
- very large shape that overflows byte count.

### Exit gate

Every initial operation must match the written specification and Python reference fixtures across a broad generated test matrix.

---

## 12. Phase 2: Native CPU Tensor Runtime

### Goal

Move tensor storage and computation to safe, accelerated native memory.

### Deliverables

- Opaque tensor handles.
- Stable C ABI.
- Native allocation and deallocation.
- Reference counting or another documented ownership system.
- CPU backend dispatcher.
- Contiguous and strided storage.
- BLAS-backed matrix multiplication where available.
- Pure native fallback kernels.
- Backend capability reporting.
- Build hooks for native compilation/bundling.

### C ABI rules

- Expose opaque handles, not C++ classes.
- No exception may cross the C boundary.
- Every function returns a status code or a result structure.
- Error text is retrieved through a dedicated function.
- ABI version is queryable.
- Ownership transfer is explicit in function names and documentation.
- Struct sizes and versions are validated.

### Required tests

- Dart/native round-trip.
- Native unit tests independent of Dart.
- Differential operation tests.
- Allocation stress tests.
- repeated create/free cycles;
- views and shared storage;
- sanitizer suite;
- ABI compatibility test;
- backend initialization race test.

### Edge cases

- zero-byte allocation;
- allocation failure;
- null output pointer;
- double release;
- use after release;
- overlapping inputs and outputs;
- aliased views;
- unaligned input;
- negative or overflowing stride;
- operation cancelled during execution;
- process shutdown with live handles.

### Performance gate

For large matrix multiplication, confirm that the accelerated path is actually selected and report reproducible measurements. Do not require Python parity yet, but prevent obvious accidental scalar fallback.

### Exit gate

The native CPU runtime passes sanitizers, differential tests, ownership tests, and platform build tests.

---

## 13. Phase 3: Production Tensor API

### Goal

Provide an idiomatic, stable Dart tensor experience.

### Deliverables

- `Tensor`;
- `Shape`;
- `Stride`;
- `DType`;
- `Device`;
- storage/view abstraction;
- backend dispatcher;
- rich indexing;
- broadcasting;
- reductions;
- linear algebra foundation;
- random distributions;
- tensor serialization;
- asynchronous operation hooks where justified.

### API design rules

- Constructors validate eagerly.
- Expensive copies must be explicit or documented.
- Methods that return views must say so.
- In-place operations must end with `_` only if that convention is formally adopted and documented; otherwise use explicit names.
- Mutation must never surprise users through hidden aliasing.
- Device transfer must be explicit.
- Sync points must be documented for asynchronous backends.
- Public methods should accept named arguments when ambiguity is possible.

### Operation families

- creation;
- indexing;
- shape manipulation;
- elementwise arithmetic;
- comparison;
- logical;
- reductions;
- sorting and selection;
- linear algebra;
- statistics;
- random;
- FFT later in the phase;
- sparse tensors as a separately gated sub-phase.

### Required tests

For every operator:

- specification test;
- Python differential test;
- shape inference test;
- dtype inference test;
- device dispatch test;
- contiguous test;
- non-contiguous test;
- empty test;
- scalar test;
- NaN/infinity test;
- invalid-input test;
- serialization round-trip when relevant.

### Exit gate

A published operator compatibility table shows exactly what is implemented and how behavior differs from NumPy/PyTorch.

---

## 14. Phase 4: Automatic Differentiation

### Goal

Build a correct dynamic autograd engine integrated with tensor backends.

### Deliverables

- `requiresGrad`;
- computation graph nodes;
- backward engine;
- gradient accumulation;
- `detach`;
- `noGrad`;
- custom gradient registration;
- saved tensors;
- graph release;
- anomaly detection;
- optional retained graph;
- higher-order gradients for explicitly supported operations.

### Design requirements

- Backward rules live near operator specifications, not in one giant file.
- Each differentiable operator declares:
  - differentiable inputs;
  - saved values;
  - backward formula;
  - undefined points;
  - complex-number policy when added;
  - broadcast reduction behavior.
- Avoid reference cycles that leak graphs.
- Detect illegal in-place modification of saved values.
- Gradient accumulation dtype must be specified.

### Required tests

- finite-difference checks;
- PyTorch differential gradients;
- branch graphs;
- diamond graphs;
- repeated tensor use;
- multiple outputs;
- custom upstream gradient;
- broadcasting backward;
- view backward;
- detached tensors;
- no-grad regions;
- graph freed after backward;
- retained graph behavior;
- anomaly reporting;
- unsupported higher-order gradient.

### Edge cases

- non-scalar backward without upstream gradient;
- NaN gradient;
- infinite gradient;
- zero-sized tensor gradient;
- integer tensor marked for gradient;
- leaf versus non-leaf gradient retention;
- in-place modification after forward;
- backward called twice;
- cyclic graph attempt;
- exception during backward.

### Exit gate

Every stable differentiable tensor operator passes analytic, finite-difference, and PyTorch comparison tests.

---

## 15. Phase 5: Neural Networks and Optimization

### Goal

Support real model construction and training.

### Deliverables

- `Module`;
- `Parameter`;
- state dictionary;
- train/eval modes;
- `Sequential`;
- initialization;
- core layers;
- losses;
- optimizers;
- schedulers;
- gradient clipping;
- mixed-precision interface;
- checkpoint save/load.

### Initial layers

- Linear;
- ReLU, GELU, Sigmoid, Tanh;
- Dropout;
- Flatten;
- Embedding;
- LayerNorm;
- BatchNorm;
- Conv1D and Conv2D;
- pooling;
- basic recurrent layers after core stability;
- attention and transformer blocks after matrix and normalization maturity.

### Initial losses

- mean squared error;
- binary cross entropy;
- cross entropy;
- negative log likelihood;
- L1;
- Huber.

### Initial optimizers

- SGD;
- Momentum;
- Adam;
- AdamW;
- RMSProp.

### Required tests

- forward differential tests;
- backward differential tests;
- parameter discovery;
- nested module state;
- train/eval behavior;
- deterministic dropout with seed;
- optimizer one-step comparison with PyTorch;
- optimizer multi-step trajectory;
- checkpoint round-trip;
- shared parameter handling;
- frozen parameters;
- zero gradient behavior;
- gradient clipping.

### End-to-end acceptance models

- linear regression;
- XOR classifier;
- MNIST-like small classifier using a bundled tiny fixture;
- overfit-one-batch test;
- save/load prediction equivalence.

### Exit gate

At least three end-to-end models train reproducibly, converge according to documented thresholds, and match reference trajectories within justified tolerance.

---

## 16. Phase 6: DataFrame, Dataset, and Data Loading

### Goal

Create the data layer required for practical ML.

### Deliverables

- `Series`;
- `DataFrame`;
- schema;
- nullable columns;
- categorical data;
- row and column selection;
- filter;
- sort;
- group;
- join;
- aggregate;
- missing-value operations;
- CSV and JSON;
- Arrow C Data Interface;
- Arrow streaming;
- Parquet through a native backend;
- dataset abstractions;
- batching, shuffling, prefetching.

### Architectural rule

Prefer columnar storage and Arrow interoperability.
Do not model a serious DataFrame as only `List<Map<String, dynamic>>`.

### Required tests

- Pandas/Arrow differential fixtures;
- schema preservation;
- null handling;
- categorical round-trip;
- join variants;
- group aggregation;
- chunked input;
- streaming;
- CSV dialects;
- malformed records;
- Unicode;
- large-column count;
- empty table;
- zero-row table with schema;
- Parquet round-trip;
- Arrow zero-copy ownership behavior.

### Edge cases

- duplicate column names;
- mixed inferred types;
- all-null column;
- embedded newline in CSV;
- escaped quotes;
- invalid UTF-8 policy;
- timezone-aware timestamps;
- integer column with one missing value;
- NaN versus null;
- join with null keys;
- duplicate join keys;
- huge row count;
- cancellation while streaming.

### Exit gate

Common tabular pipelines are expressible, tested, and benchmarked without forcing all data into Dart object-per-cell storage.

---

## 17. Phase 7: Classical Machine Learning

### Goal

Provide a scikit-learn-style estimator ecosystem.

### Common contracts

```dart
abstract interface class Estimator<X, Y> {
  void fit(X features, Y target);
}

abstract interface class Predictor<X, Y> {
  Y predict(X features);
}
```

Also define:

- transformer;
- probabilistic predictor;
- partial-fit estimator;
- fitted-state contract;
- parameter inspection;
- cloning;
- pipeline;
- cross-validation splitters;
- metrics.

### Algorithm order

#### Preprocessing

- train/test split;
- standard scaler;
- min-max scaler;
- robust scaler;
- label encoder;
- one-hot encoder;
- imputation;
- polynomial features;
- feature selection basics.

#### Linear models

- linear regression;
- ridge;
- lasso;
- elastic net;
- logistic regression.

#### Neighbors and naive methods

- KNN classification/regression;
- nearest-neighbor search;
- Gaussian/Multinomial/Bernoulli Naive Bayes.

#### Trees and ensembles

- decision tree;
- random forest;
- extra trees;
- gradient boosting only after tree correctness and benchmark maturity.

#### Clustering and decomposition

- K-Means;
- DBSCAN;
- PCA;
- truncated SVD;
- Gaussian mixtures later.

#### Model selection

- K-fold;
- stratified K-fold;
- grid search;
- randomized search;
- pipelines;
- scoring.

### Required tests per estimator

- scikit-learn differential result;
- fitted/unfitted behavior;
- deterministic seed;
- input validation;
- single sample;
- single feature;
- constant feature;
- duplicated rows;
- missing data policy;
- multiclass behavior;
- sample weights when supported;
- serialization;
- parameter cloning;
- convergence warning/error;
- known small analytical dataset;
- large random dataset smoke test.

### Exit gate

Each stable estimator has a compatibility page, sklearn comparison fixtures, documented differences, complexity notes, and reproducible examples.

---

## 18. Phase 8: Statistics and Scientific Computing

### Goal

Cover the scientific utilities needed by ML users.

### Deliverables

- descriptive statistics;
- probability distributions;
- sampling;
- correlation and covariance;
- hypothesis tests;
- confidence intervals;
- numerical integration;
- optimization basics;
- interpolation;
- signal processing foundation;
- FFT integration.

### Testing

- SciPy/NumPy differential fixtures;
- analytical closed-form cases;
- extreme tails;
- invalid parameters;
- distribution normalization;
- random sampling moment tests with statistically justified bounds;
- deterministic seed behavior;
- precision across dtypes.

### Rule

Statistical tests must document assumptions.
Never return a p-value without clearly defined method and input constraints.

---

## 19. Phase 9: Interoperability and Model Formats

### Goal

Make DartML useful inside the existing ML world.

### Priority order

1. NPY/NPZ.
2. SafeTensors.
3. DLPack.
4. Apache Arrow C Data Interface.
5. ONNX import and validation.
6. ONNX export for supported graphs.
7. framework-specific bridge tools only when justified.

### DLPack requirements

- explicit producer/consumer ownership;
- device metadata;
- dtype mapping;
- shape/stride mapping;
- version handling;
- single-consumption semantics where required;
- zero-copy tests;
- deleter tests;
- stream semantics for devices.

### ONNX requirements

- opset-aware import;
- operator-version mapping;
- shape and type inference where supported;
- external data;
- dynamic shapes;
- initializers;
- graph validation;
- unsupported operator diagnostics;
- conformance fixtures;
- comparison against ONNX Runtime.

### Parser security tests

- truncated input;
- oversized claimed length;
- integer overflow;
- deep nesting;
- duplicate names;
- cyclic graph;
- external path traversal;
- decompression bomb where formats allow compression;
- malicious metadata size;
- unsupported opset;
- invalid tensor raw-data length.

### Exit gate

Interoperability features pass conformance suites and never silently reinterpret unsupported data.

---

## 20. Phase 10: GPU Backends

### Goal

Train and infer on modern accelerators.

### Backend sequence

1. Metal for Apple development hardware or CUDA for available NVIDIA hardware.
2. The other of Metal/CUDA.
3. WebGPU.
4. ROCm when test hardware is available.
5. Platform inference delegates and specialized accelerators.

Do not implement a backend that cannot be continuously tested.

### Common backend contract

- device enumeration;
- allocation;
- transfer;
- synchronization;
- stream/queue;
- event;
- kernel launch;
- error retrieval;
- capability query;
- memory statistics;
- deterministic-mode support status.

### Required operation progression

1. elementwise;
2. reductions;
3. matmul;
4. convolution;
5. normalization;
6. softmax;
7. attention primitives;
8. fused kernels.

### Required tests

- CPU/GPU differential;
- device transfer;
- non-contiguous input;
- zero-size tensor;
- out-of-memory;
- invalid device;
- synchronization;
- multiple streams/queues;
- asynchronous error;
- mixed precision;
- deterministic mode;
- long-running allocation stress;
- backend shutdown.

### Performance and honesty rules

- Report data-transfer time separately.
- Report kernel time and end-to-end time.
- State whether compilation time is included.
- Never compare warmed Dart GPU runs to cold Python runs.
- Use the same dtype, shape, algorithm, and synchronization points.
- Publish raw benchmark data.

### Exit gate

A backend is stable only when it has continuous access to real hardware, conformance coverage, memory stress tests, and reproducible benchmark reports.

---

## 21. Phase 11: Graph Capture, Compiler, and Optimization

### Goal

Optimize eager models without changing observable results beyond documented numeric tolerance.

### Deliverables

- graph IR;
- shape inference;
- type inference;
- constant folding;
- dead-code elimination;
- common subexpression rules where safe;
- operation fusion;
- memory planning;
- backend lowering;
- graph cache;
- model AOT export;
- quantization pipeline later.

### Compiler correctness tests

For every optimization:

- optimized versus unoptimized output;
- gradient equivalence when training graphs are supported;
- dynamic shape behavior;
- aliasing behavior;
- side-effect ordering;
- error equivalence;
- random-operation semantics;
- stateful module behavior;
- invalid graph diagnostics.

### Edge cases

- dynamic rank;
- dynamic dimension;
- zero-sized dimension;
- control flow;
- mutation;
- shared parameters;
- random nodes;
- unsupported operator fallback;
- backend-specific lowering failure;
- cache invalidation.

### Exit gate

Every optimization can be disabled independently and has a correctness proof through tests, not assumption.

---

## 22. Phase 12: Distributed and Parallel Training

### Goal

Support multi-device and multi-process workloads.

### Deliverables

- process group abstraction;
- rank/world size;
- collectives;
- data parallel wrapper;
- distributed sampler;
- checkpoint sharding;
- failure reporting;
- launcher;
- backend adapters such as NCCL or other available native collectives.

### Required tests

- single-process equivalence;
- two-process local test;
- all-reduce correctness;
- rank mismatch;
- worker timeout;
- worker failure;
- uneven batch;
- deterministic sampler;
- checkpoint resume;
- duplicated or missing rank;
- cancellation;
- network interruption simulation.

### Rule

Dart isolates are not a substitute for a proven high-performance collective runtime.
Use native or process-level systems with explicit contracts.

### Exit gate

Distributed results match single-device reference behavior for supported models and failure modes are recoverable or clearly reported.

---

## 23. Phase 13: Tooling, REPL, Visualization, and Flutter Experience

### Goal

Make the ecosystem pleasant enough to adopt.

### Deliverables

- CLI diagnostics;
- tensor/model inspector;
- benchmark runner;
- converter;
- interactive REPL or notebook integration;
- inline table display;
- plotting adapters;
- Flutter inference examples;
- background isolate guidance;
- asset/model bundling;
- mobile performance profiler;
- platform compatibility diagnostics.

### Required tests

- CLI golden tests;
- invalid command handling;
- model inspection of malformed files;
- Flutter asset loading;
- hot restart behavior;
- isolate transfer behavior;
- Android/iOS lifecycle;
- desktop path handling;
- web fallback;
- offline model execution.

### Exit gate

A new user can install the package, train or load a small model, inspect it, run inference, and debug common failures using documented commands.

---

## 24. Phase 14: Security, Release Engineering, and Ecosystem Hardening

### Goal

Prepare stable public releases.

### Security requirements

- threat model;
- responsible disclosure process;
- parser limits;
- safe external-file handling;
- dependency/license audit;
- generated-artifact provenance;
- checksum verification for downloaded native assets;
- reproducible builds where feasible;
- no arbitrary code execution during model loading;
- clear policy for untrusted models.

### Release requirements

- semantic versioning;
- changelog;
- migration guide;
- API snapshot;
- package score checks;
- clean-package publish dry run;
- signed tags where available;
- generated source provenance;
- platform artifact checksums;
- compatibility report;
- benchmark report;
- known limitations.

### Release candidate gate

A release candidate must pass:

- all stable-platform CI;
- full conformance suite;
- sanitizer suite;
- documentation generation;
- package publish dry run;
- examples;
- compatibility audit;
- performance regression review;
- security checklist.

The AI may prepare a release.
The owner must explicitly authorize publishing.

---

## 25. Python Parity Program

Python parity is split into measurable tracks.

### 25.1 API capability parity

Maintain a matrix:

| Domain | Reference | DartML status | Differences |
|---|---|---|---|
| Tensor creation | NumPy/PyTorch | | |
| Broadcasting | NumPy | | |
| Autograd | PyTorch | | |
| Layers | PyTorch | | |
| DataFrame | Pandas/Arrow | | |
| Estimators | scikit-learn | | |
| Model format | ONNX | | |

Do not chase identical naming when Dart conventions produce a better API.
Document intentional differences.

### 25.2 Correctness parity

A feature qualifies when:

- standard examples pass;
- generated differential tests pass;
- edge cases pass;
- error behavior is intentional;
- numeric error is within justified tolerance.

### 25.3 Performance parity

Benchmark by workload category:

- small-tensor latency;
- large-tensor throughput;
- matrix multiplication;
- convolution;
- data loading;
- model training step;
- inference latency;
- memory use;
- startup time;
- mobile package size.

A single favorable benchmark never proves parity.

### 25.4 Ecosystem parity

Track:

- documentation quality;
- examples;
- supported platforms;
- model formats;
- debugging;
- profiling;
- release stability;
- community contribution process.

---

## 26. Benchmark Protocol

### Required metadata

Every benchmark report must include:

```text
Commit:
Dart version:
Python version:
Reference library version:
Compiler:
Native backend:
OS:
CPU:
GPU:
RAM:
Power mode:
DType:
Shape:
Warm-up count:
Measured iterations:
Synchronization method:
```

### Fair-comparison rules

- Same mathematical operation.
- Same input shape.
- Same dtype.
- Same device.
- Same thread count when controllable.
- Same inclusion/exclusion of transfer.
- Same warm/cold conditions.
- Synchronize asynchronous devices before timing completion.
- Report median and p95.
- Keep raw samples.
- Repeat on more than one run.
- Do not manually select only favorable results.

### Performance regression policy

- Mark a baseline.
- Compare statistically, not from one sample.
- Investigate regressions beyond the agreed noise threshold.
- Record accepted regressions with a decision note.

---

## 27. Dependency Policy

Before adding a dependency, record:

- exact purpose;
- why standard Dart/native facilities are insufficient;
- license;
- maintenance status;
- security history;
- transitive dependency cost;
- binary size impact;
- platform limitations;
- replacement difficulty.

Rules:

- Pin Python reference dependencies in a lock file.
- Keep Dart constraints compatible with supported stable SDKs.
- Avoid depending on abandoned packages for core functionality.
- Wrap third-party native libraries behind internal interfaces.
- Never expose a third-party type throughout the public API unless interoperability requires it.

---

## 28. Documentation Standard

### Public API example

```dart
/// Returns a view with [shape] when storage layout permits.
///
/// The total number of elements must remain unchanged. When the current
/// strides cannot represent the requested shape, this method returns a
/// contiguous copy only if [allowCopy] is true.
///
/// Throws [ShapeException] when the element count differs.
Tensor reshape(Shape shape, {bool allowCopy = true});
```

### Every operator specification must state

- mathematical definition;
- accepted ranks;
- broadcasting;
- dtype promotion;
- output shape;
- output dtype;
- device behavior;
- view/copy behavior;
- gradient;
- errors;
- examples;
- Python compatibility;
- known backend differences.

### Tutorial requirements

Every major phase adds:

- concept explanation;
- smallest runnable example;
- practical example;
- common mistakes;
- troubleshooting;
- performance notes.

---

## 29. Coding Standard

### Dart

- Follow Effective Dart.
- Use sound null safety.
- Prefer immutable value objects.
- Prefer sealed result/state hierarchies where useful.
- Avoid `dynamic` in core numeric paths.
- Avoid reflection-dependent designs.
- Keep public exports curated.
- Use extension types or value classes only with clear benefit.
- Do not hide expensive work in getters.
- Do not perform implicit device synchronization in innocent-looking getters without documentation.
- Keep error messages stable enough for humans, but tests should prefer exception type and structured fields over exact prose.

### Native code

- Use RAII internally where C++ is used.
- Expose only C ABI.
- No uncaught exception crosses ABI.
- Validate every pointer and size from FFI.
- Use checked arithmetic for allocation sizes.
- Keep ownership explicit.
- Avoid global mutable state.
- Make initialization idempotent.
- Compile with strict warnings and treat warnings as errors in CI.

### Comments

- Explain why, constraints, invariants, and numerical reasoning.
- Do not narrate obvious syntax.
- Every unsafe block or pointer conversion requires a short invariant comment.

---

## 30. Git and Change Discipline

Even when one AI performs all work, preserve professional change history.

For each logical change:

- update tests with implementation;
- update status/docs;
- create a concise change summary;
- do not mix formatting of unrelated files;
- preserve bisectability;
- avoid generated-file churn;
- never rewrite stable history after a public release.

Suggested branch naming:

```text
phase-03/tensor-broadcasting
fix/autograd-view-lifetime
perf/cpu-matmul-dispatch
```

Suggested change summary:

```text
tensor: add zero-dimension broadcasting
```

---

## 31. Definition of Done for Any Feature

A feature is complete only when all applicable items are true:

- [ ] Specification exists.
- [ ] API is consistent with package boundaries.
- [ ] Implementation is complete.
- [ ] Handwritten files are at most 80 lines.
- [ ] Unit tests pass.
- [ ] Edge-case tests pass.
- [ ] Property tests pass.
- [ ] Differential tests pass.
- [ ] Gradient tests pass when applicable.
- [ ] Fuzz tests are added when parsing/indexing/memory is involved.
- [ ] Native sanitizer tests pass when applicable.
- [ ] Integration tests pass.
- [ ] Benchmarks exist when performance matters.
- [ ] Public documentation is complete.
- [ ] Example is updated.
- [ ] Compatibility matrix is updated.
- [ ] Changelog/status is updated.
- [ ] Repository-wide verification passes.
- [ ] Unsupported behavior is documented.
- [ ] No unverified parity claim is made.

---

## 32. Phase Completion Report Template

At the end of each phase, the AI must create:

```markdown
# Phase N Completion Report

## Scope Completed

## Public APIs Added

## Specifications Added

## Tests
- Unit:
- Property:
- Differential:
- Gradient:
- Fuzz:
- Integration:
- Native sanitizers:

## Platforms Verified

## Benchmarks

## Known Limitations

## Deferred Work

## Compatibility Differences

## Verification Commands and Results

## Exit Gate Decision
PASS / FAIL

## Evidence Paths
```

A phase cannot be marked `PASS` if required hardware tests were merely assumed.

---

## 33. First Implementation Sequence

Begin in this exact order:

1. Create the workspace and documents.
2. Add strict analyzer configuration.
3. Add the 80-line enforcement tool and its tests.
4. Add the root verification runner.
5. Add CI for Dart stable on Linux, macOS, and Windows.
6. Create `dart_ml_core`.
7. Specify `Shape`, `DType`, `Device`, and errors.
8. Implement and test `Shape`.
9. Implement and test dtype metadata.
10. Implement a minimal pure-Dart float64 reference tensor.
11. Generate NumPy golden fixtures.
12. Add creation, reshape, transpose, add, multiply, sum, and rank-2 matmul.
13. Add property and differential tests.
14. Design the stable C ABI.
15. Add a native runtime version handshake.
16. Move storage to native memory without changing public semantics.
17. Add sanitizer CI.
18. Continue Phase 2 and Phase 3 gates.

Do not start neural networks before tensor semantics, storage ownership, and differential correctness are stable.

---

## 34. Initial Minimal Public API Target

```dart
import 'package:dart_ml/dart_ml.dart';

void main() {
  final a = Tensor.fromList([
    [1.0, 2.0],
    [3.0, 4.0],
  ]);

  final b = Tensor.eye(2);
  final c = a.matmul(b);

  print(c);
  c.dispose();
  b.dispose();
  a.dispose();
}
```

The final ownership API may use automatic finalization, explicit disposal, or both.
The decision must be documented and stress-tested.
No example may encourage unsafe lifetime behavior.

---

## 35. Initial Edge-Case Matrix

The AI must create parameterized tests covering combinations of:

### Shapes

- `[]`
- `[0]`
- `[1]`
- `[2]`
- `[0, 3]`
- `[2, 0]`
- `[1, 3]`
- `[2, 3]`
- `[2, 1, 3]`
- high-rank small tensors
- overflow-sized metadata without allocation

### Values

- `0`
- `-0.0`
- `1`
- `-1`
- smallest finite magnitude
- largest finite magnitude
- `NaN`
- positive infinity
- negative infinity
- repeated values
- random seeded values

### Layouts

- contiguous;
- transposed;
- sliced;
- broadcasted;
- zero-stride;
- offset view;
- reversed/negative stride only after formally supported.

### Devices

- pure Dart reference;
- native CPU;
- each available GPU;
- unavailable/invalid device.

### Ownership

- original tensor;
- view;
- clone;
- disposed owner;
- disposed view;
- multiple aliases;
- finalizer path;
- explicit release path.

---

## 36. AI Prompt to Resume Work

Use this instruction with an AI coding agent:

```text
Read INSTRUCTION.md completely. Then read ROADMAP.md and STATUS.md.
Work only on the current phase and choose the smallest complete deliverable.
Before coding, inspect the relevant specifications, implementation, and tests.
Write or update the specification and tests first where practical.
Keep every handwritten code/test/native file at or below 80 physical lines.
Run focused tests, package tests, differential checks, and the root verification
command. Fix every failure caused by the change. Update documentation,
COMPATIBILITY.md, CHANGELOG.md, and STATUS.md. Never claim success for a test
you did not run. Never invent benchmark results. Finish by reporting changed
files, commands run, exact results, limitations, and the next smallest task.
```

---

## 37. Sources and Standards to Follow

Use current official specifications and documentation rather than memory:

- Dart C interoperability: <https://dart.dev/interop/c-interop>
- Dart build hooks/native assets: <https://dart.dev/tools/hooks>
- Dart pub workspaces: <https://dart.dev/tools/pub/workspaces>
- Dart package layout: <https://dart.dev/tools/pub/package-layout>
- Dart testing: <https://dart.dev/tools/testing>
- Effective Dart: <https://dart.dev/effective-dart>
- ONNX: <https://onnx.ai/>
- ONNX operators: <https://onnx.ai/onnx/operators/>
- DLPack: <https://dmlc.github.io/dlpack/latest/>
- Apache Arrow format: <https://arrow.apache.org/docs/format/>
- Arrow C Data Interface: <https://arrow.apache.org/docs/format/CDataInterface.html>

When a specification version changes:

1. record the old and new version;
2. review compatibility;
3. update fixtures;
4. rerun conformance tests;
5. document migration impact.

---

## 38. Final Success Standard

The project succeeds only when users can independently reproduce evidence that DartML provides:

- correct tensor semantics;
- safe native memory;
- reliable autograd;
- useful neural-network training;
- practical data tooling;
- classical ML algorithms;
- model interoperability;
- accelerated execution;
- clear documentation;
- stable releases;
- honest compatibility reporting.

The goal is not to imitate Python superficially.

The goal is to build a Dart-native ML ecosystem whose correctness, performance, usability, and interoperability are strong enough that developers can choose Dart for serious ML work based on evidence.
