import 'package:context_for_ai/core/error/failure.dart';
import 'package:context_for_ai/core/typedefs/type.dart';
import 'package:context_for_ai/core/usecase/usecase.dart';
import 'package:context_for_ai/features/file_tree/domain/entities/selection_state.dart';
import 'package:context_for_ai/features/file_tree/domain/entities/tree_entry.dart';
import 'package:context_for_ai/features/file_tree/domain/entities/tree_filter.dart';
import 'package:context_for_ai/features/file_tree/domain/repositories/file_tree_repository.dart';
import 'package:dartz/dartz.dart';

// ===========================
// Load Folder Contents
// ===========================

class LoadFolderContents
    extends FutureUseCaseWithParams<List<TreeEntry>, LoadFolderContentsParams> {
  LoadFolderContents({required this.repository});

  final FileTreeRepository repository;

  @override
  ResultFuture<List<TreeEntry>> call(LoadFolderContentsParams params) {
    return repository.loadFolderContents(params.folderPath);
  }
}

class LoadFolderContentsParams {
  LoadFolderContentsParams({required this.folderPath});
  final String folderPath;
}

// ===========================
// Load Filtered Folder Contents  
// ===========================

class LoadFilteredFolderContents
    extends FutureUseCaseWithParams<List<TreeEntry>, LoadFilteredFolderContentsParams> {
  LoadFilteredFolderContents({required this.repository});

  final FileTreeRepository repository;

  @override
  ResultFuture<List<TreeEntry>> call(LoadFilteredFolderContentsParams params) {
    return repository.loadFilteredFolderContents(params.folderPath, params.filter);
  }
}

class LoadFilteredFolderContentsParams {
  LoadFilteredFolderContentsParams({
    required this.folderPath,
    required this.filter,
  });
  final String folderPath;
  final TreeFilter filter;
}

// ===========================
// Apply Filter
// ===========================

class ApplyTreeFilter
    extends FutureUseCaseWithParams<List<TreeEntry>, ApplyTreeFilterParams> {
  ApplyTreeFilter({required this.repository});

  final FileTreeRepository repository;

  @override
  ResultFuture<List<TreeEntry>> call(ApplyTreeFilterParams params) {
    return repository.applyFilter(params.entries, params.filter);
  }
}

class ApplyTreeFilterParams {
  ApplyTreeFilterParams({
    required this.entries,
    required this.filter,
  });
  final List<TreeEntry> entries;
  final TreeFilter filter;
}

// ===========================
// Calculate Token Count
// ===========================

class CalculateTokenCount
    extends FutureUseCaseWithParams<int, CalculateTokenCountParams> {
  CalculateTokenCount({required this.repository});

  final FileTreeRepository repository;

  @override
  ResultFuture<int> call(CalculateTokenCountParams params) {
    return repository.calculateTokenCount(params.filePath);
  }
}

class CalculateTokenCountParams {
  CalculateTokenCountParams({required this.filePath});
  final String filePath;
}

// ===========================
// Validate Path
// ===========================

class ValidatePath extends FutureUseCaseWithParams<bool, ValidatePathParams> {
  ValidatePath({required this.repository});

  final FileTreeRepository repository;

  @override
  ResultFuture<bool> call(ValidatePathParams params) {
    return repository.validatePath(params.path);
  }
}

class ValidatePathParams {
  ValidatePathParams({required this.path});
  final String path;
}

// ===========================
// Get Global Filter
// ===========================

class GetGlobalFilter extends FutureUseCaseWithoutParams<TreeFilter> {
  GetGlobalFilter({required this.repository});

  final FileTreeRepository repository;

  @override
  ResultFuture<TreeFilter> call() {
    return repository.getGlobalFilter();
  }
}

// ===========================
// Check File Readability
// ===========================

class CheckFileReadability
    extends FutureUseCaseWithParams<bool, CheckFileReadabilityParams> {
  CheckFileReadability({required this.repository});

  final FileTreeRepository repository;

  @override
  ResultFuture<bool> call(CheckFileReadabilityParams params) {
    return repository.checkFileReadability(params.filePath);
  }
}

class CheckFileReadabilityParams {
  CheckFileReadabilityParams({required this.filePath});
  final String filePath;
}

// ===========================
// Calculate Selection State (Pure Business Logic)
// ===========================

