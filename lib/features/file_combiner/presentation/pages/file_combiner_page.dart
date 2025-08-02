import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/combiner_file_tree.dart';
import '../cubit/combiner_tree_cubit.dart';
import '../cubit/combiner_tree_state.dart';

class FileCombinerPage extends StatelessWidget {
  final String initialPath;

  const FileCombinerPage({
    Key? key,
    required this.initialPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Combiner'),
        actions: [
          BlocBuilder<CombinerTreeCubit, CombinerTreeState>(
            builder: (context, state) {
              return TextButton.icon(
                onPressed: state.totalSelectedFiles > 0 
                    ? () => _showCombineDialog(context) 
                    : null,
                icon: const Icon(Icons.merge_outlined),
                label: Text('Combine (${state.totalSelectedFiles})'),
              );
            },
          ),
        ],
      ),
      body: CombinerFileTree(
        rootPath: initialPath,
        onSelectionChanged: () {
          // Optional: Handle selection changes
          print('Selection changed');
        },
      ),
    );
  }

  void _showCombineDialog(BuildContext context) {
    final cubit = context.read<CombinerTreeCubit>();
    final selectedFiles = cubit.getSelectedReadableFiles();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Combine Files'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${selectedFiles.length} files selected'),
            Text('~${cubit.state.totalTokens} tokens estimated'),
            const SizedBox(height: 16),
            const Text('Files to combine:'),
            const SizedBox(height: 8),
            Container(
              height: 200,
              width: double.maxFinite,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ListView.builder(
                itemCount: selectedFiles.length,
                itemBuilder: (context, index) {
                  final filePath = selectedFiles[index];
                  final fileName = filePath.split('/').last;
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.description, size: 16),
                    title: Text(
                      fileName,
                      style: const TextStyle(fontSize: 12),
                    ),
                    subtitle: Text(
                      filePath,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _combineFiles(context, selectedFiles);
            },
            child: const Text('Combine'),
          ),
        ],
      ),
    );
  }

  void _combineFiles(BuildContext context, List<String> filePaths) {
    // TODO: Implement file combination logic
    // This would typically call your existing combineFiles method
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Combining ${filePaths.length} files...'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            // TODO: Navigate to result
          },
        ),
      ),
    );
  }
}

// Alternative simple usage example
class SimpleUsageExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simple File Tree')),
      body: CombinerFileTree(
        rootPath: '/your/project/path',
        showFilterBar: true,
        showTokenCounts: true,
        onSelectionChanged: () {
          // Handle selection changes
        },
      ),
    );
  }
}