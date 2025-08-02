import 'package:flutter/material.dart';
import '../../domain/entities/tree_node.dart';
import '../../domain/entities/selection_state.dart';
import '../../domain/value_objects/file_extension.dart';

class TreeNodeWidget extends StatelessWidget {
  final TreeNode node;
  final double indentationPerLevel;
  final bool allowSelection;
  final Function(String)? onNodeTapped;
  final Function(String)? onSelectionToggled;
  final bool showFileSize;
  final bool showTokenCount;

  const TreeNodeWidget({
    Key? key,
    required this.node,
    this.indentationPerLevel = 20.0,
    this.allowSelection = true,
    this.onNodeTapped,
    this.onSelectionToggled,
    this.showFileSize = true,
    this.showTokenCount = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: node.depth * indentationPerLevel),
      child: InkWell(
        onTap: () => onNodeTapped?.call(node.entry.path),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: Row(
            children: [
              // Expand/collapse button for directories
              if (node.entry.isDirectory) ...[
                SizedBox(
                  width: 24,
                  child: IconButton(
                    icon: Icon(
                      node.isExpanded 
                          ? Icons.keyboard_arrow_down 
                          : Icons.keyboard_arrow_right,
                      size: 16,
                    ),
                    onPressed: () => onNodeTapped?.call(node.entry.path),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ] else ...[
                const SizedBox(width: 24),
              ],

              // Selection checkbox
              if (allowSelection) ...[
                SizedBox(
                  width: 24,
                  child: Checkbox(
                    value: _getCheckboxValue(),
                    tristate: true,
                    onChanged: (_) => onSelectionToggled?.call(node.entry.path),
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // File/folder icon
              Icon(
                node.entry.isDirectory ? Icons.folder : Icons.description,
                size: 18,
                color: node.entry.isDirectory 
                    ? Colors.amber[700] 
                    : _getFileIconColor(),
              ),
              
              const SizedBox(width: 8),

              // File/folder name
              Expanded(
                child: Text(
                  node.entry.name,
                  style: TextStyle(
                    fontSize: 14,
                    color: node.entry.isReadable ? null : Colors.grey,
                    fontStyle: node.entry.isReadable ? null : FontStyle.italic,
                  ),
                ),
              ),

              // Token count for selected files
              if (showTokenCount && 
                  !node.entry.isDirectory && 
                  node.tokenCount > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${node.tokenCount}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // File size
              if (showFileSize && 
                  !node.entry.isDirectory && 
                  node.entry.size != null) ...[
                Text(
                  _formatFileSize(node.entry.size!),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool? _getCheckboxValue() {
    switch (node.selectionState) {
      case SelectionState.checked:
        return true;
      case SelectionState.unchecked:
        return false;
      case SelectionState.intermediate:
        return null; // Tristate checkbox shows indeterminate
    }
  }

  Color _getFileIconColor() {
    final extension = FileExtension.fromEntry(node.entry);
    
    switch (extension.value) {
      case '.dart':
        return Colors.blue;
      case '.json':
        return Colors.orange;
      case '.yaml':
      case '.yml':
        return Colors.purple;
      case '.md':
        return Colors.green;
      case '.txt':
        return Colors.grey;
      default:
        return Colors.grey[600]!;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}