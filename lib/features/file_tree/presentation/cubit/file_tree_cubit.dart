import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:context_for_ai/core/error/failure.dart';
import '../../domain/entities/tree_entry.dart';
import '../../domain/entities/tree_filter.dart';
import '../../domain/entities/tree_node.dart';
import '../../domain/entities/selection_state.dart';
import '../../domain/usecases/file_tree_usecases.dart';
import 'file_tree_state.dart';

class FileTreeCubit extends Cubit<FileTreeState> {
  final LoadFolderContents _loadFolderContents;
  final ApplyTreeFilter _applyTreeFilter;
  final CalculateTokenCount _calculateTokenCount;
  final ValidatePath _validatePath;
  final GetGlobalFilter _getGlobalFilter;
  final CheckFileReadability _checkFileReadability;
  final CalculateSelectionState _calculateSelectionState;

  Timer? _filterDebouncer;
  Timer? _tokenCountDebouncer;

  FileTreeCubit({
    required LoadFolderContents loadFolderContents,
    required ApplyTreeFilter applyTreeFilter,
    required CalculateTokenCount calculateTokenCount,
    required ValidatePath validatePath,
    required GetGlobalFilter getGlobalFilter,
    required CheckFileReadability checkFileReadability,
    required CalculateSelectionState calculateSelectionState,
  })  : _loadFolderContents = loadFolderContents,
        _applyTreeFilter = applyTreeFilter,
        _calculateTokenCount = calculateTokenCount,
        _validatePath = validatePath,
        _getGlobalFilter = getGlobalFilter,
        _checkFileReadability = checkFileReadability,
        _calculateSelectionState = calculateSelectionState,
        super(const FileTreeState());