class CalculateSelectionState
    extends
        FutureUseCaseWithParams<
          Map<String, SelectionState>,
          CalculateSelectionStateParams
        > {
  CalculateSelectionState();

  @override
  ResultFuture<Map<String, SelectionState>> call(
    CalculateSelectionStateParams params,
  ) async {
    try {
      final result = _calculateCascadingSelection(
        clickedPath: params.clickedPath,
        isDirectory: params.isDirectory,
        currentState: params.currentState,
        allEntries: params.allEntries,
        currentSelectionStates: params.currentSelectionStates,
      );

      return Right(result);
    } catch (e) {
      return Left(
        ValidationFailure(
          message: 'Failed to calculate selection state: $e',
          title: 'Validation Failure',
        ),
      );
    }
  }

  Map<String, SelectionState> _calculateCascadingSelection({
    required String clickedPath,
    required bool isDirectory,
    required SelectionState currentState,
    required Map<String, List<TreeEntry>> allEntries,
    required Map<String, SelectionState> currentSelectionStates,
  }) {
    final newSelectionStates = Map<String, SelectionState>.from(currentSelectionStates);
    final affectedPaths = <String>{};

    if (isDirectory) {
      _handleFolderSelection(
        folderPath: clickedPath,
        currentState: currentState,
        allEntries: allEntries,
        selectionStates: newSelectionStates,
        affectedPaths: affectedPaths,
      );
    } else {
      _handleFileSelection(
        filePath: clickedPath,
        currentState: currentState,
        selectionStates: newSelectionStates,
        affectedPaths: affectedPaths,
      );
    }

    // Update ancestors for all affected paths
    for (final path in affectedPaths) {
      _updateAncestors(
        childPath: path,
        allEntries: allEntries,
        selectionStates: newSelectionStates,
      );
    }

    return newSelectionStates;
  }

  void _handleFolderSelection({
    required String folderPath,
    required SelectionState currentState,
    required Map<String, List<TreeEntry>> allEntries,
    required Map<String, SelectionState> selectionStates,
    required Set<String> affectedPaths,
  }) {
    final newState = currentState.toggle();
    selectionStates[folderPath] = newState;
    affectedPaths.add(folderPath);

    // Apply to all descendants
    _selectDescendants(
      folderPath: folderPath,
      targetState: newState,
      allEntries: allEntries,
      selectionStates: selectionStates,
      affectedPaths: affectedPaths,
    );
  }

  void _handleFileSelection({
    required String filePath,
    required SelectionState currentState,
    required Map<String, SelectionState> selectionStates,
    required Set<String> affectedPaths,
  }) {
    final newState = currentState.toggle();
    selectionStates[filePath] = newState;
    affectedPaths.add(filePath);
  }

  void _selectDescendants({
    required String folderPath,
    required SelectionState targetState,
    required Map<String, List<TreeEntry>> allEntries,
    required Map<String, SelectionState> selectionStates,
    required Set<String> affectedPaths,
  }) {
    final entries = allEntries[folderPath];
    if (entries == null) return;

    for (final entry in entries) {
      if (!entry.isDirectory && !entry.isReadable) continue;

      selectionStates[entry.path] = targetState;
      affectedPaths.add(entry.path);

      if (entry.isDirectory && allEntries.containsKey(entry.path)) {
        _selectDescendants(
          folderPath: entry.path,
          targetState: targetState,
          allEntries: allEntries,
          selectionStates: selectionStates,
          affectedPaths: affectedPaths,
        );
      }
    }
  }

  void _updateAncestors({
    required String childPath,
    required Map<String, List<TreeEntry>> allEntries,
    required Map<String, SelectionState> selectionStates,
  }) {
    final parentPath = _getParentPath(childPath);
    if (parentPath.isEmpty) return;

    final parentState = _calculateParentSelectionState(
      parentPath: parentPath,
      allEntries: allEntries,
      selectionStates: selectionStates,
    );

    final currentParentState = selectionStates[parentPath] ?? SelectionState.unchecked;
    if (currentParentState != parentState) {
      selectionStates[parentPath] = parentState;
      _updateAncestors(
        childPath: parentPath,
        allEntries: allEntries,
        selectionStates: selectionStates,
      );
    }
  }

  SelectionState _calculateParentSelectionState({
    required String parentPath,
    required Map<String, List<TreeEntry>> allEntries,
    required Map<String, SelectionState> selectionStates,
  }) {
    final children = allEntries[parentPath];
    if (children == null || children.isEmpty) return SelectionState.unchecked;

    final relevantChildren = children.where((child) {
      return child.isDirectory || child.isReadable;
    }).toList();

    if (relevantChildren.isEmpty) return SelectionState.unchecked;

    var checkedCount = 0;
    var intermediateCount = 0;

    for (final child in relevantChildren) {
      final childState = selectionStates[child.path] ?? SelectionState.unchecked;
      switch (childState) {
        case SelectionState.checked:
          checkedCount++;
        case SelectionState.intermediate:
          intermediateCount++;
        case SelectionState.unchecked:
          break;
      }
    }

    if (checkedCount == relevantChildren.length) {
      return SelectionState.checked;
    } else if (checkedCount > 0 || intermediateCount > 0) {
      return SelectionState.intermediate;
    } else {
      return SelectionState.unchecked;
    }
  }

  String _getParentPath(String path) {
    final parts = path.split('/');
    if (parts.length <= 1) return '';
    return parts.sublist(0, parts.length - 1).join('/');
  }
}

class CalculateSelectionStateParams {
  CalculateSelectionStateParams({
    required this.clickedPath,
    required this.isDirectory,
    required this.currentState,
    required this.allEntries,
    required this.currentSelectionStates,
  });

  final String clickedPath;
  final bool isDirectory;
  final SelectionState currentState;
  final Map<String, List<TreeEntry>> allEntries;
  final Map<String, SelectionState> currentSelectionStates;
}
