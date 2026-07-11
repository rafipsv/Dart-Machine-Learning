import 'package:test/test.dart';

import '../../tool/file_length/scanner.dart';
import 'helpers.dart';

void main() {
  test('pubspec.lock and Markdown files over 80 lines are excluded', () {
    final repo = FixtureRepo.create();
    addTearDown(repo.dispose);
    repo.writeLines('pubspec.lock', 120);
    repo.writeLines('README.md', 120);

    expect(scanLengths(repo.root).passed, true);
  });

  test('cache and build directories are excluded deliberately', () {
    final repo = FixtureRepo.create();
    addTearDown(repo.dispose);
    repo.writeLines('.dart_tool/generated.dart', 120);
    repo.writeLines('build/output.dart', 120);
    repo.writeLines('cache/output.dart', 120);
    repo.writeLines('.git/hooks/hook.dart', 120);

    expect(scanLengths(repo.root).passed, true);
  });

  test('nested cache project directories are scanned', () {
    final repo = FixtureRepo.create();
    addTearDown(repo.dispose);
    repo.writeLines('lib/cache/hidden.dart', 81);
    repo.writeLines('packages/example/cache/config.yaml', 82);

    final paths = scanLengths(repo.root).violations.map((v) => v.path).toList();

    expect(paths, [
      'lib/cache/hidden.dart',
      'packages/example/cache/config.yaml',
    ]);
  });

  test('nested tmp and temp project directories are scanned', () {
    final repo = FixtureRepo.create();
    addTearDown(repo.dispose);
    repo.writeLines('lib/src/tmp/hidden.dart', 81);
    repo.writeLines('packages/example/temp/config.yaml', 82);

    final paths = scanLengths(repo.root).violations.map((v) => v.path).toList();

    expect(paths, [
      'lib/src/tmp/hidden.dart',
      'packages/example/temp/config.yaml',
    ]);
  });

  test('paths containing spaces and non-ASCII characters are handled', () {
    final repo = FixtureRepo.create('dart ml_日本_');
    addTearDown(repo.dispose);
    repo.writeLines('space dir/naive file.dart', 80);
    repo.writeLines('unicode/বাংলা.dart', 81);

    final violations = scanLengths(repo.root).violations;

    expect(violations.single.path, 'unicode/বাংলা.dart');
  });
}
