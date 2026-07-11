import 'dart:io';

import 'generated.dart';
import 'model.dart';
import 'path_utils.dart';
import 'policy.dart';
import 'walker.dart';

LengthResult scanLengths(
  Directory root, {
  DirectoryLister listDirectory = defaultListDirectory,
}) {
  final violations = <LengthViolation>[];
  final errors = <String>[];
  if (!root.existsSync()) {
    return LengthResult(violations, ['Root not found: ${root.path}']);
  }

  for (final file in collectFiles(root, errors, listDirectory)) {
    final relative = relativePath(root, file);
    try {
      final lines = file.readAsLinesSync();
      if (generatedExempt(root, file, lines)) {
        continue;
      }
      if (lines.length > maxHandwrittenLines) {
        violations.add(
          LengthViolation(relative, lines.length, maxHandwrittenLines),
        );
      }
    } on FileSystemException catch (error) {
      final message = error.osError?.message ?? error.message;
      final kind = message.contains('decode') ? 'invalid text' : 'unreadable';
      errors.add('$relative: $kind ($message)');
    } on FormatException catch (error) {
      errors.add('$relative: invalid text (${error.message})');
    }
  }

  violations.sort((a, b) => a.path.compareTo(b.path));
  errors.sort();
  return LengthResult(violations, errors);
}
