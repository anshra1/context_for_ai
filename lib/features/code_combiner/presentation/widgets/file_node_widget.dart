import 'package:flutter/material.dart';
import '../../data/models/file_node.dart';
import '../../data/models/node_type.dart';
import '../../data/models/selection_state.dart';

class FileNodeWidget extends StatelessWidget {
  final FileNode node;
  final Function(String)? onToggleSelection;
  final Function(String)? onToggleExpansion;
  final int depth;
  
  const FileNodeWidget({
    Key? key,
    required this.node,
    this.onToggleSelection,
    this.onToggleExpansion,
    this.depth = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            if (node.type == NodeType.folder) {
              onToggleExpansion?.call(node.id);
            }
          },
          child: Container(
            padding: EdgeInsets.only(
              left: depth * 16.0 + 8.0,
              right: 8.0,
              top: 4.0,
              bottom: 4.0,
            ),
            child: Row(
              children: [
                // TODO: Add expansion arrow for folders
                if (node.type == NodeType.folder) ...[
                  Icon(
                    node.isExpanded 
                        ? Icons.keyboard_arrow_down 
                        : Icons.keyboard_arrow_right,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                ] else ...[
                  const SizedBox(width: 20),
                ],
                
                // TODO: Add selection checkbox
                GestureDetector(
                  onTap: () => onToggleSelection?.call(node.id),
                  child: _buildCheckbox(),
                ),
                const SizedBox(width: 8),
                
                // TODO: Add file/folder icon
                Icon(
                  node.type == NodeType.folder 
                      ? Icons.folder 
                      : Icons.description,
                  size: 16,
                  color: node.type == NodeType.folder 
                      ? Colors.blue 
                      : Colors.grey[600],
                ),
                const SizedBox(width: 8),
                
                // TODO: Add file/folder name
                Expanded(
                  child: Text(
                    node.name,
                    style: TextStyle(
                      fontSize: 14,
                      color: _getTextColor(),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // TODO: Add children if folder is expanded
        if (node.type == NodeType.folder && node.isExpanded)
          ...node.childIds.map((childId) {
            // TODO: Get child node and render recursively
            return Container(
              key: ValueKey(childId),
              child: const Placeholder(fallbackHeight: 32),
            );
          }),
      ],
    );
  }
  
  Widget _buildCheckbox() {
    switch (node.selectionState) {
      case SelectionState.checked:
        return Container(
          width: 16,
          height: 16,
          decoration: const BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
          child: const Icon(
            Icons.check,
            size: 12,
            color: Colors.white,
          ),
        );
      case SelectionState.intermediate:
        return Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.grey[400],
            shape: BoxShape.rectangle,
            border: Border.all(color: Colors.grey[600]!),
            borderRadius: const BorderRadius.all(Radius.circular(2)),
          ),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[600],
              shape: BoxShape.rectangle,
            ),
          ),
        );
      case SelectionState.unchecked:
      default:
        return Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            border: Border.all(color: Colors.grey[600]!),
            borderRadius: const BorderRadius.all(Radius.circular(2)),
          ),
        );
    }
  }
  
  Color _getTextColor() {
    switch (node.selectionState) {
      case SelectionState.checked:
        return Colors.blue[700]!;
      case SelectionState.intermediate:
        return Colors.grey[700]!;
      case SelectionState.unchecked:
      default:
        return Colors.black87;
    }
  }
}