import 'package:test/test.dart';

import '../../tool/file_length/scanner.dart';
import 'helpers.dart';

void main() {
  test('handwritten file with exactly 80 lines passes', () {
    final repo = FixtureRepo.create();
    addTearDown(repo.dispose);
    repo.writeLines('lib/eighty.dart', 80);

    expect(scanLengths(repo.root).passed, true);
  });

  test('handwritten file with 81 lines fails', () async {
    final repo = FixtureRepo.create();
    addTearDown(repo.dispose);
    repo.writeLines('lib/eighty_one.dart', 81);

    final result = await runChecker(repo.root.path);

    expect(result.exitCode, 1);
    expect(outputOf(result), contains('lib/eighty_one.dart: 81 lines'));
    expect(outputOf(result), contains('(max 80)'));
  });

  test('multiple violations are all reported in deterministic order', () {
    final repo = FixtureRepo.create();
    addTearDown(repo.dispose);
    repo.writeLines('zeta.dart', 82);
    repo.writeLines('alpha.dart', 83);

    final paths = scanLengths(repo.root).violations.map((v) => v.path).toList();

    expect(paths, ['alpha.dart', 'zeta.dart']);
  });

  test('nested handwritten source files are scanned', () {
    final repo = FixtureRepo.create();
    addTearDown(repo.dispose);
    repo.writeLines('packages/core/lib/src/deep.dart', 81);

    final violations = scanLengths(repo.root).violations;

    expect(violations.single.path, 'packages/core/lib/src/deep.dart');
  });
}
