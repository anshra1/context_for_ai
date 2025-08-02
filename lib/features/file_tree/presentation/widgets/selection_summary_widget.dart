import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/file_tree_cubit.dart';
import '../cubit/file_tree_state.dart';

class SelectionSummaryWidget extends StatelessWidget {
  final bool showTokenCount;
  final bool showClearButton;

  const SelectionSummaryWidget({
    Key? key,
    this.showTokenCount = true,
    this.showClearButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FileTreeCubit, FileTreeState>(
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
              // Files icon and count
              Icon(
                Icons.description,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                state.selectionSummary,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const Spacer(),
              
              // Token count
              if (showTokenCount) ...[
                Icon(
                  Icons.token,
                  size: 20,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  state.tokenSummary,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              
              // Clear button
              if (showClearButton && state.totalSelectedFiles > 0) ...[
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () => context.read<FileTreeCubit>().clearAllSelections(),
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text('Clear All'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}