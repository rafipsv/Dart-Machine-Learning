import 'package:test/test.dart';

import '../../tool/file_length/generated.dart';
import '../../tool/file_length/scanner.dart';
import 'helpers.dart';

void main() {
  test('canonical generated header with approved generator is exempt', () {
    final repo = FixtureRepo.create();
    addTearDown(repo.dispose);
    repo.writeText('tool/generators/make.dart', '// generator');
    repo.writeText(
      'lib/generated/good.dart',
      generated('tool/generators/make.dart'),
    );

    expect(scanLengths(repo.root).passed, true);
  });

  test('fake generated headers cannot bypass the line limit', () {
    final repo = FixtureRepo.create();
    addTearDown(repo.dispose);
    repo.writeText('pubspec.yaml', 'name: fake');
    repo.writeText('tool/generators/make.dart', '// generator');
    for (final path in _badPaths.entries) {
      repo.writeText(path.key, path.value);
    }

    final paths = scanLengths(repo.root).violations.map((v) => v.path).toList();

    expect(paths, _badPaths.keys.toList()..sort());
  });

  test('windows-style approved provenance is normalized', () {
    final repo = FixtureRepo.create();
    addTearDown(repo.dispose);
    repo.writeText('tool/generators/make.dart', '// generator');
    repo.writeText(
      'lib/generated/win.dart',
      generated(r'tool\generators\make.dart'),
    );

    expect(scanLengths(repo.root).passed, true);
  });
}

Map<String, String> get _badPaths => {
  'lib/generated/pubspec.dart': generated('pubspec.yaml'),
  'lib/generated/word.dart': _oversized('// generated'),
  'lib/generated/edit.dart': _header('tool/generators/make.dart', edit: false),
  'lib/generated/escape.dart': generated('../tool/generators/make.dart'),
  'lib/generated/absolute.dart': generated('/tool/generators/make.dart'),
  'lib/generated/drive.dart': generated(r'C:\tool\generators\make.dart'),
  'lib/generated/missing.dart': generated('tool/generators/missing.dart'),
  'lib/generated/self.dart': generated('lib/generated/self.dart'),
  'lib/not_generated.dart': generated('tool/generators/make.dart'),
};

String generated(String provenance) => _header(provenance);

String _header(String provenance, {bool edit = true}) {
  final second = edit ? doNotEditMarker : '// editable';
  return _oversized('$generatedMarker\n$second\n$provenancePrefix$provenance');
}

String _oversized(String header) {
  final body = List<String>.filled(82, '// body').join('\n');
  return '$header\n$body';
}
