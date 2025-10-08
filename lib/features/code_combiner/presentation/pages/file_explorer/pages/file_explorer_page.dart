import 'package:context_for_ai/core/routes/route_name.dart';
import 'package:context_for_ai/features/code_combiner/data/enum/node_type.dart';
import 'package:context_for_ai/features/code_combiner/data/models/file_node.dart';
import 'package:context_for_ai/features/code_combiner/presentation/cubits/file_explorer_cubit.dart';
import 'package:context_for_ai/features/code_combiner/presentation/cubits/file_explorer_state.dart';
import 'package:context_for_ai/features/code_combiner/presentation/pages/file_explorer/view/file_tree_view.dart';
import 'package:context_for_ai/features/code_combiner/presentation/pages/file_explorer/widget/bottom_buttons.dart';
import 'package:context_for_ai/features/code_combiner/presentation/pages/file_explorer/widget/filter_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_system/material_design_system.dart';

import 'package:context_for_ai/features/code_combiner/domain/repositories/code_combiner_repository.dart';

class FileExplorerPage extends StatefulWidget {
  const FileExplorerPage({required this.workspaceData, super.key});

  final Object workspaceData;

  @override
  State<FileExplorerPage> createState() => _FileExplorerPageState();
}

class _FileExplorerPageState extends State<FileExplorerPage> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<FileExplorerCubit>();
    final data = widget.workspaceData;
    if (data is WorkspaceData) {
      cubit.initializeFromWorkspaceData(data);
    } else if (data is String) {
      cubit.initialize(data);
    }
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
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => context.pushNamed(RoutesName.settings),
              ),
              const SizedBox(width: 8),
            ],
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

                // Filters section
                SizedBox(height: spacing.small(context)),
                FilterInput(
                  onChanged: (filters) {
                    context.read<FileExplorerCubit>().applyPositiveFilters(
                      filters.toSet(),
                    );
                  },
                  onSearchChanged: (query) {
                    context.read<FileExplorerCubit>().applySearchQuery(query);
                  },
                ),

                SizedBox(height: spacing.small(context)),

                Expanded(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(),
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : TreeView(nodes: nodes),
                  ),
                ),

                SizedBox(height: spacing.large(context)),

                // Bottom actions
                BottonButtons(spacing: spacing),
              ],
            ),
          ),
        );
      },
    );
  }
}
