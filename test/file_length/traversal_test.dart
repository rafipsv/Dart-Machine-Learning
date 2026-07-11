import 'dart:io';

import 'package:test/test.dart';

import '../../tool/file_length/scanner.dart';
import '../../tool/file_length/walker.dart';
import 'helpers.dart';

void main() {
  test('directory listing failures are reported and scanning continues', () {
    final repo = FixtureRepo.create();
    addTearDown(repo.dispose);
    repo.writeLines('a/fail/ignored.dart', 81);
    repo.writeLines('b/violation.dart', 82);

    final result = scanLengths(
      repo.root,
      listDirectory: failingLister(repo, {'a/fail'}),
    );

    expect(result.errors, ['a/fail: unreadable directory (denied)']);
    expect(result.violations.single.path, 'b/violation.dart');
  });

  test('multiple directory listing failures are sorted deterministically', () {
    final repo = FixtureRepo.create();
    addTearDown(repo.dispose);
    repo.writeLines('z/fail.dart', 1);
    repo.writeLines('a/fail.dart', 1);

    final result = scanLengths(
      repo.root,
      listDirectory: failingLister(repo, {'z', 'a'}),
    );

    expect(result.passed, false);
    expect(result.errors, [
      'a: unreadable directory (denied)',
      'z: unreadable directory (denied)',
    ]);
  });

  test('cli exits nonzero when checker errors exist', () async {
    final repo = FixtureRepo.create();
    addTearDown(repo.dispose);
    repo.writeBytes('lib/bad.dart', [0xff, 0xfe, 0xfd]);

    final result = await runChecker(repo.root.path);

    expect(result.exitCode, 1);
    expect(outputOf(result), contains('lib/bad.dart: invalid text'));
  });
}

DirectoryLister failingLister(FixtureRepo repo, Set<String> failingPaths) {
  return (directory) {
    final rootPath = repo.root.path;
    final relative = directory.path == rootPath
        ? '.'
        : directory.path.substring(rootPath.length + 1);
    if (failingPaths.contains(relative)) {
      throw const FileSystemException('denied');
    }
    return directory.listSync(followLinks: false);
  };
}
