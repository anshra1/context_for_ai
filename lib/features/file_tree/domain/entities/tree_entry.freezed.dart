// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tree_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TreeEntry {
  String get name => throw _privateConstructorUsedError;
  String get path => throw _privateConstructorUsedError;
  bool get isDirectory => throw _privateConstructorUsedError;
  int? get size => throw _privateConstructorUsedError;
  DateTime? get lastModified => throw _privateConstructorUsedError;
  bool get isReadable => throw _privateConstructorUsedError;

  /// Create a copy of TreeEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TreeEntryCopyWith<TreeEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TreeEntryCopyWith<$Res> {
  factory $TreeEntryCopyWith(TreeEntry value, $Res Function(TreeEntry) then) =
      _$TreeEntryCopyWithImpl<$Res, TreeEntry>;
  @useResult
  $Res call(
      {String name,
      String path,
      bool isDirectory,
      int? size,
      DateTime? lastModified,
      bool isReadable});
}

/// @nodoc
class _$TreeEntryCopyWithImpl<$Res, $Val extends TreeEntry>
    implements $TreeEntryCopyWith<$Res> {
  _$TreeEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TreeEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? path = null,
    Object? isDirectory = null,
    Object? size = freezed,
    Object? lastModified = freezed,
    Object? isReadable = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      path: null == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String,
      isDirectory: null == isDirectory
          ? _value.isDirectory
          : isDirectory // ignore: cast_nullable_to_non_nullable
              as bool,
      size: freezed == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int?,
      lastModified: freezed == lastModified
          ? _value.lastModified
          : lastModified // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isReadable: null == isReadable
          ? _value.isReadable
          : isReadable // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TreeEntryImplCopyWith<$Res>
    implements $TreeEntryCopyWith<$Res> {
  factory _$$TreeEntryImplCopyWith(
          _$TreeEntryImpl value, $Res Function(_$TreeEntryImpl) then) =
      __$$TreeEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String path,
      bool isDirectory,
      int? size,
      DateTime? lastModified,
      bool isReadable});
}

/// @nodoc
class __$$TreeEntryImplCopyWithImpl<$Res>
    extends _$TreeEntryCopyWithImpl<$Res, _$TreeEntryImpl>
    implements _$$TreeEntryImplCopyWith<$Res> {
  __$$TreeEntryImplCopyWithImpl(
      _$TreeEntryImpl _value, $Res Function(_$TreeEntryImpl) _then)
      : super(_value, _then);

  /// Create a copy of TreeEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? path = null,
    Object? isDirectory = null,
    Object? size = freezed,
    Object? lastModified = freezed,
    Object? isReadable = null,
  }) {
    return _then(_$TreeEntryImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      path: null == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String,
      isDirectory: null == isDirectory
          ? _value.isDirectory
          : isDirectory // ignore: cast_nullable_to_non_nullable
              as bool,
      size: freezed == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int?,
      lastModified: freezed == lastModified
          ? _value.lastModified
          : lastModified // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isReadable: null == isReadable
          ? _value.isReadable
          : isReadable // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$TreeEntryImpl implements _TreeEntry {
  const _$TreeEntryImpl(
      {required this.name,
      required this.path,
      required this.isDirectory,
      this.size,
      this.lastModified,
      this.isReadable = true});

  @override
  final String name;
  @override
  final String path;
  @override
  final bool isDirectory;
  @override
  final int? size;
  @override
  final DateTime? lastModified;
  @override
  @JsonKey()
  final bool isReadable;

  @override
  String toString() {
    return 'TreeEntry(name: $name, path: $path, isDirectory: $isDirectory, size: $size, lastModified: $lastModified, isReadable: $isReadable)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TreeEntryImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.isDirectory, isDirectory) ||
                other.isDirectory == isDirectory) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.lastModified, lastModified) ||
                other.lastModified == lastModified) &&
            (identical(other.isReadable, isReadable) ||
                other.isReadable == isReadable));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, name, path, isDirectory, size, lastModified, isReadable);

  /// Create a copy of TreeEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TreeEntryImplCopyWith<_$TreeEntryImpl> get copyWith =>
      __$$TreeEntryImplCopyWithImpl<_$TreeEntryImpl>(this, _$identity);
}

abstract class _TreeEntry implements TreeEntry {
  const factory _TreeEntry(
      {required final String name,
      required final String path,
      required final bool isDirectory,
      final int? size,
      final DateTime? lastModified,
      final bool isReadable}) = _$TreeEntryImpl;

  @override
  String get name;
  @override
  String get path;
  @override
  bool get isDirectory;
  @override
  int? get size;
  @override
  DateTime? get lastModified;
  @override
  bool get isReadable;

  /// Create a copy of TreeEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TreeEntryImplCopyWith<_$TreeEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
