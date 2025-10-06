import 'package:context_for_ai/features/code_combiner/data/enum/node_type.dart';
import 'package:context_for_ai/features/code_combiner/data/enum/selection_state.dart';
import 'package:context_for_ai/features/code_combiner/data/models/file_node.dart';
import 'package:context_for_ai/features/code_combiner/data/models/filter_settings.dart';
import 'package:context_for_ai/features/code_combiner/domain/usecases/code_combiner_usecase.dart';
import 'package:context_for_ai/features/code_combiner/presentation/cubits/states/file_explorer_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// FileExplorerCubit following Clean Architecture with proper sealed states
/// Manages file tree selection, filtering, and expansion with optimal memory usage
class FileExplorerCubit extends Cubit<FileExplorerState> {
  FileExplorerCubit({required this.useCase}) : super(const FileExplorerInitial());

  final CodeCombinerUseCase useCase;

  // ==================== LOCAL SESSION VARIABLES ====================
  // Memory efficient - only stored locally, not in state
  Map<String, FileNode> _allNodes = {}; // Fixed after scan
  final Set<String> _selectedFileIds = {}; // Selection tracking
  final Map<String, bool> _expansionStates = {}; // Folder expand/collapse
  FilterSettings _currentFilterSettings = FilterSettings.defaults();

  // ==================== INITIALIZATION ====================

  /// Initialize workspace - scan directory and load settings
  Future<void> initialize(String workspacePath) async {
    emit(const FileExplorerLoading());

    final result = await useCase.openDirectoryTree(workspacePath);
    result.fold(
      (failure) => emit(FileExplorerError(failure.message)),
      (workspaceData) {
        // Store complete tree locally (one-time scan per session)
        _allNodes = workspaceData.fileTree;
        _currentFilterSettings = workspaceData.filterSettings;

        // Compute initial filtered nodes and emit
        final filteredNodes = _computeFilteredNodes();
        emit(FileExplorerLoaded(filteredNodes));
      },
    );
  }

  // ==================== SELECTION MANAGEMENT ====================

  /// Toggle node selection with real-time ancestor updates
  void toggleNodeSelection(String nodeId) {
    final node = _allNodes[nodeId];
    if (node == null) return;

    // Create working copy for atomic updates
    final updatedNodes = Map<String, FileNode>.from(_allNodes);

    if (node.type == NodeType.file) {
      _toggleFileSelection(nodeId, node, updatedNodes);
    } else {
      _toggleFolderSelection(nodeId, node, updatedNodes);
    }

    // Real-time ancestor state updates
    _updateAncestorStates(nodeId, updatedNodes);

    // Store updated nodes locally
    _allNodes = updatedNodes;

    // Emit new filtered tree
    final filteredNodes = _computeFilteredNodes();
    emit(FileExplorerLoaded(filteredNodes));
  }

  void _toggleFileSelection(String fileId, FileNode file, Map<String, FileNode> nodes) {
    final newState = file.selectionState == SelectionState.checked
        ? SelectionState.unchecked
        : SelectionState.checked;

    nodes[fileId] = file.copyWith(selectionState: newState);

    // Update selection tracking
    if (newState == SelectionState.checked) {
      _selectedFileIds.add(fileId);
    } else {
      _selectedFileIds.remove(fileId);
    }
  }

  void _toggleFolderSelection(
    String folderId,
    FileNode folder,
    Map<String, FileNode> nodes,
  ) {
    final newState = folder.selectionState == SelectionState.checked
        ? SelectionState.unchecked
        : SelectionState.checked;

    _setFolderAndDescendants(folderId, newState, nodes);
  }

  void _setFolderAndDescendants(
    String folderId,
    SelectionState state,
    Map<String, FileNode> nodes,
  ) {
    final folder = nodes[folderId];
    if (folder == null) return;

    nodes[folderId] = folder.copyWith(selectionState: state);

    // Recursively update all descendants
    for (final childId in folder.childIds) {
      final child = nodes[childId];
      if (child == null) continue;

      nodes[childId] = child.copyWith(selectionState: state);

      // Update selection tracking for files
      if (child.type == NodeType.file) {
        if (state == SelectionState.checked) {
          _selectedFileIds.add(childId);
        } else {
          _selectedFileIds.remove(childId);
        }
      } else {
        // Recursively handle nested folders
        _setFolderAndDescendants(childId, state, nodes);
      }
    }
  }

