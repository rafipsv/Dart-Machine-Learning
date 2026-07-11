import 'dart:io';

import 'package:test/test.dart';

import '../../tool/file_length/path_utils.dart';
import '../../tool/file_length/scanner.dart';
import 'helpers.dart';

void main() {
  test('line endings and final newline handling are physical lines', () {
    final repo = FixtureRepo.create();
    addTearDown(repo.dispose);
    repo.writeText('lib/lf.dart', List.filled(80, '// line').join('\n'));
    repo.writeText('lib/crlf.dart', List.filled(80, '// line').join('\r\n'));
    repo.writeText(
      'lib/final_newline.dart',
      '${List.filled(80, '//').join('\n')}\n',
    );
    repo.writeText(
      'lib/no_final_newline.dart',
      List.filled(81, '//').join('\n'),
    );

    final paths = scanLengths(repo.root).violations.map((v) => v.path).toList();

    expect(paths, ['lib/no_final_newline.dart']);
  });

  test('path normalization accepts Windows-style separators', () {
    expect(normalizePath(r'lib\src\file.dart'), 'lib/src/file.dart');
  });

  test('symlinks outside repository are not followed', () {
    final repo = FixtureRepo.create();
    final outside = FixtureRepo.create('dart_ml_outside_');
    addTearDown(repo.dispose);
    addTearDown(outside.dispose);
    outside.writeLines('long.dart', 120);
    try {
      Link(
        '${repo.root.path}/lib/outside.dart',
      ).createSync('${outside.root.path}/long.dart', recursive: true);
    } on FileSystemException {
      markTestSkipped('Host does not permit symlink fixture creation.');
    }

    expect(scanLengths(repo.root).passed, true);
  });
}
