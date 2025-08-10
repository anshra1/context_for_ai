import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/file_explorer_cubit.dart';
import '../cubits/settings_cubit.dart';
import '../../data/models/file_tree_state.dart';
import '../../data/models/filter_settings.dart';

class FilterPanelWidget extends StatefulWidget {
  const FilterPanelWidget({Key? key}) : super(key: key);

  @override
  State<FilterPanelWidget> createState() => _FilterPanelWidgetState();
}

class _FilterPanelWidgetState extends State<FilterPanelWidget> {
  final TextEditingController _extensionController = TextEditingController();
  final Set<String> _sessionExtensions = {};
  
  @override
  void dispose() {
    _extensionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FileExplorerCubit, FileTreeState>(
      builder: (context, state) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TODO: Add filter panel header
                const Text(
                  'Filters',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                // TODO: Add positive filtering section
                const Text(
                  'Show only these file types:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _extensionController,
                        decoration: const InputDecoration(
                          hintText: 'e.g., .dart, .js, .py',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: _addExtension,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _addExtension(_extensionController.text),
                      child: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // TODO: Add extension chips
                Wrap(
                  spacing: 8.0,
                  children: _sessionExtensions.map((ext) {
                    return Chip(
                      label: Text(ext),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () => _removeExtension(ext),
                    );
                  }).toList(),
                ),
                
                if (_sessionExtensions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _applyFilters,
                        child: const Text('Apply Filters'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _clearFilters,
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // TODO: Add negative filters section
                const Text(
                  'Blocked Extensions:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                
                Wrap(
                  spacing: 4.0,
                  children: state.filterSettings.blockedExtensions.map((ext) {
                    return Chip(
                      label: Text(ext),
                      backgroundColor: Colors.red[100],
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 16),
                
                // TODO: Add settings link
                TextButton.icon(
                  onPressed: () {
                    // TODO: Navigate to settings page
                  },
                  icon: const Icon(Icons.settings),
                  label: const Text('Manage Blocked Items'),
                ),
                
                const SizedBox(height: 16),
                
                // TODO: Add filter statistics
                const Divider(),
                Text('Total Files: ${state.allNodes.length}'),
                Text('Selected: ${state.selectedFileIds.length}'),
                if (state.filterSettings.enablePositiveFiltering)
                  const Text(
                    'Positive filtering active',
                    style: TextStyle(color: Colors.blue),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  void _addExtension(String extension) {
    if (extension.trim().isEmpty) return;
    
    String cleanExtension = extension.trim();
    if (!cleanExtension.startsWith('.')) {
      cleanExtension = '.$cleanExtension';
    }
    
    setState(() {
      _sessionExtensions.add(cleanExtension);
      _extensionController.clear();
    });
  }
  
  void _removeExtension(String extension) {
    setState(() {
      _sessionExtensions.remove(extension);
    });
    
    // If no extensions left, clear filters
    if (_sessionExtensions.isEmpty) {
      _clearFilters();
    }
  }
  
  void _applyFilters() {
    context.read<FileExplorerCubit>().applyPositiveFilters(_sessionExtensions);
  }
  
  void _clearFilters() {
    setState(() {
      _sessionExtensions.clear();
    });
    context.read<FileExplorerCubit>().applyPositiveFilters({});
  }
}