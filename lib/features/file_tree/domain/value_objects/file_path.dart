import '../entities/tree_entry.dart';

/// Value object for file path operations
class FilePath {
  final String value;

  const FilePath._(this.value);

  factory FilePath.fromEntry(TreeEntry entry) {
    return FilePath._(entry.path);
  }

  factory FilePath.fromString(String path) {
    return FilePath._(path);
  }

  /// Check if file is hidden (starts with .)
  bool get isHidden {
    final fileName = value.split('/').last;
    return fileName.startsWith('.');
  }

  /// Get parent path
  String get parentPath {
    final parts = value.split('/');
    if (parts.length <= 1) return '';
    return parts.sublist(0, parts.length - 1).join('/');
  }

  /// Get file name
  String get fileName {
    return value.split('/').last;
  }

  /// Check if path is valid
  bool get isValid {
    return value.isNotEmpty && !value.contains('//');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FilePath && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}