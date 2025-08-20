import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/file_explorer_cubit.dart';
import '../../data/models/file_tree_state.dart';
import '../../data/models/file_node.dart';
import '../../data/enum/node_type.dart';
import 'file_node_widget.dart';

class FileTreeWidget extends StatelessWidget {
  const FileTreeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FileExplorerCubit, FileTreeState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading file tree...'),
              ],
            ),
          );
        }
        
        if (state.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error: ${state.errorMessage}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement retry logic
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        if (state.allNodes.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_open,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No files to display',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Select a workspace to get started',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }
        
        return Column(
          children: [
            // TODO: Add tree header with selection info
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text('Selected: ${state.selectedFileIds.length} files'),
                  const Spacer(),
                  Text('Tokens: ${state.tokenCount}'),
                  const SizedBox(width: 16),
                  // TODO: Add clear all button
                  TextButton(
                    onPressed: () {
                      context.read<FileExplorerCubit>().clearAllSelections();
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            
            // TODO: Add scrollable file tree
            Expanded(
              child: ListView(
                children: _buildTreeNodes(context, state),
              ),
            ),
          ],
        );
      },
    );
  }
  
  List<Widget> _buildTreeNodes(BuildContext context, FileTreeState state) {
    // TODO: Implement tree node building
    final rootNodes = state.allNodes.values
        .where((node) => node.parentId == null || node.parentId == state.rootId)
        .toList();
    
    return rootNodes.map((node) => FileNodeWidget(
      key: ValueKey(node.id),
      node: node,
      // onToggleSelection: (nodeId) {
      //   context.read<FileExplorerCubit>().toggleNodeSelection(nodeId);
      // },
      // onToggleExpansion: (nodeId) {
      //   context.read<FileExplorerCubit>().toggleFolderExpansion(nodeId);
      // },
    )).toList();
  }
}