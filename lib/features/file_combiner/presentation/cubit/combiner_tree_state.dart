import 'package:equatable/equatable.dart';
import '../../../../shared/widgets/file_tree/models/file_tree_models.dart';
import '../../../../shared/widgets/file_tree/cubit/simple_file_tree_state.dart';

class CombinerTreeState extends Equatable {
  /// Base tree state (inherited from simple tree)
  final SimpleFileTreeState baseState;
  
  /// Selection states - SEPARATE from tree data
  final Map<String, SelectionState> selectionStates;
  
  /// Selected file paths for easy access
  final Set<String> selectedFilePaths;
  
  /// Token counts per file
  final Map<String, int> tokenCounts;
  
  /// Total selected files count
  final int totalSelectedFiles;
  
  /// Total estimated tokens
  final int totalTokens;
  
  /// Whether selection is currently being updated (prevent UI flicker)
  final bool isUpdatingSelection;

  const CombinerTreeState({
    this.baseState = const SimpleFileTreeState(),
    this.selectionStates = const {},
    this.selectedFilePaths = const {},
    this.tokenCounts = const {},
    this.totalSelectedFiles = 0,
    this.totalTokens = 0,
    this.isUpdatingSelection = false,
  });

  /// Get selection state for a path
  SelectionState getSelectionState(String path) {
    return selectionStates[path] ?? SelectionState.unchecked;
  }

  /// Check if path is selected (checked or intermediate)
  bool isSelected(String path) {
    final state = getSelectionState(path);
    return state == SelectionState.checked || state == SelectionState.intermediate;
  }

  /// Check if path is fully selected
  bool isFullySelected(String path) {
    return getSelectionState(path) == SelectionState.checked;
  }

  /// Check if path is partially selected
  bool isPartiallySelected(String path) {
    return getSelectionState(path) == SelectionState.intermediate;
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
          for (final entries in baseState.cachedFolders.values) {
            final entry = entries.cast<FileTreeEntry?>().firstWhere(
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

  @override
  List<Object?> get props => [
        baseState,
        selectionStates,
        selectedFilePaths,
        tokenCounts,
        totalSelectedFiles,
        totalTokens,
        isUpdatingSelection,
      ];

  CombinerTreeState copyWith({
    SimpleFileTreeState? baseState,
    Map<String, SelectionState>? selectionStates,
    Set<String>? selectedFilePaths,
    Map<String, int>? tokenCounts,
    int? totalSelectedFiles,
    int? totalTokens,
    bool? isUpdatingSelection,
  }) {
    return CombinerTreeState(
      baseState: baseState ?? this.baseState,
      selectionStates: selectionStates ?? this.selectionStates,
      selectedFilePaths: selectedFilePaths ?? this.selectedFilePaths,
      tokenCounts: tokenCounts ?? this.tokenCounts,
      totalSelectedFiles: totalSelectedFiles ?? this.totalSelectedFiles,
      totalTokens: totalTokens ?? this.totalTokens,
      isUpdatingSelection: isUpdatingSelection ?? this.isUpdatingSelection,
    );
  }

  /// Create new state with updated base state
  CombinerTreeState withBaseState(SimpleFileTreeState newBaseState) {
    return copyWith(baseState: newBaseState);
  }
}