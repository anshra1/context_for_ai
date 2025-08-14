import 'dart:io';

void main() async {
  final dir = Directory('test_folder');

  // list() returns a Stream<FileSystemEntity>
  await for (final entity in dir.list()) {
    if (entity is File) {
      print('File: ${entity.path}');
    } else if (entity is Directory) {
      print('Folder: ${entity.path}');
    }
  }
}
