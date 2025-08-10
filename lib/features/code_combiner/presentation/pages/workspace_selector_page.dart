import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/workspace_cubit.dart';
import '../widgets/workspace_list_widget.dart';
import '../../data/models/recent_workspace.dart';

class WorkspaceSelectorPage extends StatelessWidget {
  const WorkspaceSelectorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Workspace'),
        actions: [
          // TODO: Add refresh button to cleanup invalid workspaces
          IconButton(
            onPressed: () {
              // TODO: Implement workspace cleanup
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Workspaces',
          ),
        ],
      ),
      body: BlocBuilder<WorkspaceCubit, List<RecentWorkspace>>(
        builder: (context, workspaces) {
          if (workspaces.isEmpty) {
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
                    'No recent workspaces',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Select a folder to get started',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          
          return Column(
            children: [
              // TODO: Add workspace list
              const Expanded(
                // child: WorkspaceListWidget(workspaces: workspaces),
                child: Placeholder(),
              ),
              
              // TODO: Add action buttons
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implement folder picker
                        },
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Browse for Folder'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}