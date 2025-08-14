import 'package:context_for_ai/features/code_combiner/data/datasources/file_system_data_source.dart';
import 'package:context_for_ai/features/code_combiner/data/models/file_node.dart';
import 'package:context_for_ai/features/code_combiner/data/models/node_type.dart';
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
            _expandedNodes[node.id] = node.parentId == null; // Only root expanded
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
    return _buildTreeNode(rootNode, 0, [], true);
  }

  Widget _buildTreeNode(FileNode node, int depth, List<bool> lineStates, bool isLast) {
    final isFolder = node.type == NodeType.folder;
    final isExpanded = _expandedNodes[node.id] ?? false;
    final hasChildren = isFolder && node.childIds.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: hasChildren ? () => _toggleNodeExpansion(node.id) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
            child: Row(
              children: [
                // Build tree connection lines
                ...List.generate(depth, (index) {
                  if (index < lineStates.length) {
                    return SizedBox(
                      width: 20,
                      child: Text(
                        lineStates[index] ? '│' : ' ',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontFamily: 'monospace',
                        ),
                      ),
                    );
                  }
                  return const SizedBox(width: 20);
                }),

                // Connection line and arrow/icon
                if (depth > 0) ...[
                  SizedBox(
                    width: 20,
                    child: Text(
                      isLast ? '└─' : '├─',
                      style: TextStyle(color: Colors.grey[400], fontFamily: 'monospace'),
                    ),
                  ),
                ],

                // Expand/collapse arrow for folders
                if (hasChildren) ...[
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 2),
                ] else if (isFolder) ...[
                  const SizedBox(width: 18),
                ] else ...[
                  const SizedBox(width: 18),
                ],

                // File/folder icon
                Icon(
                  isFolder
                      ? (isExpanded ? Icons.folder_open : Icons.folder)
                      : _getFileIcon(node.name),
                  size: 16,
                  color: isFolder ? Colors.blue : Colors.grey[600],
                ),
                const SizedBox(width: 6),

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
          ...node.childIds.asMap().entries.map((entry) {
            final index = entry.key;
            final childId = entry.value;
            final childNode = _scannedNodes[childId];
            if (childNode != null) {
              final isLastChild = index == node.childIds.length - 1;
              final newLineStates = [...lineStates];
              if (depth > 0) {
                newLineStates.add(!isLast);
              }
              return _buildTreeNode(childNode, depth + 1, newLineStates, isLastChild);
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
