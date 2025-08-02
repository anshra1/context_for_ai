import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/widgets/file_tree/models/file_tree_models.dart';
import '../../../../features/setting/data/datasource/setting_datasource.dart';
import '../../../../core/models/app_settings_hive.dart';
import '../cubit/combiner_tree_cubit.dart';
import '../cubit/combiner_tree_state.dart';
import 'combiner_file_tree.dart';

/// Dynamic path version of CombinerFileTree that integrates with your AppSettings
class DynamicCombinerFileTree extends StatefulWidget {
  final String? initialPath;
  final SettingsDataSource settingsDataSource;
  final VoidCallback? onSelectionChanged;
  final bool showPathSelector;
  final bool showFilterBar;
  final bool showTokenCounts;

  const DynamicCombinerFileTree({
    Key? key,
    this.initialPath,
    required this.settingsDataSource,
    this.onSelectionChanged,
    this.showPathSelector = true,
    this.showFilterBar = true,
    this.showTokenCounts = true,
  }) : super(key: key);

  @override
  State<DynamicCombinerFileTree> createState() => _DynamicCombinerFileTreeState();
}

class _DynamicCombinerFileTreeState extends State<DynamicCombinerFileTree> {
  late CombinerTreeCubit _cubit;
  String? _currentPath;
  AppSettingsHive? _currentSettings;

  @override
  void initState() {
    super.initState();
    _currentPath = widget.initialPath;
    _cubit = CombinerTreeCubit();
    _loadSettingsAndInitialize();
  }

  Future<void> _loadSettingsAndInitialize() async {
    try {
      // Load your existing app settings
      final settings = await widget.settingsDataSource.loadSettings();
      setState(() {
        _currentSettings = AppSettingsHive.fromModel(settings);
      });

      // Initialize tree if path provided
      if (_currentPath != null) {
        await _loadPathWithSettings(_currentPath!);
      }
    } catch (e) {
      // Handle error loading settings
      print('Error loading settings: $e');
    }
  }

  Future<void> _loadPathWithSettings(String rootPath) async {
    if (_currentSettings == null) return;

    // Create filter from your app settings + any additional allowed extensions
    final filter = FileTreeFilter.fromAppSettings(
      excludedFileExtensions: _currentSettings!.excludedFileExtensions,
      excludedNames: _currentSettings!.excludedNames,
      showHiddenFiles: _currentSettings!.showHiddenFiles,
      allowedExtensions: ['.dart', '.yaml', '.json'], // File combiner specific
    );

    // Apply settings to tree
    _cubit.updateFilter(filter);
    await _cubit.loadRoot(rootPath);
    
    setState(() {
      _currentPath = rootPath;
    });
  }

  /// Change to a new path dynamically
  Future<void> changePath(String newPath) async {
    await _loadPathWithSettings(newPath);
    widget.onSelectionChanged?.call();
  }

  /// Refresh with current settings (useful after settings change)
  Future<void> refreshWithNewSettings() async {
    await _loadSettingsAndInitialize();
    if (_currentPath != null) {
      await _loadPathWithSettings(_currentPath!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Column(
        children: [
          // Path selector
          if (widget.showPathSelector) _buildPathSelector(),
          
          // Tree content
          if (_currentPath != null)
            Expanded(
              child: _buildTreeContent(),
            )
          else
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_open, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Select a folder to explore'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPathSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.folder,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _currentPath ?? 'No folder selected',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _currentPath != null 
                    ? null 
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          TextButton.icon(
            onPressed: _showPathPicker,
            icon: const Icon(Icons.folder_open),
            label: const Text('Change Path'),
          ),
        ],
      ),
    );
  }

  Widget _buildTreeContent() {
    return BlocBuilder<CombinerTreeCubit, CombinerTreeState>(
      builder: (context, state) {
        return Column(
          children: [
            // Selection summary
            _buildSelectionSummary(state),
            
            // Filter bar (if enabled)
            if (widget.showFilterBar) _buildFilterBar(),
            
            // Tree view
            Expanded(
              child: _buildTreeView(state),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSelectionSummary(CombinerTreeState state) {
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
          Icon(
            Icons.description,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            '${state.totalSelectedFiles} files selected',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (widget.showTokenCounts) ...[
            Icon(
              Icons.token,
              size: 20,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(width: 8),
            Text(
              '~${_formatTokenCount(state.totalTokens)} tokens',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(width: 16),
          if (state.totalSelectedFiles > 0)
            TextButton.icon(
              onPressed: () => _cubit.clearAllSelections(),
              icon: const Icon(Icons.clear_all, size: 16),
              label: const Text('Clear All'),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    // Simple filter bar - you can expand this
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search files...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                if (_currentSettings != null) {
                  final filter = FileTreeFilter.fromAppSettings(
                    excludedFileExtensions: _currentSettings!.excludedFileExtensions,
                    excludedNames: _currentSettings!.excludedNames,
                    showHiddenFiles: _currentSettings!.showHiddenFiles,
                    allowedExtensions: ['.dart', '.yaml', '.json'],
                    searchQuery: query,
                  );
                  _cubit.updateFilter(filter);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreeView(CombinerTreeState state) {
    if (state.baseState.isLoading && state.baseState.cachedFolders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final treeNodes = _cubit.buildTreeWithSelection();

    if (treeNodes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No files found matching current filters',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    // Use the tree view from CombinerFileTree
    return ListView.builder(
      itemCount: _countAllNodes(treeNodes),
      itemBuilder: (context, index) {
        final node = _getNodeAtIndex(treeNodes, index);
        if (node == null) return const SizedBox.shrink();

        // Use your existing tree node widget logic here
        return _TreeNodeWidget(node: node);
      },
    );
  }

  void _showPathPicker() async {
    // Simple path input dialog - you can make this more sophisticated
    final controller = TextEditingController(text: _currentPath ?? '');
    
    final newPath = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Folder Path'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter folder path...',
            prefixIcon: Icon(Icons.folder),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Load'),
          ),
        ],
      ),
    );

    if (newPath != null && newPath.isNotEmpty) {
      await changePath(newPath);
    }
  }

  String _formatTokenCount(int tokens) {
    if (tokens < 1000) return tokens.toString();
    if (tokens < 1000000) return '${(tokens / 1000).toStringAsFixed(1)}K';
    return '${(tokens / 1000000).toStringAsFixed(1)}M';
  }

  // Helper methods for tree rendering (simplified versions)
  int _countAllNodes(List<dynamic> nodes) => nodes.length; // Simplified
  dynamic _getNodeAtIndex(List<dynamic> nodes, int index) => 
      index < nodes.length ? nodes[index] : null; // Simplified

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }
}

// Simplified tree node widget for the dynamic version
class _TreeNodeWidget extends StatelessWidget {
  final dynamic node;

  const _TreeNodeWidget({required this.node});

  @override
  Widget build(BuildContext context) {
    // Simplified version - use your full implementation from combiner_file_tree.dart
    return ListTile(
      title: Text(node.entry?.name ?? 'Unknown'),
      leading: Icon(
        node.entry?.isDirectory == true ? Icons.folder : Icons.description,
      ),
    );
  }
}