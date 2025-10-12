import 'package:context_for_ai/features/code_combiner/data/datasources/file_system_data_source.dart';
import 'package:context_for_ai/features/code_combiner/data/enum/node_type.dart';
import 'package:context_for_ai/features/code_combiner/data/models/file_node.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Directory Scanner Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DirectoryScannerPage(),
    );
  }
}

class DirectoryScannerPage extends StatefulWidget {
  const DirectoryScannerPage({super.key});

  @override
  DirectoryScannerPageState createState() => DirectoryScannerPageState();
}

class DirectoryScannerPageState extends State<DirectoryScannerPage> {
  final FileSystemDataSourceImpl _dataSource = FileSystemDataSourceImpl();

  Map<String, FileNode> _scannedNodes = {};
  final Map<String, bool> _expandedNodes = {}; // Track expanded state
  bool _isScanning = false;
  String? _error;

  // Hardcoded directory path - using current project directory
  final String _directoryPath = '/home/ansh/Studio Projects/Clone/context_for_ai';

  @override
  void initState() {
    super.initState();
    _startScanning();
  }

  Future<void> _startScanning() async {
    setState(() {
      _isScanning = true;
      _error = null;
    });

    try {
      final nodes = await _dataSource.scanDirectory(_directoryPath);

      setState(() {
        _scannedNodes = nodes;
        _isScanning = false;
        // Initialize expanded state - root is expanded, folders collapsed
        _expandedNodes.clear();

        for (final node in nodes.values) {
          if (node.type == NodeType.folder) {
            _expandedNodes[node.id] =
                node.parentId ==
                null; // Only root expanded// Only root expanded/ Only root expanded
          }
        }
      });
    } on Exception catch (e) {
      setState(() {
        _error = e.toString();
        _isScanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Directory Scanner Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _startScanning,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scanning: $_directoryPath',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Total nodes found: ${_scannedNodes.length}'),
            const SizedBox(height: 16),

            if (_isScanning) ...[
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Scanning directory...'),
                  ],
                ),
              ),
            ] else if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Error:',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                    Text(_error!),
                  ],
                ),
              ),
            ] else if (_scannedNodes.isNotEmpty) ...[
              const Text(
                'Directory Tree:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildTree(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _toggleNodeExpansion(String nodeId) {
    setState(() {
      _expandedNodes[nodeId] = !(_expandedNodes[nodeId] ?? false);
    });
  }

  Widget _buildTree() {
    // Find root node
    final rootNode = _scannedNodes.values.firstWhere((node) => node.parentId == null);
    return _buildTreeNode(rootNode, 0);
  }

  Widget _buildTreeNode(FileNode node, int depth) {
    final isFolder = node.type == NodeType.folder;
    final isExpanded = _expandedNodes[node.id] ?? false;
    final hasChildren = isFolder && node.childIds.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: hasChildren ? () => _toggleNodeExpansion(node.id) : null,
          child: Container(
            padding: EdgeInsets.only(left: depth * 20.0, top: 4, bottom: 4),
            child: Row(
              children: [
                // Expand/collapse arrow for folders
                if (hasChildren) ...[
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                ] else ...[
                  const SizedBox(width: 20), // Space for files
                ],

                // File/folder icon
                Icon(
                  isFolder
                      ? (isExpanded ? Icons.folder_open : Icons.folder)
                      : _getFileIcon(node.name),
                  size: 16,
                  color: isFolder ? Colors.blue : Colors.grey[600],
                ),
                const SizedBox(width: 8),

                // File/folder name
                Expanded(
                  child: Text(
                    node.name,
                    style: TextStyle(
                      fontWeight: isFolder ? FontWeight.w500 : FontWeight.normal,
                      color: isFolder ? Colors.blue[800] : Colors.grey[800],
                      fontSize: 13,
                    ),
                  ),
                ),

                // File count for folders
                if (hasChildren)
                  Text(
                    '(${node.childIds.length})',
                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
                  ),
              ],
            ),
          ),
        ),

        // Show children if folder is expanded
        if (isFolder && hasChildren && isExpanded) ...[
          ...node.childIds.map((childId) {
            final childNode = _scannedNodes[childId];
            if (childNode != null) {
              return _buildTreeNode(childNode, depth + 1);
            }
            return const SizedBox.shrink();
          }),
        ],
      ],
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = path.extension(fileName).toLowerCase();
    switch (extension) {
      case '.dart':
        return Icons.code;
      case '.json':
        return Icons.data_object;
      case '.yaml':
      case '.yml':
        return Icons.settings;
      case '.md':
        return Icons.description;
      case '.png':
      case '.jpg':
      case '.jpeg':
      case '.gif':
        return Icons.image;
      case '.txt':
        return Icons.article;
      default:
        return Icons.insert_drive_file;
    }
  }
}
