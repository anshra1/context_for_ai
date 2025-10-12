import 'package:context_for_ai/core/routes/route_name.dart';
import 'package:context_for_ai/features/code_combiner/presentation/cubits/workspace_state.dart';
import 'package:context_for_ai/features/code_combiner/presentation/cubits/workspace_cubit.dart';
import 'package:context_for_ai/features/code_combiner/presentation/pages/workspace/widgets/drag_and_drop_area.dart';
import 'package:context_for_ai/features/code_combiner/presentation/pages/workspace/widgets/recent_workspaces_list.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_system/material_design_system.dart';

class WorkspaceSelectorPage extends StatefulWidget {
  const WorkspaceSelectorPage({super.key});

  @override
  State<WorkspaceSelectorPage> createState() => _WorkspaceSelectorPageState();
}

class _WorkspaceSelectorPageState extends State<WorkspaceSelectorPage> {
  @override
  void initState() {
    super.initState();

    context.read<WorkspaceCubit>().loadRecentWorkspaces();
  }

  @override
  Widget build(BuildContext context) {
    final md = MdTheme.of(context);
    final spacing = SpacingTokens();

    return BlocConsumer<WorkspaceCubit, WorkspaceState>(
      listener: (context, state) {
        if (state is WorkspaceError) {
          // _showNotImplementedSnack(
          //   context,
          //   '${state.failure.title}: ${state.failure.message}',
          // );
        }
        // Navigation occurs on selection to explorer with path
        if (state is SuccessState) {
          // Optional feedback messages
          // _showNotImplementedSnack(context, state.message);
        }

        if (state is WorkspaceOpened) {
          context.pushNamed(RoutesName.fileExplorer, extra: state.workspaceData);
        }
      },
      builder: (context, state) {
        final isLoading = state is WorkspaceLoading;
        final recentPaths = state is WorkspaceLoaded
            ? state.workspaces.map((w) => w.path).toList()
            : <String>[];

        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                if (isLoading) const LinearProgressIndicator(minHeight: 2),
                if (isLoading) SizedBox(height: spacing.large(context)),
                SizedBox(height: spacing.small(context)),
                Align(
                  alignment: Alignment.centerLeft,
                  child: WorkspaceHeader(
                    title: 'WorkSpace Screen',
                    textStyle: md.typ
                        .getHeadlineMedium(context)
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),

                SizedBox(height: spacing.large() * 2),
                SizedBox(
                  width: 260,
                  height: 48,
                  child: PrimaryButtonWithIcon(
                    onPressed: () async {
                      final path = await _pickDirectoryWithSystemDialog();
                      if (path != null) {
                        if (!context.mounted) return;
                        await context.pushNamed(RoutesName.fileExplorer, extra: path);
                      }
                    },
                    text: 'Select a Directory',
                    borderRadius: 8,
                  ),
                ),
                SizedBox(height: spacing.large()),

                const FolderDropCopyPath(),

                SizedBox(height: spacing.large(context)),

                Align(
                  alignment: Alignment.centerLeft,
                  child: WorkspaceHeader(
                    title: 'Recent Workspaces',
                    textStyle: md.typ
                        .getTitleLarge(context)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                const Divider(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: RecentWorkspacesList(
                    recentPaths: recentPaths,
                    onTapPath: (path) {
                      context.read<WorkspaceCubit>().openDirectoryTree(path);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Future<String?> _pickDirectoryWithSystemDialog() async {
  try {
    final directoryPath = await FilePicker.platform
        .getDirectoryPath(
          dialogTitle: 'Select Workspace Directory',
        )
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => null,
        );
    return directoryPath;
  } on Exception catch (_) {
    // TODO: Handle unsupported platforms gracefully; fallback to manual prompt
    return null;
  }
}
