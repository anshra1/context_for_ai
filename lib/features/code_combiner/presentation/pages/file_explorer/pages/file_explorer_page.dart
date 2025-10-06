import 'package:context_for_ai/features/code_combiner/data/enum/node_type.dart';
import 'package:context_for_ai/features/code_combiner/data/models/file_node.dart';
import 'package:context_for_ai/features/code_combiner/presentation/cubits/file_explorer_cubit.dart';
import 'package:context_for_ai/features/code_combiner/presentation/cubits/states/file_explorer_state.dart';
import 'package:context_for_ai/features/code_combiner/presentation/pages/file_explorer/widget/text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_system/material_design_system.dart';

class FileExplorerPage extends StatefulWidget {
  const FileExplorerPage({required this.workspaceData, super.key});

  final String workspaceData;

  @override
  State<FileExplorerPage> createState() => _FileExplorerPageState();
}

class _FileExplorerPageState extends State<FileExplorerPage> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _allowedExtensions = <String>{};

  @override
  void initState() {
    super.initState();
    context.read<FileExplorerCubit>().initialize(widget.workspaceData);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MdTheme.of(context);
    final spacing = SpacingTokens();

    return BlocBuilder<FileExplorerCubit, FileExplorerState>(
      builder: (context, state) {
        final isLoading = state is FileExplorerLoading;
        final nodes = switch (state) {
          final FileExplorerLoaded s => s.filteredNodes,
          final FileExplorerFilterUpdating s => s.filteredNodes,
          final FileExplorerFilterUpdateSuccess s => s.filteredNodes,
          _ => <String, FileNode>{},
        };

        return Scaffold(
          appBar: AppBar(
            title: const Text('File Export'),
            centerTitle: false,
          ),
          body: Padding(
            padding: EdgeInsets.all(spacing.large(context)),
            child: Column(
              children: [
                // Header with counts and token estimate placeholder
                Row(
                  children: [
                    Text(
                      '# No. of Files: ${nodes.values.where((n) => n.type == NodeType.file).length}',
                    ),
                    SizedBox(width: spacing.large(context)),
                    const Text(
                      'Token Estimate: ~— tokens',
                    ), // TODO: Calculate on demand
                  ],
                ),

                SizedBox(height: spacing.large(context)),

                // Filters section
                SizedBox(height: spacing.small(context)),
                TextFieldButtonWithLabel(
                  64.0,
                  labelText: 'Allowed File Extensions',
                  iconData: Icons.filter_list,

                  startingText: _allowedExtensions.join(', '),
                  tooltipText: 'Edit the comma-separated list of file extensions.',
                  onTextSubmitted: (value) {
                    final newExtensions = value
                        .split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toSet();

                    setState(() {
                      _allowedExtensions
                        ..clear()
                        ..addAll(newExtensions);
                    });
                    context.read<FileExplorerCubit>().applyPositiveFilters(
                      _allowedExtensions,
                    );
                  },
                ),

                SizedBox(height: spacing.large(context)),

                // Search & clear section
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search files...',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    SizedBox(width: spacing.medium(context)),
                    TextButton(
                      onPressed: () =>
                          context.read<FileExplorerCubit>().clearAllSelections(),
                      child: const Text('Clear All Selections'),
                    ),
                  ],
                ),

                SizedBox(height: spacing.large(context)),

                // File list
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: tokens.sys.outline),
                      borderRadius: ShapeTokens().borderRadiusMedium,
                    ),
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _TreeView(
                            nodes: _applySearch(nodes),
                          ),
                  ),
                ),

                SizedBox(height: spacing.large(context)),

                // Bottom actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Show preview UI
                      },
                      icon: const Icon(Icons.visibility_outlined),
                      label: const Text('Preview'),
                    ),
                    SizedBox(width: spacing.large(context)),
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Copy to clipboard
                      },
                      icon: const Icon(Icons.copy_all_outlined),
                      label: const Text('Copy to Clipboard'),
                    ),
                    SizedBox(width: spacing.large(context)),
                    ElevatedButton.icon(
                      onPressed: () =>
                          context.read<FileExplorerCubit>().exportSelectedFiles(),
                      icon: const Icon(Icons.save_alt_outlined),
                      label: const Text('Save as .txt'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Map<String, FileNode> _applySearch(Map<String, FileNode> nodes) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return nodes;
    return Map.fromEntries(
      nodes.entries.where((e) => e.value.name.toLowerCase().contains(query)),
    );
  }
}

class _TreeView extends StatelessWidget {
  const _TreeView({required this.nodes});

  final Map<String, FileNode> nodes;

  @override
  Widget build(BuildContext context) {
    // Find root nodes (no parent or parent not present)
    final roots = nodes.values.where(
      (n) => n.parentId == null || !nodes.containsKey(n.parentId),
    );
    return ListView(
      children: roots.map((n) => _TreeNode(node: n, nodes: nodes, depth: 0)).toList(),
    );
  }
}

class _TreeNode extends StatelessWidget {
  const _TreeNode({
    required this.node,
    required this.nodes,
    required this.depth,
  });

  final FileNode node;
  final Map<String, FileNode> nodes;
  final int depth;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FileExplorerCubit>();
    final isFolder = node.type == NodeType.folder;
    final theme = Theme.of(context);
    final isExpanded = isFolder && cubit.isFolderExpanded(node.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            if (isFolder) {
              cubit.toggleFolderExpansion(node.id);
            } else {
              cubit.toggleNodeSelection(node.id);
            }
          },
          child: Padding(
            padding: EdgeInsets.only(
              left: (depth * 24.0) + 8.0,
              top: 6,
              bottom: 6,
              right: 8,
            ),
            child: Row(
              children: [
                // Checkbox
                Checkbox(
                  value: node.selectionState.name == 'checked',
                  tristate: true,
                  onChanged: (_) => cubit.toggleNodeSelection(node.id),
                ),
                // Chevron placeholder / toggle
                if (isFolder)
                  InkWell(
                    onTap: () => cubit.toggleFolderExpansion(node.id),
                    child: Icon(
                      isExpanded ? Icons.expand_more : Icons.chevron_right,
                      size: 16,
                    ),
                  )
                else
                  const SizedBox(width: 16),
                const SizedBox(width: 4),
                Icon(
                  isFolder ? Icons.folder_outlined : Icons.insert_drive_file_outlined,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    node.name,
                    style: theme.textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isFolder && isExpanded)
          ...node.childIds
              .map((id) => nodes[id])
              .whereType<FileNode>()
              .map((child) => _TreeNode(node: child, nodes: nodes, depth: depth + 1)),
      ],
    );
  }
}
