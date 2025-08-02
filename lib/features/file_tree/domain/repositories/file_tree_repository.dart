import 'package:context_for_ai/core/typedefs/type.dart';
import '../entities/tree_entry.dart';
import '../entities/tree_filter.dart';

abstract class FileTreeRepository {
  /// Load folder contents from file system
  ResultFuture<List<TreeEntry>> loadFolderContents(String folderPath);

  /// Load folder contents with filter applied directly at data source level
  ResultFuture<List<TreeEntry>> loadFilteredFolderContents(
    String folderPath,
    TreeFilter filter,
  );

  /// Apply filter to list of entries
  ResultFuture<List<TreeEntry>> applyFilter(
    List<TreeEntry> entries,
    TreeFilter filter,
  );

  /// Calculate token count for a file
  ResultFuture<int> calculateTokenCount(String filePath);

  /// Check if file is readable
  ResultFuture<bool> checkFileReadability(String filePath);

  /// Get app settings for global filtering
  ResultFuture<TreeFilter> getGlobalFilter();

  /// Validate path exists and is accessible
  ResultFuture<bool> validatePath(String path);
}