import 'package:freezed_annotation/freezed_annotation.dart';
import 'tree_entry.dart';

part 'tree_node.freezed.dart';

@freezed
class TreeNode with _$TreeNode {
  const factory TreeNode({
    required TreeEntry entry,
    required List<TreeNode> children,
    required int depth,
    required bool isExpanded,
    int? tokenCount,
  }) = _TreeNode;
}