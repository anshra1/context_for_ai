import 'package:context_for_ai/features/file_tree/domain/entities/tree_entry.dart';

/// Value object for file extension
class FileExtension {
  const FileExtension._(this.value);

  factory FileExtension.fromEntry(TreeEntry entry) {
    if (entry.isDirectory || !entry.name.contains('.')) {
      return const FileExtension._('');
    }
    return FileExtension._('.${entry.name.split('.').last.toLowerCase()}');
  }

  factory FileExtension.fromString(String extension) {
    if (extension.isEmpty) return const FileExtension._('');

    final normalized = extension.startsWith('.')
        ? extension.toLowerCase()
        : '.${extension.toLowerCase()}';

    return FileExtension._(normalized);
  }
  final String value;

  bool get isEmpty => value.isEmpty;
  bool get isNotEmpty => value.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FileExtension && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
