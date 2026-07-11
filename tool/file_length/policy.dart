import 'dart:io';

import 'path_utils.dart';

const int maxHandwrittenLines = 80;

const Set<String> metadataDirs = {'.git', '.dart_tool'};

const Set<String> topLevelExcludedDirs = {
  '.idea',
  '.vscode',
  'build',
  'cache',
  'coverage',
  'tmp',
  'temp',
};

const Set<String> applicableExtensions = {
  '.dart',
  '.yaml',
  '.yml',
  '.json',
  '.sh',
  '.bash',
  '.zsh',
  '.ps1',
  '.bat',
  '.c',
  '.cc',
  '.cpp',
  '.h',
  '.hpp',
  '.rs',
  '.cu',
  '.metal',
  '.glsl',
  '.wgsl',
};

bool skipDirectory(Directory root, Directory dir) {
  final relative = relativePath(root, dir);
  if (relative == '.') {
    return false;
  }
  final parts = splitPath(relative);
  if (parts.any(metadataDirs.contains)) {
    return true;
  }
  return parts.length == 1 && topLevelExcludedDirs.contains(parts.single);
}

bool appliesToFile(Directory root, File file) {
  final relative = relativePath(root, file);
  final name = splitPath(relative).last;
  if (name == 'pubspec.lock') {
    return false;
  }
  if (name == '.gitignore') {
    return true;
  }
  if (extensionOf(name) == '.md') {
    return false;
  }
  return applicableExtensions.contains(extensionOf(name));
}
