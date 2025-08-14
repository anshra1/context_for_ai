import 'dart:io';

void main() async {
  final dir = Directory('/home/ansh/Studio Projects/Clone/context_for_ai/test_folder');

  if (dir.existsSync()) {
    await for (final entity in dir.list(recursive: true, followLinks: true)) {
      print(entity.path);
    }
  } else {
    print('Directory does not exist');
  }
}
