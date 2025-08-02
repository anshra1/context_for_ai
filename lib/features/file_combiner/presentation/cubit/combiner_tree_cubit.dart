import 'dart:async';
import 'dart:io' as io;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/widgets/file_tree/cubit/simple_file_tree_cubit.dart';
import '../../../../shared/widgets/file_tree/cubit/simple_file_tree_state.dart';
import '../../../../shared/widgets/file_tree/models/file_tree_models.dart';
import '../../../../shared/widgets/file_tree/services/file_tree_service.dart';
import '../utils/selection_algorithms.dart';
import 'combiner_tree_state.dart';

class CombinerTreeCubit extends Cubit<CombinerTreeState> {
  final SimpleFileTreeCubit _baseTreeCubit;
  StreamSubscription<SimpleFileTreeState>? _baseTreeSubscription;
  Timer? _tokenCountDebouncer;

  CombinerTreeCubit({String? rootPath}) 
      : _baseTreeCubit = SimpleFileTreeCubit(const FileTreeServiceImpl()),
        super(const CombinerTreeState()) {
    
    // Listen to base tree changes
    _baseTreeSubscription = _baseTreeCubit.stream.listen(_onBaseTreeChanged);
    
    // Initialize if root path provided
    if (rootPath != null) {
      loadRoot(rootPath);
    }
  }

  /// Initialize tree with root path
  Future<void> loadRoot(String rootPath) async {
    await _baseTreeCubit.loadRoot(rootPath);
  }

  /// Expand folder (delegates to base tree)
  Future<void> expandFolder(String folderPath) async {
    await _baseTreeCubit.expandFolder(folderPath);
  }

  /// Collapse folder (delegates to base tree)
  void collapseFolder(String folderPath) {
    _baseTreeCubit.collapseFolder(folderPath);
  }

  /// Update filter (delegates to base tree)
  void updateFilter(FileTreeFilter newFilter) {
    _baseTreeCubit.updateFilter(newFilter);
  }

  /// Handle node selection - implements your flowchart logic
  Future<void> toggleNodeSelection(String path) async {
    if (state.isUpdatingSelection) return; // Prevent concurrent updates

    emit(state.copyWith(isUpdatingSelection: true));

    try {
      // Find the entry in cached data
      FileTreeEntry? entry;
      for (final entries in state.baseState.cachedFolders.values) {
        entry = entries.cast<FileTreeEntry?>().firstWhere(
          (e) => e?.path == path,
          orElse: () => null,
        );
        if (entry != null) break;
      }

      if (entry == null) {
        emit(state.copyWith(isUpdatingSelection: false));
        return;
      }

      // Check if file is readable (skip unreadable files with toast)
      if (!entry.isDirectory && !entry.isReadable) {
        // TODO: Show toast: "File is not readable"
        emit(state.copyWith(isUpdatingSelection: false));
        return;
      }

      final currentState = state.getSelectionState(path);

      // Calculate cascading selection changes
      final selectionResult = SelectionAlgorithms.calculateCascadingSelection(
        clickedPath: path,
        isDirectory: entry.isDirectory,
        currentState: currentState,
        cachedFolders: state.baseState.cachedFolders,
        currentSelectionStates: state.selectionStates,
        expandedFolders: state.baseState.expandedFolders,
      );

      // Update selection states
      final newSelectionStates = selectionResult.newSelectionStates;
      
      // Calculate new selected files
      final newSelectedFilePaths = <String>{};
      for (final entry in newSelectionStates.entries) {
        if (entry.value == SelectionState.checked) {
          // Only add readable files to selected paths
          final fileEntry = _findEntryByPath(entry.key);
          if (fileEntry != null && !fileEntry.isDirectory && fileEntry.isReadable) {
            newSelectedFilePaths.add(entry.key);
          }
        }
      }

      // Update token counts for affected files
      await _updateTokenCounts(selectionResult.affectedPaths);

      // Calculate totals
      final totalTokens = state.tokenCounts.values.fold(0, (sum, count) => sum + count);

      emit(state.copyWith(
        selectionStates: newSelectionStates,
        selectedFilePaths: newSelectedFilePaths,
        totalSelectedFiles: newSelectedFilePaths.length,
        totalTokens: totalTokens,
        isUpdatingSelection: false,
      ));
    } catch (e) {
      emit(state.copyWith(isUpdatingSelection: false));
      // TODO: Handle error (show toast/snackbar)
    }
  }

