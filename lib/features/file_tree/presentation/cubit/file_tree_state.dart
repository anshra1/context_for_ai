import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/tree_entry.dart';
import '../../domain/entities/tree_node.dart';
import '../../domain/entities/tree_filter.dart';
import '../../domain/entities/selection_state.dart';

part 'file_tree_state.freezed.dart';

@freezed
class FileTreeState with _$FileTreeState {
  const factory FileTreeState({
    // Tree Data
    @Default({}) Map<String, List<TreeEntry>> cachedFolders,
    @Default({}) Map<String, List<TreeEntry>> filteredFolders,
    @Default({}) Set<String> expandedFolders,
    @Default({}) Set<String> loadedFolders,
    
    // Selection State (separated from tree data)
    @Default({}) Map<String, SelectionState> selectionStates,
    @Default({}) Set<String> selectedFilePaths,
    @Default({}) Map<String, int> tokenCounts,
    
    // Filter & Search
    @Default(TreeFilter()) TreeFilter currentFilter,
    
    // UI State
    @Default(false) bool isLoading,
    @Default(false) bool isUpdatingSelection,
    @Default({}) Map<String, bool> folderLoadingStates,
    @Default({}) Map<String, String> folderErrors,
    
    // Current Context
    String? rootPath,
    
    // Statistics
    @Default(0) int totalSelectedFiles,
    @Default(0) int totalTokens,
  }) = _FileTreeState;

  const FileTreeState._();

  // Computed Properties
  
  /// Check if a folder is loading
  bool isFolderLoading(String folderPath) {
    return folderLoadingStates[folderPath] ?? false;
  }

  /// Check if a folder has been loaded
  bool isFolderLoaded(String folderPath) {
    return loadedFolders.contains(folderPath);
  }

  /// Check if a folder is expanded
  bool isFolderExpanded(String folderPath) {
    return expandedFolders.contains(folderPath);
  }

  /// Get error for a folder
  String? getFolderError(String folderPath) {
    return folderErrors[folderPath];
  }

  /// Get filtered entries for a folder
  List<TreeEntry> getFilteredEntries(String folderPath) {
    return filteredFolders[folderPath] ?? [];
  }

  /// Get raw entries for a folder
  List<TreeEntry> getRawEntries(String folderPath) {
    return cachedFolders[folderPath] ?? [];
  }

  /// Get selection state for a path
  SelectionState getSelectionState(String path) {
    return selectionStates[path] ?? SelectionState.unchecked;
  }

  /// Check if path is selected
  bool isSelected(String path) {
    final state = getSelectionState(path);
    return state == SelectionState.checked || state == SelectionState.intermediate;
  }

  /// Check if path is fully selected
  bool isFullySelected(String path) {
    return getSelectionState(path) == SelectionState.checked;
  }

  /// Get token count for a file
  int getTokenCount(String path) {
    return tokenCounts[path] ?? 0;
  }

  /// Get all selected readable files
  List<String> getSelectedReadableFiles() {
    return selectedFilePaths
        .where((path) {
          // Find the entry in loaded folders
          for (final entries in cachedFolders.values) {
            final entry = entries.cast<TreeEntry?>().firstWhere(
              (e) => e?.path == path,
              orElse: () => null,
            );
            if (entry != null) {
              return !entry.isDirectory && entry.isReadable;
            }
          }
          return false;
        })
        .toList();
  }

  /// Check if there are any active operations
  bool get hasActiveOperations {
    return isLoading || 
           isUpdatingSelection || 
           folderLoadingStates.values.any((loading) => loading);
  }

  /// Check if tree has content
  bool get hasContent {
    return cachedFolders.isNotEmpty;
  }

  /// Get total statistics
  String get selectionSummary {
    if (totalSelectedFiles == 0) return 'No files selected';
    if (totalSelectedFiles == 1) return '1 file selected';
    return '$totalSelectedFiles files selected';
  }

  String get tokenSummary {
    if (totalTokens == 0) return '0 tokens';
    if (totalTokens < 1000) return '$totalTokens tokens';
    if (totalTokens < 1000000) {
      return '${(totalTokens / 1000).toStringAsFixed(1)}K tokens';
    }
    return '${(totalTokens / 1000000).toStringAsFixed(1)}M tokens';
  }
}