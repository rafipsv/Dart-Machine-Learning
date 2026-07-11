import 'dart:io';

import 'file_length/scanner.dart';

void main(List<String> args) {
  if (args.length > 1) {
    stderr.writeln('Usage: dart run tool/check_file_length.dart [root]');
    exitCode = 64;
    return;
  }

  final root = args.isEmpty ? Directory.current : Directory(args.single);
  final result = scanLengths(root);
  for (final error in result.errors) {
    stderr.writeln(error);
  }
  for (final violation in result.violations) {
    stdout.writeln(
      '${violation.path}: ${violation.lines} lines '
      '(max ${violation.maxLines})',
    );
  }
  exitCode = result.passed ? 0 : 1;
}
