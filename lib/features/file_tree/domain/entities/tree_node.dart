import 'package:freezed_annotation/freezed_annotation.dart';
import 'tree_entry.dart';
import 'selection_state.dart';

part 'tree_node.freezed.dart';

@freezed
class TreeNode with _$TreeNode {
  const factory TreeNode({
    required TreeEntry entry,
    @Default([]) List<TreeNode> children,
    @Default(0) int depth,
    @Default(false) bool isExpanded,
    @Default(SelectionState.unchecked) SelectionState selectionState,
    @Default(0) int tokenCount,
  }) = _TreeNode;
}