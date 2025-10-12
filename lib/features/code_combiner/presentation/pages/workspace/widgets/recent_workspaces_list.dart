import 'package:context_for_ai/features/code_combiner/presentation/pages/workspace/widgets/recent_workspace_file_path.dart';
import 'package:flutter/material.dart';

class RecentWorkspacesList extends StatelessWidget {
  const RecentWorkspacesList({
    required this.recentPaths,
    required this.onTapPath,
    this.loadingPath,
    super.key,
  });

  final List<String> recentPaths;
  final void Function(String path) onTapPath;
  final String? loadingPath;

  @override
  Widget build(BuildContext context) {
    if (recentPaths.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No recent workspaces yet',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Pick a folder or drop one to see it here.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    return Column(
      children: List.generate(recentPaths.length, (index) {
        final path = recentPaths[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => onTapPath(path),
              child: FilePathTile(
                filePath: path,
                onTap: () => onTapPath(path),
                isLoading: loadingPath == path,
              ),
            ),
          ),
        );
      }),
    );
  }
}
