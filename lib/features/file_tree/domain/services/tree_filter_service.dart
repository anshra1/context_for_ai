import '../entities/tree_entry.dart';
import '../entities/tree_filter.dart';
import '../value_objects/file_extension.dart';
import '../value_objects/file_path.dart';

/// Domain service for filtering tree entries
class TreeFilterService {
  const TreeFilterService();

  /// Create filter from app settings
  TreeFilter createFromAppSettings({
    required List<String> excludedFileExtensions,
    required List<String> excludedNames,
    required bool showHiddenFiles,
    List<String> allowedExtensions = const [],
    String searchQuery = '',
  }) {
    return TreeFilter(
      allowedExtensions: allowedExtensions,
      excludedFolders: excludedNames,
      excludedExtensions: excludedFileExtensions,
      showHiddenFiles: showHiddenFiles,
      searchQuery: searchQuery,
    );
  }

  /// Check if entry should be included based on filter criteria
  bool shouldInclude(TreeEntry entry, TreeFilter filter) {
    final fileExtension = FileExtension.fromEntry(entry);
    final filePath = FilePath.fromEntry(entry);

    // Hidden files
    if (!filter.showHiddenFiles && filePath.isHidden) return false;

    // Excluded folders
    if (entry.isDirectory && filter.excludedFolders.contains(entry.name)) {
      return false;
    }

    // Excluded extensions (only for files)
    if (!entry.isDirectory && 
        filter.excludedExtensions.contains(fileExtension.value)) {
      return false;
    }

    // Allowed extensions (only for files, and only if specified)
    if (!entry.isDirectory && filter.allowedExtensions.isNotEmpty) {
      if (!filter.allowedExtensions.contains(fileExtension.value)) return false;
    }

    // Search query
    if (filter.searchQuery.isNotEmpty) {
      if (!entry.name.toLowerCase().contains(filter.searchQuery.toLowerCase())) {
        return false;
      }
    }

    return true;
  }

  /// Check if filter has any active criteria
  bool hasActiveFilters(TreeFilter filter) {
    return filter.allowedExtensions.isNotEmpty ||
           filter.excludedExtensions.isNotEmpty ||
           !filter.showHiddenFiles ||
           filter.searchQuery.isNotEmpty;
  }

  /// Apply filter to list of entries
  List<TreeEntry> applyFilter(List<TreeEntry> entries, TreeFilter filter) {
    return entries.where((entry) => shouldInclude(entry, filter)).toList();
  }
}