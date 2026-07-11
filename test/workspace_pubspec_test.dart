import 'dart:io';

import 'package:test/test.dart';

const List<String> packages = [
  'dart_ml',
  'dart_ml_core',
  'dart_ml_tensor',
  'dart_ml_autograd',
  'dart_ml_nn',
  'dart_ml_optim',
  'dart_ml_data',
  'dart_ml_stats',
  'dart_ml_learn',
  'dart_ml_io',
  'dart_ml_onnx',
  'dart_ml_runtime',
  'dart_ml_flutter',
  'dart_ml_cli',
];

void main() {
  test('root pubspec lists every Phase 0 package skeleton', () {
    final root = File('pubspec.yaml').readAsStringSync();

    for (final package in packages) {
      expect(root, contains('packages/$package'));
    }
  });

  test('workspace packages use shared resolution', () {
    for (final package in packages) {
      final pubspec = File('packages/$package/pubspec.yaml').readAsStringSync();

      expect(pubspec, contains('name: $package'));
      expect(pubspec, contains('resolution: workspace'));
      expect(pubspec, contains('publish_to: none'));
    }
  });

  test('workspace packages inherit root analyzer configuration', () {
    for (final package in packages) {
      expect(
        File('packages/$package/analysis_options.yaml').existsSync(),
        false,
      );
    }
  });
}