  /// Initialize tree with root path
  Future<void> loadRoot(String rootPath) async {
    emit(state.copyWith(isLoading: true, rootPath: rootPath));

    try {
      // Load global filter first
      final globalFilterResult = await _getGlobalFilter(NoParams());
      final globalFilter = globalFilterResult.fold(
        (failure) => const TreeFilter(), // Default filter on failure
        (filter) => filter,
      );

      emit(state.copyWith(currentFilter: globalFilter));

      // Load root folder
      await _loadFolder(rootPath);

      // Auto-expand root
      await expandFolder(rootPath);

      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        folderErrors: {...state.folderErrors, rootPath: e.toString()},
      ));
    }
  }

  /// Change to a different root path
  Future<void> changeRootPath(String newRootPath) async {
    // Clear previous state
    emit(state.copyWith(
      cachedFolders: {},
      filteredFolders: {},
      expandedFolders: {},
      loadedFolders: {},
      selectionStates: {},
      selectedFilePaths: {},
      tokenCounts: {},
      folderLoadingStates: {},
      folderErrors: {},
      totalSelectedFiles: 0,
      totalTokens: 0,
    ));

    await loadRoot(newRootPath);
  }

  /// Smart loading - only load folder when needed
  Future<void> expandFolder(String folderPath) async {
    // Add to expanded set first (for immediate UI feedback)
    final newExpandedFolders = {...state.expandedFolders, folderPath};
    emit(state.copyWith(expandedFolders: newExpandedFolders));

    // Load folder data if not already loaded
    if (!state.isFolderLoaded(folderPath)) {
      await _loadFolder(folderPath);
    }
  }

  /// Collapse folder
  void collapseFolder(String folderPath) {
    final newExpandedFolders = state.expandedFolders.toSet()..remove(folderPath);
    emit(state.copyWith(expandedFolders: newExpandedFolders));
  }

  /// Update filter with debouncing
  void updateFilter(TreeFilter newFilter) {
    _filterDebouncer?.cancel();
    _filterDebouncer = Timer(const Duration(milliseconds: 300), () {
      emit(state.copyWith(currentFilter: newFilter));
      _applyFiltersToAllLoadedFolders();
    });
  }

  /// Toggle node selection - implements hierarchical selection logic
  Future<void> toggleNodeSelection(String path) async {
    if (state.isUpdatingSelection) return;

    emit(state.copyWith(isUpdatingSelection: true));

    try {
      // Find the entry
      TreeEntry? entry;
      for (final entries in state.cachedFolders.values) {
        entry = entries.cast<TreeEntry?>().firstWhere(
          (e) => e?.path == path,
          orElse: () => null,
        );
        if (entry != null) break;
      }

      if (entry == null) {
        emit(state.copyWith(isUpdatingSelection: false));
        return;
      }

      // Check if file is readable
      if (!entry.isDirectory && !entry.isReadable) {
        // Skip unreadable files
        emit(state.copyWith(isUpdatingSelection: false));
        return;
      }

      final currentState = state.getSelectionState(path);

      // Calculate cascading selection changes using use case
      final selectionResult = await _calculateSelectionState(
        CalculateSelectionStateParams(
          clickedPath: path,
          isDirectory: entry.isDirectory,
          currentState: currentState,
          allEntries: state.cachedFolders,
          currentSelectionStates: state.selectionStates,
        ),
      );

      final newSelectionStates = selectionResult.fold(
        (failure) => state.selectionStates, // Keep current on failure
        (states) => states,
      );

      // Calculate new selected files
      final newSelectedFilePaths = <String>{};
      for (final entry in newSelectionStates.entries) {
        if (entry.value == SelectionState.checked) {
          final fileEntry = _findEntryByPath(entry.key);
          if (fileEntry != null && !fileEntry.isDirectory && fileEntry.isReadable) {
            newSelectedFilePaths.add(entry.key);
          }
        }
      }

      // Update token counts for selected files
      await _updateTokenCounts(newSelectedFilePaths);

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

  /// Build tree structure with selection states
  List<TreeNode> buildTree() {
    if (state.rootPath == null) return [];

    final rootEntries = state.getFilteredEntries(state.rootPath!);
    return rootEntries.map((entry) => _buildNode(entry, 0)).toList();
  }

  /// Get all selected readable file paths
  List<String> getSelectedReadableFiles() {
    return state.getSelectedReadableFiles();
  }

  /// Private: Load folder from repository
  Future<void> _loadFolder(String folderPath) async {
    // Set loading state
    final newLoadingStates = {...state.folderLoadingStates, folderPath: true};
    emit(state.copyWith(folderLoadingStates: newLoadingStates));

    try {
      // Load from repository
      final result = await _loadFolderContents(
        LoadFolderContentsParams(folderPath: folderPath),
      );

      final entries = result.fold(
        (failure) => throw failure,
        (entries) => entries,
      );

      // Update cached data
      final newCachedFolders = {...state.cachedFolders, folderPath: entries};
      final newLoadedFolders = {...state.loadedFolders, folderPath};

      // Apply current filter
      final filterResult = await _applyTreeFilter(
        ApplyTreeFilterParams(entries: entries, filter: state.currentFilter),
      );

      final filteredEntries = filterResult.fold(
        (failure) => entries, // Use unfiltered on filter failure
        (filtered) => filtered,
      );

      final newFilteredFolders = {...state.filteredFolders, folderPath: filteredEntries};

      // Remove loading state and errors
      final newLoadingStatesEnd = {...state.folderLoadingStates}..remove(folderPath);
      final newErrors = {...state.folderErrors}..remove(folderPath);

      emit(state.copyWith(
        cachedFolders: newCachedFolders,
        filteredFolders: newFilteredFolders,
        loadedFolders: newLoadedFolders,
        folderLoadingStates: newLoadingStatesEnd,
        folderErrors: newErrors,
      ));
    } on Failure catch (failure) {
      _handleLoadingError(folderPath, failure.message);
    } catch (e) {
      _handleLoadingError(folderPath, e.toString());
    }
  }

  /// Private: Handle loading errors
  void _handleLoadingError(String folderPath, String error) {
    final newLoadingStatesError = {...state.folderLoadingStates}..remove(folderPath);
    final newErrors = {...state.folderErrors, folderPath: error};

    emit(state.copyWith(
      folderLoadingStates: newLoadingStatesError,
      folderErrors: newErrors,
    ));
  }

  /// Private: Apply filters to all loaded folders
  void _applyFiltersToAllLoadedFolders() {
    final newFilteredFolders = <String, List<TreeEntry>>{};

    for (final folderPath in state.loadedFolders) {
      final rawEntries = state.getRawEntries(folderPath);
      final filteredEntries = rawEntries.where(state.currentFilter.shouldInclude).toList();
      newFilteredFolders[folderPath] = filteredEntries;
    }

    emit(state.copyWith(filteredFolders: newFilteredFolders));
  }

  /// Private: Update token counts for selected files
  Future<void> _updateTokenCounts(Set<String> selectedFilePaths) async {
    final newTokenCounts = <String, int>{};

    _tokenCountDebouncer?.cancel();
    _tokenCountDebouncer = Timer(const Duration(milliseconds: 100), () async {
      for (final path in selectedFilePaths) {
        final tokenResult = await _calculateTokenCount(
          CalculateTokenCountParams(filePath: path),
        );
        
        final tokenCount = tokenResult.fold(
          (failure) => 0,
          (count) => count,
        );
        
        newTokenCounts[path] = tokenCount;
      }

      // Update state with new token counts
      final totalTokens = newTokenCounts.values.fold(0, (sum, count) => sum + count);
      emit(state.copyWith(
        tokenCounts: newTokenCounts,
        totalTokens: totalTokens,
      ));
    });
  }

  /// Private: Find entry by path in cached data
  TreeEntry? _findEntryByPath(String path) {
    for (final entries in state.cachedFolders.values) {
      final entry = entries.cast<TreeEntry?>().firstWhere(
        (e) => e?.path == path,
        orElse: () => null,
      );
      if (entry != null) return entry;
    }
    return null;
  }

  /// Private: Build tree node recursively
  TreeNode _buildNode(TreeEntry entry, int depth) {
    final isExpanded = state.isFolderExpanded(entry.path);
    final selectionState = state.getSelectionState(entry.path);
    final tokenCount = state.getTokenCount(entry.path);
    final children = <TreeNode>[];

    // Build children only if expanded and loaded
    if (entry.isDirectory && isExpanded && state.isFolderLoaded(entry.path)) {
      final childEntries = state.getFilteredEntries(entry.path);

      // Folders first, then files
      final folders = childEntries.where((e) => e.isDirectory).toList();
      final files = childEntries.where((e) => !e.isDirectory).toList();

      children.addAll(folders.map((child) => _buildNode(child, depth + 1)));
      children.addAll(files.map((child) => _buildNode(child, depth + 1)));
    }

    return TreeNode(
      entry: entry,
      children: children,
      depth: depth,
      isExpanded: isExpanded,
      selectionState: selectionState,
      tokenCount: tokenCount,
    );
  }

  @override
  Future<void> close() {
    _filterDebouncer?.cancel();
    _tokenCountDebouncer?.cancel();
    return super.close();
  }
}