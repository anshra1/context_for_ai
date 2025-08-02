import '../entities/tree_node.dart';
import '../entities/selection_state.dart';

/// Domain service for tree node operations
class TreeNodeService {
  const TreeNodeService();

  /// Check if node is selected (checked or intermediate)
  bool isSelected(TreeNode node) {
    return node.selectionState == SelectionState.checked || 
           node.selectionState == SelectionState.intermediate;
  }

  /// Check if node is fully selected
  bool isFullySelected(TreeNode node) {
    return node.selectionState == SelectionState.checked;
  }

  /// Check if node is partially selected
  bool isPartiallySelected(TreeNode node) {
    return node.selectionState == SelectionState.intermediate;
  }

  /// Get readable files from node's children
  List<TreeNode> getReadableFiles(TreeNode node) {
    return node.children
        .where((child) => !child.entry.isDirectory && child.entry.isReadable)
        .toList();
  }

  /// Get directories from node's children
  List<TreeNode> getDirectories(TreeNode node) {
    return node.children
        .where((child) => child.entry.isDirectory)
        .toList();
  }

  /// Calculate total selected files in node and its children
  int calculateTotalSelectedFiles(TreeNode node) {
    int count = 0;
    
    if (!node.entry.isDirectory && 
        node.entry.isReadable && 
        isFullySelected(node)) {
      count = 1;
    }
    
    for (final child in node.children) {
      count += calculateTotalSelectedFiles(child);
    }
    
    return count;
  }

  /// Calculate total tokens in node and its children
  int calculateTotalTokens(TreeNode node) {
    int total = node.tokenCount;
    
    for (final child in node.children) {
      total += calculateTotalTokens(child);
    }
    
    return total;
  }

  /// Get all selected file paths from node tree
  List<String> getSelectedFilePaths(TreeNode node) {
    final paths = <String>[];
    
    if (!node.entry.isDirectory && 
        node.entry.isReadable && 
        isFullySelected(node)) {
      paths.add(node.entry.path);
    }
    
    for (final child in node.children) {
      paths.addAll(getSelectedFilePaths(child));
    }
    
    return paths;
  }
}