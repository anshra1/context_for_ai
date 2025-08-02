import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/widgets/file_tree/models/file_tree_models.dart';
import '../cubit/combiner_tree_cubit.dart';
import '../cubit/combiner_tree_state.dart';

class CombinerFileTree extends StatelessWidget {
  final String rootPath;
  final FileTreeFilter? initialFilter;
  final VoidCallback? onSelectionChanged;
  final double indentationPerLevel;
  final bool showTokenCounts;
  final bool showFilterBar;

  const CombinerFileTree({
    Key? key,
    required this.rootPath,
    this.initialFilter,
    this.onSelectionChanged,
    this.indentationPerLevel = 20.0,
    this.showTokenCounts = true,
    this.showFilterBar = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CombinerTreeCubit(rootPath: rootPath),
      child: Column(
        children: [
          if (showFilterBar) const _FilterBar(),
          const _SelectionSummary(),
          const Expanded(child: _TreeView()),
        ],
      ),
    );
  }
}

class _FilterBar extends StatefulWidget {
  const _FilterBar();

  @override
  State<_FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<_FilterBar> {
  final _searchController = TextEditingController();
  final _allowedExtensions = <String>{'.dart', '.yaml', '.json'};

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search files...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _updateFilter();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (_) => _updateFilter(),
          ),
          
          const SizedBox(height: 12),
          
          // Extension filters
          Wrap(
            spacing: 8,
            children: [
              ..._allowedExtensions.map((ext) => FilterChip(
                label: Text(ext),
                selected: true,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _allowedExtensions.add(ext);
                    } else {
                      _allowedExtensions.remove(ext);
                    }
                  });
                  _updateFilter();
                },
              )),
              ActionChip(
                label: const Text('Add Filter'),
                onPressed: _showAddFilterDialog,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _updateFilter() {
    final filter = FileTreeFilter(
      allowedExtensions: _allowedExtensions.toList(),
      searchQuery: _searchController.text,
      showHiddenFiles: false,
      excludedFolders: ['.git', 'node_modules', '.DS_Store', 'build'],
    );
    
    context.read<CombinerTreeCubit>().updateFilter(filter);
  }

  void _showAddFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add File Extension'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'e.g., .txt, .md, .py',
            prefixText: '.',
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              final ext = value.startsWith('.') ? value : '.$value';
              setState(() {
                _allowedExtensions.add(ext);
              });
              _updateFilter();
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _SelectionSummary extends StatelessWidget {
  const _SelectionSummary();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CombinerTreeCubit, CombinerTreeState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.description,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '${state.totalSelectedFiles} files selected',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.token,
                size: 20,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                '~${_formatTokenCount(state.totalTokens)} tokens',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              if (state.totalSelectedFiles > 0)
                TextButton.icon(
                  onPressed: () => context.read<CombinerTreeCubit>().clearAllSelections(),
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text('Clear All'),
                ),
            ],
          ),
        );
      },
    );
  }

  String _formatTokenCount(int tokens) {
    if (tokens < 1000) return tokens.toString();
    if (tokens < 1000000) return '${(tokens / 1000).toStringAsFixed(1)}K';
    return '${(tokens / 1000000).toStringAsFixed(1)}M';
  }
}

class _TreeView extends StatelessWidget {
  const _TreeView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CombinerTreeCubit, CombinerTreeState>(
      builder: (context, state) {
        if (state.baseState.isLoading && state.baseState.cachedFolders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final treeNodes = context.read<CombinerTreeCubit>().buildTreeWithSelection();

        if (treeNodes.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No files found',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: _countAllNodes(treeNodes),
          itemBuilder: (context, index) {
            final node = _getNodeAtIndex(treeNodes, index);
            if (node == null) return const SizedBox.shrink();

            return _TreeNodeWidget(node: node);
          },
        );
      },
    );
  }

  int _countAllNodes(List<FileTreeNodeWithSelection> nodes) {
    int count = 0;
    for (final node in nodes) {
      count += 1;
      if (node.isExpanded) {
        count += _countAllNodes(node.children);
      }
    }
    return count;
  }

