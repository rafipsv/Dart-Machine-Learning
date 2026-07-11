import 'package:test/test.dart';

import '../../tool/file_length/scanner.dart';
import 'helpers.dart';

void main() {
  test('checker returns exit code 0 for passing fixture', () async {
    final repo = FixtureRepo.create();
    addTearDown(repo.dispose);
    repo.writeLines('lib/good.dart', 80);

    final result = await runChecker(repo.root.path);

    expect(result.exitCode, 0);
    expect(outputOf(result), isEmpty);
  });

  test('invalid applicable text is reported explicitly', () {
    final repo = FixtureRepo.create();
    addTearDown(repo.dispose);
    repo.writeBytes('lib/bad.dart', [0xff, 0xfe, 0xfd]);

    final result = scanLengths(repo.root);

    expect(result.passed, false);
    expect(result.errors.single, contains('lib/bad.dart: invalid text'));
  });

  test('real repository currently passes the checker', () async {
    final result = await runChecker('.');

    expect(result.exitCode, 0);
    expect(outputOf(result), isEmpty);
  });
}