  /// Clear all selections
  void clearAllSelections() {
    emit(state.copyWith(
      selectionStates: {},
      selectedFilePaths: {},
      tokenCounts: {},
      totalSelectedFiles: 0,
      totalTokens: 0,
    ));
  }

  /// Get all selected readable file paths
  List<String> getSelectedReadableFiles() {
    return state.getSelectedReadableFiles();
  }

  /// Build tree with selection states
  List<FileTreeNodeWithSelection> buildTreeWithSelection() {
    final baseNodes = _baseTreeCubit.buildTree();
    return baseNodes.map((node) => _convertToSelectionNode(node)).toList();
  }

  /// Private: Handle base tree state changes
  void _onBaseTreeChanged(SimpleFileTreeState newBaseState) {
    emit(state.withBaseState(newBaseState));
  }

  /// Private: Update token counts for affected paths
  Future<void> _updateTokenCounts(Set<String> affectedPaths) async {
    final newTokenCounts = Map<String, int>.from(state.tokenCounts);

    for (final path in affectedPaths) {
      final entry = _findEntryByPath(path);
      if (entry == null || entry.isDirectory || !entry.isReadable) {
        newTokenCounts.remove(path);
        continue;
      }

      final selectionState = state.selectionStates[path] ?? SelectionState.unchecked;
      if (selectionState == SelectionState.checked) {
        // Calculate token count for this file
        _tokenCountDebouncer?.cancel();
        _tokenCountDebouncer = Timer(const Duration(milliseconds: 100), () async {
          final tokenCount = await _calculateFileTokenCount(path);
          newTokenCounts[path] = tokenCount;
          
          // Update state with new token counts
          final totalTokens = newTokenCounts.values.fold(0, (sum, count) => sum + count);
          emit(state.copyWith(
            tokenCounts: newTokenCounts,
            totalTokens: totalTokens,
          ));
        });
      } else {
        newTokenCounts.remove(path);
      }
    }

    // Immediate update for removed tokens
    final totalTokens = newTokenCounts.values.fold(0, (sum, count) => sum + count);
    emit(state.copyWith(
      tokenCounts: newTokenCounts,
      totalTokens: totalTokens,
    ));
  }

  /// Private: Calculate token count for a file
  Future<int> _calculateFileTokenCount(String filePath) async {
    try {
      final file = io.File(filePath);
      final content = await file.readAsString();
      return SelectionAlgorithms.calculateTokenCount(content);
    } catch (e) {
      return 0;
    }
  }

  /// Private: Find entry by path in cached data
  FileTreeEntry? _findEntryByPath(String path) {
    for (final entries in state.baseState.cachedFolders.values) {
      final entry = entries.cast<FileTreeEntry?>().firstWhere(
        (e) => e?.path == path,
        orElse: () => null,
      );
      if (entry != null) return entry;
    }
    return null;
  }

  /// Private: Convert base tree node to selection node
  FileTreeNodeWithSelection _convertToSelectionNode(FileTreeNode baseNode) {
    final selectionState = state.getSelectionState(baseNode.entry.path);
    final tokenCount = state.getTokenCount(baseNode.entry.path);

    return FileTreeNodeWithSelection(
      baseNode: baseNode,
      selectionState: selectionState,
      tokenCount: tokenCount,
      children: baseNode.children.map(_convertToSelectionNode).toList(),
    );
  }

  @override
  Future<void> close() {
    _baseTreeSubscription?.cancel();
    _tokenCountDebouncer?.cancel();
    _baseTreeCubit.close();
    return super.close();
  }
}

/// Extended tree node with selection information
class FileTreeNodeWithSelection {
  final FileTreeNode baseNode;
  final SelectionState selectionState;
  final int tokenCount;
  final List<FileTreeNodeWithSelection> children;

  const FileTreeNodeWithSelection({
    required this.baseNode,
    required this.selectionState,
    required this.tokenCount,
    this.children = const [],
  });

  // Delegate properties to base node
  FileTreeEntry get entry => baseNode.entry;
  int get depth => baseNode.depth;
  bool get isExpanded => baseNode.isExpanded;
  String get parentPath => baseNode.parentPath;
}