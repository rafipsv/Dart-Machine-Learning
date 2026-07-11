import 'dart:io';

import 'path_utils.dart';

// Canonical generated header:
// line 1: generatedMarker
// line 2: doNotEditMarker
// line 3: provenancePrefix + approved generator path
const generatedMarker = '// GENERATED CODE - DARTML FILE LENGTH EXEMPTION';
const doNotEditMarker = '// DO NOT EDIT.';
const provenancePrefix = '// Generated from: ';

bool generatedExempt(Directory root, File file, List<String> lines) {
  final relative = relativePath(root, file);
  if (!splitPath(relative).contains('generated') || lines.length < 3) {
    return false;
  }
  if (lines[0] != generatedMarker || lines[1] != doNotEditMarker) {
    return false;
  }
  final provenance = _provenance(lines[2]);
  if (provenance == null || !_approvedGenerator(provenance)) {
    return false;
  }
  return _checkedInGenerator(root, file, provenance);
}

String? _provenance(String line) {
  if (!line.startsWith(provenancePrefix)) {
    return null;
  }
  final path = normalizePath(line.substring(provenancePrefix.length).trim());
  if (path.isEmpty || path.startsWith('/') || _windowsAbsolute(path)) {
    return null;
  }
  return splitPath(path).contains('..') ? null : path;
}

bool _approvedGenerator(String path) {
  final parts = splitPath(path);
  if (parts.length >= 3 && parts[0] == 'tool' && parts[1] == 'generators') {
    return true;
  }
  return parts.length >= 5 &&
      parts[0] == 'packages' &&
      parts[2] == 'tool' &&
      parts[3] == 'generators';
}

bool _checkedInGenerator(Directory root, File generated, String path) {
  final platformPath = splitPath(path).join(Platform.pathSeparator);
  final target = File('${root.path}${Platform.pathSeparator}$platformPath');
  if (!target.existsSync() ||
      target.statSync().type != FileSystemEntityType.file) {
    return false;
  }
  final rootPath = _realPath(Directory(root.path));
  final targetPath = _realPath(target);
  final generatedPath = _realPath(generated);
  return targetPath != generatedPath && targetPath.startsWith('$rootPath/');
}

bool _windowsAbsolute(String path) => RegExp(r'^[A-Za-z]:/').hasMatch(path);

String _realPath(FileSystemEntity entity) =>
    normalizePath(entity.resolveSymbolicLinksSync());
