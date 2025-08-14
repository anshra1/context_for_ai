import 'package:flutter/material.dart';

void main() => runApp(const SimpleTreeApp());

class SimpleTreeApp extends StatelessWidget {
  const SimpleTreeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Simple Tree Example')),
        body: const TreeExample(),
      ),
    );
  }
}

// Simple data structure for tree nodes
class SimpleNode {
  SimpleNode({
    required this.id,
    required this.name,
    this.children = const [],
  });

  final String id;
  final String name;
  final List<SimpleNode> children;
}

class TreeExample extends StatefulWidget {
  const TreeExample({super.key});

  @override
  TreeExampleState createState() => TreeExampleState();
}

class TreeExampleState extends State<TreeExample> {
  // Track which nodes are expanded
  final Set<String> _expandedNodes = {};

  // Sample tree data
  final SimpleNode _rootNode = SimpleNode(
    id: 'root',
    name: 'Project',
    children: [
      SimpleNode(
        id: 'lib',
        name: 'lib',
        children: [
          SimpleNode(id: 'main', name: 'main.dart'),
          SimpleNode(id: 'widgets', name: 'widgets.dart'),
        ],
      ),
      SimpleNode(
        id: 'test',
        name: 'test',
        children: [
          SimpleNode(id: 'test_file', name: 'test_file.dart'),
        ],
      ),
      SimpleNode(id: 'readme', name: 'README.md'),
    ],
  );

  @override
  void initState() {
    super.initState();
    // Start with root expanded
    _expandedNodes.add('root');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Simple Tree Structure:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // This calls buildTree() which starts the recursive rendering
          _buildTree(),
        ],
      ),
    );
  }

  // STEP 1: buildTree() - Find the root and start rendering
  Widget _buildTree() {
    print('📋 buildTree() called - Starting tree render from root');
    return _buildTreeNode(_rootNode, 0);
  }

  // STEP 2: buildTreeNode() - Recursively render each node
  Widget _buildTreeNode(SimpleNode node, int depth) {
    print('🌳 buildTreeNode(${node.name}, depth: $depth)');

    final hasChildren = node.children.isNotEmpty;
    final isExpanded = _expandedNodes.contains(node.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Render current node
        _renderSingleNode(node, depth, hasChildren, isExpanded),

        // If expanded and has children, render all children
        if (hasChildren && isExpanded) ...[
          ...node.children.map((child) {
            print('   ↳ Rendering child: ${child.name}');
            // RECURSIVE CALL: Each child calls buildTreeNode again
            return _buildTreeNode(child, depth + 1);
          }),
        ],
      ],
    );
  }

  // STEP 3: Render individual node UI
  Widget _renderSingleNode(
    SimpleNode node,
    int depth,
    bool hasChildren,
    bool isExpanded,
  ) {
    return GestureDetector(
      onTap: hasChildren ? () => _toggleExpansion(node.id) : null,
      child: Container(
        padding: EdgeInsets.only(left: depth * 20.0, top: 4, bottom: 4),
        child: Row(
          children: [
            // Show expand/collapse icon for folders
            if (hasChildren) ...[
              Icon(
                isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                size: 16,
              ),
              const SizedBox(width: 4),
            ] else ...[
              const SizedBox(width: 20), // Space for files
            ],

            // File/folder icon
            Icon(
              hasChildren ? Icons.folder : Icons.insert_drive_file,
              size: 16,
              color: hasChildren ? Colors.blue : Colors.grey,
            ),
            const SizedBox(width: 8),

            // Name
            Text(
              node.name,
              style: TextStyle(
                fontWeight: hasChildren ? FontWeight.bold : FontWeight.normal,
                color: hasChildren ? Colors.blue : Colors.black87,
              ),
            ),

            // Child count for folders
            if (hasChildren)
              Text(
                ' (${node.children.length})',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }

  void _toggleExpansion(String nodeId) {
    setState(() {
      if (_expandedNodes.contains(nodeId)) {
        _expandedNodes.remove(nodeId);
        print('📁 Collapsed: $nodeId');
      } else {
        _expandedNodes.add(nodeId);
        print('📂 Expanded: $nodeId');
      }
    });
  }
}

/* 
HOW IT WORKS:

1. buildTree() is called once to start rendering
2. buildTreeNode() is called recursively for each node:
   - First for root node (depth 0)
   - Then for each child (depth 1)  
   - Then for each grandchild (depth 2)
   - And so on...

3. Each call to buildTreeNode():
   - Renders the current node
   - If expanded, maps over children and calls buildTreeNode() again
   - Returns a Column containing current node + all child widgets

TREE STRUCTURE:
Project/              ← buildTreeNode(root, 0)
├── lib/              ← buildTreeNode(lib, 1)
│   ├── main.dart     ← buildTreeNode(main, 2)
│   └── widgets.dart  ← buildTreeNode(widgets, 2)
├── test/             ← buildTreeNode(test, 1)
│   └── test_file.dart← buildTreeNode(test_file, 2)
└── README.md         ← buildTreeNode(readme, 1)

The magic is in the recursion - each node renders itself, then tells 
its children to render themselves, creating the full tree!
*/
