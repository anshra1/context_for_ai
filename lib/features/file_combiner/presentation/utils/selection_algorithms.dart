import '../../../../shared/widgets/file_tree/models/file_tree_models.dart';

class SelectionAlgorithms {
  /// Calculate cascading selection state when a node is clicked
  static SelectionResult calculateCascadingSelection({
    required String clickedPath,
    required bool isDirectory,
    required SelectionState currentState,
    required Map<String, List<FileTreeEntry>> cachedFolders,
    required Map<String, SelectionState> currentSelectionStates,
    required Set<String> expandedFolders,
  }) {
    final newSelectionStates = Map<String, SelectionState>.from(currentSelectionStates);
    final affectedPaths = <String>{};

    if (isDirectory) {
      _handleFolderSelection(
        folderPath: clickedPath,
        currentState: currentState,
        cachedFolders: cachedFolders,
        selectionStates: newSelectionStates,
        affectedPaths: affectedPaths,
        expandedFolders: expandedFolders,
      );
    } else {
      _handleFileSelection(
        filePath: clickedPath,
        currentState: currentState,
        cachedFolders: cachedFolders,
        selectionStates: newSelectionStates,
        affectedPaths: affectedPaths,
      );
    }

    // Update ancestors for all affected paths
    final allAffectedPaths = <String>{...affectedPaths};
    for (final path in affectedPaths) {
      _updateAncestors(
        childPath: path,
        cachedFolders: cachedFolders,
        selectionStates: newSelectionStates,
        allAffectedPaths: allAffectedPaths,
      );
    }

    return SelectionResult(
      newSelectionStates: newSelectionStates,
      affectedPaths: allAffectedPaths,
    );
  }

  /// Handle folder selection (affects all descendants)
  static void _handleFolderSelection({
    required String folderPath,
    required SelectionState currentState,
    required Map<String, List<FileTreeEntry>> cachedFolders,
    required Map<String, SelectionState> selectionStates,
    required Set<String> affectedPaths,
    required Set<String> expandedFolders,
  }) {
    SelectionState newState;

    // Determine new state based on current state
    switch (currentState) {
      case SelectionState.unchecked:
      case SelectionState.intermediate:
        newState = SelectionState.checked;
        break;
      case SelectionState.checked:
        newState = SelectionState.unchecked;
        break;
    }

    // Apply to folder
    selectionStates[folderPath] = newState;
    affectedPaths.add(folderPath);

    // Apply to all descendants (recursively)
    _selectDescendants(
      folderPath: folderPath,
      targetState: newState,
      cachedFolders: cachedFolders,
      selectionStates: selectionStates,
      affectedPaths: affectedPaths,
      expandedFolders: expandedFolders,
    );
  }

  /// Handle file selection (affects ancestors)
  static void _handleFileSelection({
    required String filePath,
    required SelectionState currentState,
    required Map<String, List<FileTreeEntry>> cachedFolders,
    required Map<String, SelectionState> selectionStates,
    required Set<String> affectedPaths,
  }) {
    // Toggle file selection
    final newState = currentState == SelectionState.checked 
        ? SelectionState.unchecked 
        : SelectionState.checked;
    
    selectionStates[filePath] = newState;
    affectedPaths.add(filePath);
  }

  /// Recursively select/deselect all descendants of a folder
  static void _selectDescendants({
    required String folderPath,
    required SelectionState targetState,
    required Map<String, List<FileTreeEntry>> cachedFolders,
    required Map<String, SelectionState> selectionStates,
    required Set<String> affectedPaths,
    required Set<String> expandedFolders,
  }) {
    final entries = cachedFolders[folderPath];
    if (entries == null) return;

    for (final entry in entries) {
      // Skip unreadable files
      if (!entry.isDirectory && !entry.isReadable) continue;

      selectionStates[entry.path] = targetState;
      affectedPaths.add(entry.path);

      // Recursively handle subdirectories (only if loaded)
      if (entry.isDirectory && cachedFolders.containsKey(entry.path)) {
        _selectDescendants(
          folderPath: entry.path,
          targetState: targetState,
          cachedFolders: cachedFolders,
          selectionStates: selectionStates,
          affectedPaths: affectedPaths,
          expandedFolders: expandedFolders,
        );
      }
    }
  }

  /// Update ancestor states based on children selection
  static void _updateAncestors({
    required String childPath,
    required Map<String, List<FileTreeEntry>> cachedFolders,
    required Map<String, SelectionState> selectionStates,
    required Set<String> allAffectedPaths,
  }) {
    final parentPath = _getParentPath(childPath);
    if (parentPath.isEmpty) return;

    // Calculate parent's selection state based on children
    final parentState = _calculateParentSelectionState(
      parentPath: parentPath,
      cachedFolders: cachedFolders,
      selectionStates: selectionStates,
    );

    // Update parent if state changed
    final currentParentState = selectionStates[parentPath] ?? SelectionState.unchecked;
    if (currentParentState != parentState) {
      selectionStates[parentPath] = parentState;
      allAffectedPaths.add(parentPath);

      // Recursively update grandparents
      _updateAncestors(
        childPath: parentPath,
        cachedFolders: cachedFolders,
        selectionStates: selectionStates,
        allAffectedPaths: allAffectedPaths,
      );
    }
  }

  /// Calculate what a parent's selection state should be based on children
  static SelectionState _calculateParentSelectionState({
    required String parentPath,
    required Map<String, List<FileTreeEntry>> cachedFolders,
    required Map<String, SelectionState> selectionStates,
  }) {
    final children = cachedFolders[parentPath];
    if (children == null || children.isEmpty) {
      return SelectionState.unchecked;
    }

    // Only consider readable files and directories
    final relevantChildren = children.where((child) {
      return child.isDirectory || child.isReadable;
    }).toList();

    if (relevantChildren.isEmpty) {
      return SelectionState.unchecked;
    }

    int checkedCount = 0;
    int intermediateCount = 0;
    int totalCount = relevantChildren.length;

    for (final child in relevantChildren) {
      final childState = selectionStates[child.path] ?? SelectionState.unchecked;
      switch (childState) {
        case SelectionState.checked:
          checkedCount++;
          break;
        case SelectionState.intermediate:
          intermediateCount++;
          break;
        case SelectionState.unchecked:
          // Do nothing
          break;
      }
    }

    // Determine parent state
    if (checkedCount == totalCount) {
      return SelectionState.checked;
    } else if (checkedCount > 0 || intermediateCount > 0) {
      return SelectionState.intermediate;
    } else {
      return SelectionState.unchecked;
    }
  }

  /// Get parent path from a file/folder path
  static String _getParentPath(String path) {
    final parts = path.split('/');
    if (parts.length <= 1) return '';
    return parts.sublist(0, parts.length - 1).join('/');
  }

  /// Calculate token count for selected files
  static int calculateTokenCount(String content) {
    if (content.trim().isEmpty) return 0;
    // Simple approximation: 1 token ≈ 4 characters or 1 word
    final wordCount = content.split(RegExp(r'\s+')).length;
    final charCount = content.length;
    return (wordCount + (charCount / 4)).round();
  }
}

class SelectionResult {
  final Map<String, SelectionState> newSelectionStates;
  final Set<String> affectedPaths;

  const SelectionResult({
    required this.newSelectionStates,
    required this.affectedPaths,
  });
}