  void _updateAncestorStates(String nodeId, Map<String, FileNode> nodes) {
    final node = nodes[nodeId];
    if (node?.parentId == null) return;

    final parentId = node!.parentId!;
    final parent = nodes[parentId];
    if (parent?.type != NodeType.folder) return;

    final newParentState = _calculateFolderState(parentId, nodes);
    if (parent!.selectionState != newParentState) {
      nodes[parentId] = parent.copyWith(selectionState: newParentState);
      _updateAncestorStates(parentId, nodes); // Recursive upward propagation
    }
  }

  SelectionState _calculateFolderState(String folderId, Map<String, FileNode> nodes) {
    final folder = nodes[folderId];
    if (folder == null || folder.childIds.isEmpty) return SelectionState.unchecked;

    var checkedCount = 0;
    var hasIntermediate = false;

    for (final childId in folder.childIds) {
      final child = nodes[childId];
      if (child == null) continue;

      if (child.selectionState == SelectionState.checked) {
        checkedCount++;
      } else if (child.selectionState == SelectionState.intermediate) {
        hasIntermediate = true;
      }
    }

    if (hasIntermediate || (checkedCount > 0 && checkedCount < folder.childIds.length)) {
      return SelectionState.intermediate;
    }

    return checkedCount == folder.childIds.length
        ? SelectionState.checked
        : SelectionState.unchecked;
  }

  /// Clear all selections
  void clearAllSelections() {
    _selectedFileIds.clear();

    // Update all nodes to unchecked
    final clearedNodes = _allNodes.map(
      (id, node) => MapEntry(
        id,
        node.copyWith(selectionState: SelectionState.unchecked),
      ),
    );

    _allNodes = clearedNodes;

    // Emit updated filtered tree
    final filteredNodes = _computeFilteredNodes();
    emit(FileExplorerLoaded(filteredNodes));
  }

  // ==================== EXPANSION MANAGEMENT ====================

  /// Toggle folder expansion state
  void toggleFolderExpansion(String folderId) {
    final folder = _allNodes[folderId];
    if (folder?.type != NodeType.folder) return;

    _expansionStates[folderId] = !(_expansionStates[folderId] ?? false);

    // Emit state to trigger UI rebuild (expansion affects rendering)
    final filteredNodes = _computeFilteredNodes();
    emit(FileExplorerLoaded(filteredNodes));
  }

  /// Get expansion state for UI
  bool isFolderExpanded(String folderId) {
    return _expansionStates[folderId] ?? false;
  }

  // ==================== FILTERING SYSTEM ====================

  /// Apply positive filters (session-only, UI display filtering)
  void applyPositiveFilters(Set<String> allowedExtensions) {
    _currentFilterSettings = _currentFilterSettings.copyWith(
      allowedExtensions: allowedExtensions,
    );

    // Recompute filtered tree and emit
    final filteredNodes = _computeFilteredNodes();
    emit(FileExplorerLoaded(filteredNodes));
  }

