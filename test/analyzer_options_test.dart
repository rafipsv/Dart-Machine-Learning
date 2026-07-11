import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('strict analyzer configuration rejects raw types', () async {
    final temp = Directory.systemTemp.createTempSync('dart_ml_analyzer_');
    addTearDown(() {
      if (temp.existsSync()) {
        temp.deleteSync(recursive: true);
      }
    });

    File(
      '${temp.path}/analysis_options.yaml',
    ).writeAsStringSync(File('analysis_options.yaml').readAsStringSync());
    File('${temp.path}/pubspec.yaml').writeAsStringSync('''
name: analyzer_fixture
publish_to: none

environment:
  sdk: ">=3.9.0 <4.0.0"
''');

    final lib = Directory('${temp.path}/lib');
    lib.createSync();
    File('${lib.path}/bad.dart').writeAsStringSync('''
void acceptsRawList(List values) {
  values.add(1);
}
''');

    final result = await Process.run(Platform.resolvedExecutable, [
      'analyze',
      '--fatal-infos',
      temp.path,
    ]);

    expect(result.exitCode, isNot(0));
    expect('${result.stdout}${result.stderr}', contains('List'));
  });
}