  FileTreeNodeWithSelection? _getNodeAtIndex(List<FileTreeNodeWithSelection> nodes, int targetIndex) {
    int currentIndex = 0;
    
    for (final node in nodes) {
      if (currentIndex == targetIndex) {
        return node;
      }
      currentIndex++;

      if (node.isExpanded) {
        final childResult = _getNodeFromChildren(node.children, targetIndex, currentIndex);
        if (childResult.node != null) {
          return childResult.node;
        }
        currentIndex = childResult.newIndex;
      }
    }
    
    return null;
  }

  ({FileTreeNodeWithSelection? node, int newIndex}) _getNodeFromChildren(
    List<FileTreeNodeWithSelection> children, 
    int targetIndex, 
    int currentIndex,
  ) {
    for (final child in children) {
      if (currentIndex == targetIndex) {
        return (node: child, newIndex: currentIndex);
      }
      currentIndex++;

      if (child.isExpanded) {
        final result = _getNodeFromChildren(child.children, targetIndex, currentIndex);
        if (result.node != null) {
          return result;
        }
        currentIndex = result.newIndex;
      }
    }
    
    return (node: null, newIndex: currentIndex);
  }
}

class _TreeNodeWidget extends StatelessWidget {
  final FileTreeNodeWithSelection node;

  const _TreeNodeWidget({required this.node});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CombinerTreeCubit>();
    
    return Container(
      padding: EdgeInsets.only(left: node.depth * 20.0),
      child: InkWell(
        onTap: () => _onRowTapped(cubit),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: Row(
            children: [
              // Expand/collapse button for folders
              if (node.entry.isDirectory) ...[
                SizedBox(
                  width: 24,
                  child: cubit.state.baseState.isFolderLoading(node.entry.path)
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          icon: Icon(
                            node.isExpanded 
                                ? Icons.keyboard_arrow_down 
                                : Icons.keyboard_arrow_right,
                            size: 16,
                          ),
                          onPressed: () => _onExpandToggle(cubit),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                ),
              ] else ...[
                const SizedBox(width: 24),
              ],

              // Selection checkbox
              SizedBox(
                width: 24,
                child: Checkbox(
                  value: _getCheckboxValue(),
                  tristate: true,
                  onChanged: (_) => cubit.toggleNodeSelection(node.entry.path),
                ),
              ),

              const SizedBox(width: 8),

              // File/folder icon
              Icon(
                node.entry.isDirectory ? Icons.folder : Icons.description,
                size: 18,
                color: node.entry.isDirectory 
                    ? Colors.amber[700] 
                    : _getFileIconColor(node.entry.extension),
              ),
              
              const SizedBox(width: 8),

              // File/folder name
              Expanded(
                child: Text(
                  node.entry.name,
                  style: TextStyle(
                    fontSize: 14,
                    color: node.entry.isReadable ? null : Colors.grey,
                    fontStyle: node.entry.isReadable ? null : FontStyle.italic,
                  ),
                ),
              ),

              // Token count for selected files
              if (!node.entry.isDirectory && node.tokenCount > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${node.tokenCount}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],

              // File size
              if (!node.entry.isDirectory && node.entry.size != null) ...[
                const SizedBox(width: 8),
                Text(
                  _formatFileSize(node.entry.size!),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool? _getCheckboxValue() {
    switch (node.selectionState) {
      case SelectionState.checked:
        return true;
      case SelectionState.unchecked:
        return false;
      case SelectionState.intermediate:
        return null; // Tristate checkbox shows indeterminate
    }
  }

  void _onRowTapped(CombinerTreeCubit cubit) {
    if (node.entry.isDirectory) {
      _onExpandToggle(cubit);
    } else {
      cubit.toggleNodeSelection(node.entry.path);
    }
  }

  void _onExpandToggle(CombinerTreeCubit cubit) {
    if (node.isExpanded) {
      cubit.collapseFolder(node.entry.path);
    } else {
      cubit.expandFolder(node.entry.path);
    }
  }

  Color _getFileIconColor(String extension) {
    switch (extension) {
      case '.dart':
        return Colors.blue;
      case '.json':
        return Colors.orange;
      case '.yaml':
      case '.yml':
        return Colors.purple;
      case '.md':
        return Colors.green;
      case '.txt':
        return Colors.grey;
      default:
        return Colors.grey[600]!;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}