  /// Update negative filters (from datasource with selection cleanup)
  Future<void> updateNegativeFilters() async {
    // Keep current tree visible with loading indicator
    final currentFilteredNodes = _computeFilteredNodes();
    emit(FileExplorerFilterUpdating(currentFilteredNodes));

    try {
      final result = await useCase.getFilterSettings();

      result.fold(
        (failure) {
          emit(FileExplorerError(failure.message));
        },
        (newFilterSettings) {
          // Count selections before cleanup
          final beforeCount = _selectedFileIds.length;

          // Remove selected files that no longer pass negative filters
          _selectedFileIds.removeWhere((fileId) {
            final node = _allNodes[fileId];
            return node != null && !_passesNegativeFilter(node, newFilterSettings);
          });

          final removedCount = beforeCount - _selectedFileIds.length;

          // Update selection states in _allNodes for cleaned selections
          final updatedNodes = Map<String, FileNode>.from(_allNodes);
          for (final entry in updatedNodes.entries) {
            final fileId = entry.key;
            final node = entry.value;

            if (node.selectionState == SelectionState.checked &&
                !_selectedFileIds.contains(fileId)) {
              updatedNodes[fileId] = node.copyWith(
                selectionState: SelectionState.unchecked,
              );
            }
          }

          // Update ancestor states after selection cleanup
          for (final fileId in updatedNodes.keys) {
            if (!_selectedFileIds.contains(fileId)) {
              _updateAncestorStates(fileId, updatedNodes);
            }
          }

          // Store updated data
          _allNodes = updatedNodes;
          _currentFilterSettings = newFilterSettings.copyWith(
            allowedExtensions:
                _currentFilterSettings.allowedExtensions, // Keep positive filters
          );

          // Show success with feedback
          final newFilteredNodes = _computeFilteredNodes();
          emit(FileExplorerFilterUpdateSuccess(newFilteredNodes, removedCount));

          // Auto-transition to loaded state
          Future.delayed(const Duration(seconds: 2), () {
            if (state is FileExplorerFilterUpdateSuccess) {
              emit(FileExplorerLoaded(newFilteredNodes));
            }
          });
        },
      );
    } catch (e) {
      emit(FileExplorerError('Failed to update filters: $e'));
    }
  }

  /// Compute filtered nodes using simultaneous negative + positive filtering
  Map<String, FileNode> _computeFilteredNodes() {
    return Map.fromEntries(
      _allNodes.entries.where((entry) {
        final node = entry.value;
        return _passesNegativeFilter(node, _currentFilterSettings) &&
            _passesPositiveFilter(node, _currentFilterSettings);
      }),
    );
  }

  /// Check if node passes negative filters (blocked items)
  bool _passesNegativeFilter(FileNode node, FilterSettings settings) {
    // Check blocked extensions
    if (settings.blockedExtensions.any((ext) => node.path.endsWith(ext))) {
      return false;
    }

    // Check blocked paths
    if (settings.blockedFilePaths.any((path) => node.path.contains(path))) {
      return false;
    }

    // Check blocked file names
    if (settings.blockedFileNames.contains(node.name)) {
      return false;
    }

    // Check blocked folder names
    if (settings.blockedFolderNames.any((folder) => node.path.contains('/$folder/'))) {
      return false;
    }

    // Check hidden files
    if (!settings.includeHiddenFiles && node.name.startsWith('.')) {
      return false;
    }

    return true;
  }

  /// Check if node passes positive filters (allowed items)
  bool _passesPositiveFilter(FileNode node, FilterSettings settings) {
    // If no positive filters, show all
    if (settings.allowedExtensions.isEmpty) {
      return true;
    }

    // Always show folders (they contain files)
    if (node.type == NodeType.folder) {
      return true;
    }

    // Check if file extension is allowed
    return settings.allowedExtensions.any((ext) => node.path.endsWith(ext));
  }

  // ==================== EXPORT OPERATIONS ====================

  /// Export selected files (delegates to datasource)
  Future<void> exportSelectedFiles() async {
    if (_selectedFileIds.isEmpty) return;

    emit(const FileExplorerLoading());

    // Convert selected IDs to file paths
    final selectedPaths = _selectedFileIds
        .map((id) => _allNodes[id]?.path)
        .whereType<String>()
        .toList();

    final result = await useCase.exportFiles(selectedPaths);
    result.fold(
      (failure) => emit(FileExplorerError(failure.message)),
      (exportPreview) {
        // Export successful - return to loaded state
        final filteredNodes = _computeFilteredNodes();
        emit(FileExplorerLoaded(filteredNodes));
      },
    );
  }

  // ==================== PUBLIC GETTERS ====================

  /// Get current selection count for UI display
  int get selectedFilesCount => _selectedFileIds.length;

  /// Get current filtered nodes for external access
  Map<String, FileNode> get currentFilteredNodes {
    if (state is FileExplorerLoaded) {
      return (state as FileExplorerLoaded).filteredNodes;
    } else if (state is FileExplorerFilterUpdating) {
      return (state as FileExplorerFilterUpdating).filteredNodes;
    } else if (state is FileExplorerFilterUpdateSuccess) {
      return (state as FileExplorerFilterUpdateSuccess).filteredNodes;
    }
    return {};
  }
}
