// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tree_entry_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TreeEntryModel _$TreeEntryModelFromJson(Map<String, dynamic> json) {
  return _TreeEntryModel.fromJson(json);
}

/// @nodoc
mixin _$TreeEntryModel {
  String get name => throw _privateConstructorUsedError;
  String get path => throw _privateConstructorUsedError;
  bool get isDirectory => throw _privateConstructorUsedError;
  int? get size => throw _privateConstructorUsedError;
  DateTime? get lastModified => throw _privateConstructorUsedError;
  bool get isReadable => throw _privateConstructorUsedError;

  /// Serializes this TreeEntryModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TreeEntryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TreeEntryModelCopyWith<TreeEntryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TreeEntryModelCopyWith<$Res> {
  factory $TreeEntryModelCopyWith(
          TreeEntryModel value, $Res Function(TreeEntryModel) then) =
      _$TreeEntryModelCopyWithImpl<$Res, TreeEntryModel>;
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
class _$TreeEntryModelCopyWithImpl<$Res, $Val extends TreeEntryModel>
    implements $TreeEntryModelCopyWith<$Res> {
  _$TreeEntryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TreeEntryModel
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
abstract class _$$TreeEntryModelImplCopyWith<$Res>
    implements $TreeEntryModelCopyWith<$Res> {
  factory _$$TreeEntryModelImplCopyWith(_$TreeEntryModelImpl value,
          $Res Function(_$TreeEntryModelImpl) then) =
      __$$TreeEntryModelImplCopyWithImpl<$Res>;
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
class __$$TreeEntryModelImplCopyWithImpl<$Res>
    extends _$TreeEntryModelCopyWithImpl<$Res, _$TreeEntryModelImpl>
    implements _$$TreeEntryModelImplCopyWith<$Res> {
  __$$TreeEntryModelImplCopyWithImpl(
      _$TreeEntryModelImpl _value, $Res Function(_$TreeEntryModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TreeEntryModel
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
    return _then(_$TreeEntryModelImpl(
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
@JsonSerializable()
class _$TreeEntryModelImpl extends _TreeEntryModel {
  const _$TreeEntryModelImpl(
      {required this.name,
      required this.path,
      required this.isDirectory,
      this.size,
      this.lastModified,
      this.isReadable = true})
      : super._();

  factory _$TreeEntryModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TreeEntryModelImplFromJson(json);

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
    return 'TreeEntryModel(name: $name, path: $path, isDirectory: $isDirectory, size: $size, lastModified: $lastModified, isReadable: $isReadable)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TreeEntryModelImpl &&
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

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, name, path, isDirectory, size, lastModified, isReadable);

  /// Create a copy of TreeEntryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TreeEntryModelImplCopyWith<_$TreeEntryModelImpl> get copyWith =>
      __$$TreeEntryModelImplCopyWithImpl<_$TreeEntryModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TreeEntryModelImplToJson(
      this,
    );
  }
}

abstract class _TreeEntryModel extends TreeEntryModel {
  const factory _TreeEntryModel(
      {required final String name,
      required final String path,
      required final bool isDirectory,
      final int? size,
      final DateTime? lastModified,
      final bool isReadable}) = _$TreeEntryModelImpl;
  const _TreeEntryModel._() : super._();

  factory _TreeEntryModel.fromJson(Map<String, dynamic> json) =
      _$TreeEntryModelImpl.fromJson;

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

  /// Create a copy of TreeEntryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TreeEntryModelImplCopyWith<_$TreeEntryModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
