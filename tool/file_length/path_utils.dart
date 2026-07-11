import 'dart:io';

String relativePath(Directory root, FileSystemEntity entity) {
  final rootPath = _withSlash(normalizePath(root.absolute.path));
  final entityPath = normalizePath(entity.absolute.path);
  final rootSelf = rootPath.substring(0, rootPath.length - 1);
  if (entityPath == rootSelf) {
    return '.';
  }
  return entityPath.startsWith(rootPath)
      ? entityPath.substring(rootPath.length)
      : entityPath;
}

String normalizePath(String path) => path.replaceAll('\\', '/');

List<String> splitPath(String path) => normalizePath(path).split('/');

String extensionOf(String name) {
  final index = name.lastIndexOf('.');
  return index < 0 ? '' : name.substring(index).toLowerCase();
}

String _withSlash(String path) => path.endsWith('/') ? path : '$path/';
