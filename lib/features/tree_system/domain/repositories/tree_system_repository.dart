import 'package:dartz/dartz.dart';
import '../../../core/error/failure.dart';
import '../../../core/typedefs/type.dart';
import '../entities/tree_entry.dart';

abstract class TreeSystemRepository {
  TreeSystemRepository();

  /// 🧭 Loads all files and folders from the specified directory path
  /// Input: String folderPath - directory path to read
  /// Output: ResultFuture<List<TreeEntry>> - Either failure or list of files/folders
  ResultFuture<List<TreeEntry>> loadFolderContents(String folderPath);

  /// 🧭 Applies global and local filters to entries and prepares for UI
  /// Input: List<TreeEntry> entries, List<String> allowedExtensions
  /// Output: ResultFuture<List<TreeEntry>> - Either failure or filtered entries
  ResultFuture<List<TreeEntry>> applyFiltersAndPrepareForUI(
    List<TreeEntry> entries,
    List<String> allowedExtensions,
  );

  /// 🧭 Calculates AI token count for a specific file
  /// Input: String filePath - path to file for token calculation
  /// Output: ResultFuture<int> - Either failure or number of AI tokens
  ResultFuture<int> calculateTokenCount(String filePath);
}