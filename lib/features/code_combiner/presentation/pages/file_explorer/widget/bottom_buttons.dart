import 'package:context_for_ai/features/code_combiner/presentation/cubits/file_explorer_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_system/tokens/base_token/spacing_tokens.dart';

class BottonButtons extends StatelessWidget {
  const BottonButtons({
    required this.spacing,
    super.key,
  });

  final SpacingTokens spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
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
          onPressed: () => context.read<FileExplorerCubit>().exportSelectedFiles(),
          icon: const Icon(Icons.save_alt_outlined),
          label: const Text('Save as .txt'),
        ),
      ],
    );
  }
}