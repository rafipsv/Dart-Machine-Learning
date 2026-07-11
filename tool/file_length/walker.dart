import 'dart:io';

import 'path_utils.dart';
import 'policy.dart';

typedef DirectoryLister = List<FileSystemEntity> Function(Directory directory);

List<FileSystemEntity> defaultListDirectory(Directory directory) {
  return directory.listSync(followLinks: false);
}

List<File> collectFiles(
  Directory root,
  List<String> errors,
  DirectoryLister listDirectory,
) {
  final files = <File>[];
  _walk(root, root, files, errors, listDirectory);
  files.sort((a, b) => relativePath(root, a).compareTo(relativePath(root, b)));
  return files;
}

void _walk(
  Directory root,
  Directory dir,
  List<File> files,
  List<String> errors,
  DirectoryLister listDirectory,
) {
  if (skipDirectory(root, dir)) {
    return;
  }
  final children = _children(root, dir, errors, listDirectory);
  children.sort(
    (a, b) => relativePath(root, a).compareTo(relativePath(root, b)),
  );
  for (final child in children) {
    if (child is Directory) {
      _walk(root, child, files, errors, listDirectory);
    } else if (child is File && appliesToFile(root, child)) {
      files.add(child);
    }
  }
}

List<FileSystemEntity> _children(
  Directory root,
  Directory dir,
  List<String> errors,
  DirectoryLister listDirectory,
) {
  try {
    return listDirectory(dir);
  } on FileSystemException catch (error) {
    final relative = relativePath(root, dir);
    final message = error.osError?.message ?? error.message;
    errors.add('$relative: unreadable directory ($message)');
    return <FileSystemEntity>[];
  }
}
