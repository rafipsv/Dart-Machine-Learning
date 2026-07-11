import 'dart:io';

final class FixtureRepo {
  FixtureRepo._(this.root);

  final Directory root;

  static FixtureRepo create([String prefix = 'dart_ml_length_']) {
    return FixtureRepo._(Directory.systemTemp.createTempSync(prefix));
  }

  void dispose() {
    if (root.existsSync()) {
      root.deleteSync(recursive: true);
    }
  }

  File writeLines(String path, int count, {String text = '// line'}) {
    return writeText(path, List<String>.filled(count, text).join('\n'));
  }

  File writeText(String path, String text) {
    final file = File('${root.path}/$path');
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(text);
    return file;
  }

  File writeBytes(String path, List<int> bytes) {
    final file = File('${root.path}/$path');
    file.parent.createSync(recursive: true);
    file.writeAsBytesSync(bytes);
    return file;
  }
}

Future<ProcessResult> runChecker(String rootPath) {
  return Process.run(Platform.resolvedExecutable, [
    'run',
    'tool/check_file_length.dart',
    rootPath,
  ]);
}

String outputOf(ProcessResult result) => '${result.stdout}${result.stderr}';
