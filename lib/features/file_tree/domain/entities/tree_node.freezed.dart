// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tree_node.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TreeNode {
  TreeEntry get entry => throw _privateConstructorUsedError;
  List<TreeNode> get children => throw _privateConstructorUsedError;
  int get depth => throw _privateConstructorUsedError;
  bool get isExpanded => throw _privateConstructorUsedError;
  SelectionState get selectionState => throw _privateConstructorUsedError;
  int get tokenCount => throw _privateConstructorUsedError;

  /// Create a copy of TreeNode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TreeNodeCopyWith<TreeNode> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TreeNodeCopyWith<$Res> {
  factory $TreeNodeCopyWith(TreeNode value, $Res Function(TreeNode) then) =
      _$TreeNodeCopyWithImpl<$Res, TreeNode>;
  @useResult
  $Res call(
      {TreeEntry entry,
      List<TreeNode> children,
      int depth,
      bool isExpanded,
      SelectionState selectionState,
      int tokenCount});

  $TreeEntryCopyWith<$Res> get entry;
}

/// @nodoc
class _$TreeNodeCopyWithImpl<$Res, $Val extends TreeNode>
    implements $TreeNodeCopyWith<$Res> {
  _$TreeNodeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TreeNode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? entry = null,
    Object? children = null,
    Object? depth = null,
    Object? isExpanded = null,
    Object? selectionState = null,
    Object? tokenCount = null,
  }) {
    return _then(_value.copyWith(
      entry: null == entry
          ? _value.entry
          : entry // ignore: cast_nullable_to_non_nullable
              as TreeEntry,
      children: null == children
          ? _value.children
          : children // ignore: cast_nullable_to_non_nullable
              as List<TreeNode>,
      depth: null == depth
          ? _value.depth
          : depth // ignore: cast_nullable_to_non_nullable
              as int,
      isExpanded: null == isExpanded
          ? _value.isExpanded
          : isExpanded // ignore: cast_nullable_to_non_nullable
              as bool,
      selectionState: null == selectionState
          ? _value.selectionState
          : selectionState // ignore: cast_nullable_to_non_nullable
              as SelectionState,
      tokenCount: null == tokenCount
          ? _value.tokenCount
          : tokenCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }

  /// Create a copy of TreeNode
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TreeEntryCopyWith<$Res> get entry {
    return $TreeEntryCopyWith<$Res>(_value.entry, (value) {
      return _then(_value.copyWith(entry: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TreeNodeImplCopyWith<$Res>
    implements $TreeNodeCopyWith<$Res> {
  factory _$$TreeNodeImplCopyWith(
          _$TreeNodeImpl value, $Res Function(_$TreeNodeImpl) then) =
      __$$TreeNodeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {TreeEntry entry,
      List<TreeNode> children,
      int depth,
      bool isExpanded,
      SelectionState selectionState,
      int tokenCount});

  @override
  $TreeEntryCopyWith<$Res> get entry;
}

/// @nodoc
class __$$TreeNodeImplCopyWithImpl<$Res>
    extends _$TreeNodeCopyWithImpl<$Res, _$TreeNodeImpl>
    implements _$$TreeNodeImplCopyWith<$Res> {
  __$$TreeNodeImplCopyWithImpl(
      _$TreeNodeImpl _value, $Res Function(_$TreeNodeImpl) _then)
      : super(_value, _then);

  /// Create a copy of TreeNode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? entry = null,
    Object? children = null,
    Object? depth = null,
    Object? isExpanded = null,
    Object? selectionState = null,
    Object? tokenCount = null,
  }) {
    return _then(_$TreeNodeImpl(
      entry: null == entry
          ? _value.entry
          : entry // ignore: cast_nullable_to_non_nullable
              as TreeEntry,
      children: null == children
          ? _value._children
          : children // ignore: cast_nullable_to_non_nullable
              as List<TreeNode>,
      depth: null == depth
          ? _value.depth
          : depth // ignore: cast_nullable_to_non_nullable
              as int,
      isExpanded: null == isExpanded
          ? _value.isExpanded
          : isExpanded // ignore: cast_nullable_to_non_nullable
              as bool,
      selectionState: null == selectionState
          ? _value.selectionState
          : selectionState // ignore: cast_nullable_to_non_nullable
              as SelectionState,
      tokenCount: null == tokenCount
          ? _value.tokenCount
          : tokenCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$TreeNodeImpl implements _TreeNode {
  const _$TreeNodeImpl(
      {required this.entry,
      final List<TreeNode> children = const [],
      this.depth = 0,
      this.isExpanded = false,
      this.selectionState = SelectionState.unchecked,
      this.tokenCount = 0})
      : _children = children;

  @override
  final TreeEntry entry;
  final List<TreeNode> _children;
  @override
  @JsonKey()
  List<TreeNode> get children {
    if (_children is EqualUnmodifiableListView) return _children;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_children);
  }

  @override
  @JsonKey()
  final int depth;
  @override
  @JsonKey()
  final bool isExpanded;
  @override
  @JsonKey()
  final SelectionState selectionState;
  @override
  @JsonKey()
  final int tokenCount;

  @override
  String toString() {
    return 'TreeNode(entry: $entry, children: $children, depth: $depth, isExpanded: $isExpanded, selectionState: $selectionState, tokenCount: $tokenCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TreeNodeImpl &&
            (identical(other.entry, entry) || other.entry == entry) &&
            const DeepCollectionEquality().equals(other._children, _children) &&
            (identical(other.depth, depth) || other.depth == depth) &&
            (identical(other.isExpanded, isExpanded) ||
                other.isExpanded == isExpanded) &&
            (identical(other.selectionState, selectionState) ||
                other.selectionState == selectionState) &&
            (identical(other.tokenCount, tokenCount) ||
                other.tokenCount == tokenCount));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      entry,
      const DeepCollectionEquality().hash(_children),
      depth,
      isExpanded,
      selectionState,
      tokenCount);

  /// Create a copy of TreeNode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TreeNodeImplCopyWith<_$TreeNodeImpl> get copyWith =>
      __$$TreeNodeImplCopyWithImpl<_$TreeNodeImpl>(this, _$identity);
}

abstract class _TreeNode implements TreeNode {
  const factory _TreeNode(
      {required final TreeEntry entry,
      final List<TreeNode> children,
      final int depth,
      final bool isExpanded,
      final SelectionState selectionState,
      final int tokenCount}) = _$TreeNodeImpl;

  @override
  TreeEntry get entry;
  @override
  List<TreeNode> get children;
  @override
  int get depth;
  @override
  bool get isExpanded;
  @override
  SelectionState get selectionState;
  @override
  int get tokenCount;

  /// Create a copy of TreeNode
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TreeNodeImplCopyWith<_$TreeNodeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
