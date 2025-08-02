import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:context_for_ai/core/di/di.dart';
import '../../domain/entities/tree_filter.dart';
import '../cubit/file_tree_cubit.dart';
import '../cubit/file_tree_state.dart';
import 'tree_node_widget.dart';
import 'selection_summary_widget.dart';

/// Clean Architecture File Tree Widget
/// 
/// Features:
/// - Smart loading (performance optimized for 100+ folders)
/// - Hierarchical selection with cascading logic
/// - Integration with your existing AppSettings  
/// - Clean separation of data, business logic, and UI
class FileTreeWidget extends StatelessWidget {
  final String? initialPath;
  final TreeFilter? initialFilter;
  final VoidCallback? onSelectionChanged;
  final bool showSelectionSummary;
  final bool showFilterBar;
  final bool allowMultiSelection;
  final double indentationPerLevel;

  const FileTreeWidget({
    Key? key,
    this.initialPath,
    this.initialFilter,
    this.onSelectionChanged,
    this.showSelectionSummary = true,
    this.showFilterBar = false,
    this.allowMultiSelection = true,
    this.indentationPerLevel = 20.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<FileTreeCubit>(),
      child: _FileTreeContent(
        initialPath: initialPath,
        initialFilter: initialFilter,
        onSelectionChanged: onSelectionChanged,
        showSelectionSummary: showSelectionSummary,
        showFilterBar: showFilterBar,
        allowMultiSelection: allowMultiSelection,
        indentationPerLevel: indentationPerLevel,
      ),
    );
  }
}

class _FileTreeContent extends StatefulWidget {
  final String? initialPath;
  final TreeFilter? initialFilter;
  final VoidCallback? onSelectionChanged;
  final bool showSelectionSummary;
  final bool showFilterBar;
  final bool allowMultiSelection;
  final double indentationPerLevel;

  const _FileTreeContent({
    this.initialPath,
    this.initialFilter,
    this.onSelectionChanged,
    required this.showSelectionSummary,
    required this.showFilterBar,
    required this.allowMultiSelection,
    required this.indentationPerLevel,
  });

  @override
  State<_FileTreeContent> createState() => _FileTreeContentState();
}

class _FileTreeContentState extends State<_FileTreeContent> {
  @override
  void initState() {
    super.initState();
    if (widget.initialPath != null) {
      context.read<FileTreeCubit>().loadRoot(widget.initialPath!);
    }
    if (widget.initialFilter != null) {
      context.read<FileTreeCubit>().updateFilter(widget.initialFilter!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FileTreeCubit, FileTreeState>(
      listenWhen: (previous, current) => 
          previous.totalSelectedFiles != current.totalSelectedFiles,
      listener: (context, state) {
        widget.onSelectionChanged?.call();
      },
      child: Column(
        children: [
          // Selection Summary
          if (widget.showSelectionSummary) 
            const SelectionSummaryWidget(),

          // Filter Bar
          if (widget.showFilterBar) 
            _buildFilterBar(),

          // Tree View
          Expanded(
            child: BlocBuilder<FileTreeCubit, FileTreeState>(
              builder: (context, state) {
                return _buildTreeView(context, state);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search files...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                final cubit = context.read<FileTreeCubit>();
                final currentFilter = cubit.state.currentFilter;
                cubit.updateFilter(currentFilter.withSearchQuery(query));
              },
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: () => _showFilterOptions(context),
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter Options',
          ),
        ],
      ),
    );
  }

  Widget _buildTreeView(BuildContext context, FileTreeState state) {
    // Loading state
    if (state.isLoading && !state.hasContent) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading folder contents...'),
          ],
        ),
      );
    }

    // No path selected
    if (state.rootPath == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No folder selected',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Use changePath() to load a folder',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Build tree
    final treeNodes = context.read<FileTreeCubit>().buildTree();

    if (treeNodes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No files found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Tree view
    return ListView.builder(
      itemCount: _countFlattenedNodes(treeNodes),
      itemBuilder: (context, index) {
        final node = _getFlattenedNodeAt(treeNodes, index);
        if (node == null) return const SizedBox.shrink();

        return TreeNodeWidget(
          node: node,
          indentationPerLevel: widget.indentationPerLevel,
          allowSelection: widget.allowMultiSelection,
          onNodeTapped: (nodePath) {
            final cubit = context.read<FileTreeCubit>();
            if (node.entry.isDirectory) {
              if (node.isExpanded) {
                cubit.collapseFolder(nodePath);
              } else {
                cubit.expandFolder(nodePath);
              }
            }
          },
          onSelectionToggled: widget.allowMultiSelection
              ? (nodePath) {
                  context.read<FileTreeCubit>().toggleNodeSelection(nodePath);
                }
              : null,
        );
      },
    );
  }

  void _showFilterOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Options'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Filter options can be implemented here'),
            Text('Integration with your existing filters'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  int _countFlattenedNodes(List<dynamic> nodes) {
    int count = 0;
    for (final node in nodes) {
      count += 1;
      if (node.isExpanded && node.children.isNotEmpty) {
        count += _countFlattenedNodes(node.children);
      }
    }
    return count;
  }

  dynamic _getFlattenedNodeAt(List<dynamic> nodes, int targetIndex) {
    int currentIndex = 0;
    
    for (final node in nodes) {
      if (currentIndex == targetIndex) {
        return node;
      }
      currentIndex++;

      if (node.isExpanded && node.children.isNotEmpty) {
        final childResult = _getFlattenedNodeFromChildren(
          node.children, 
          targetIndex, 
          currentIndex,
        );
        if (childResult.node != null) {
          return childResult.node;
        }
        currentIndex = childResult.newIndex;
      }
    }
    
    return null;
  }

  ({dynamic node, int newIndex}) _getFlattenedNodeFromChildren(
    List<dynamic> children, 
    int targetIndex, 
    int currentIndex,
  ) {
    for (final child in children) {
      if (currentIndex == targetIndex) {
        return (node: child, newIndex: currentIndex);
      }
      currentIndex++;

      if (child.isExpanded && child.children.isNotEmpty) {
        final result = _getFlattenedNodeFromChildren(
          child.children, 
          targetIndex, 
          currentIndex,
        );
        if (result.node != null) {
          return result;
        }
        currentIndex = result.newIndex;
      }
    }
    
    return (node: null, newIndex: currentIndex);
  }
}

