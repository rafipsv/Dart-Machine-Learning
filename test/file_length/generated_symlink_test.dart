import 'dart:io';

import 'package:test/test.dart';

import '../../tool/file_length/generated.dart';
import '../../tool/file_length/scanner.dart';
import 'helpers.dart';

void main() {
  test('generator symlinks outside the repository are rejected', () {
    final repo = FixtureRepo.create();
    final outside = FixtureRepo.create('dart_ml_generator_outside_');
    addTearDown(repo.dispose);
    addTearDown(outside.dispose);
    outside.writeText('make.dart', '// outside generator');
    try {
      Link(
        '${repo.root.path}/tool/generators/make.dart',
      ).createSync('${outside.root.path}/make.dart', recursive: true);
    } on FileSystemException {
      markTestSkipped('Host does not permit symlink fixture creation.');
    }
    repo.writeText(
      'lib/generated/bad.dart',
      generated('tool/generators/make.dart'),
    );

    final violations = scanLengths(repo.root).violations;

    expect(violations.single.path, 'lib/generated/bad.dart');
  });
}

String generated(String provenance) {
  final body = List<String>.filled(82, '// body').join('\n');
  return '$generatedMarker\n$doNotEditMarker\n'
      '$provenancePrefix$provenance\n$body';
}
