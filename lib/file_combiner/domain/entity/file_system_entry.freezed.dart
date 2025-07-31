// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'file_system_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FileSystemEntry _$FileSystemEntryFromJson(Map<String, dynamic> json) {
  return _FileSystemEntry.fromJson(json);
}

/// @nodoc
mixin _$FileSystemEntry {
  String get name => throw _privateConstructorUsedError;
  String get path => throw _privateConstructorUsedError;
  bool get isDirectory => throw _privateConstructorUsedError;
  int? get size => throw _privateConstructorUsedError;

  /// Serializes this FileSystemEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FileSystemEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FileSystemEntryCopyWith<FileSystemEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FileSystemEntryCopyWith<$Res> {
  factory $FileSystemEntryCopyWith(
          FileSystemEntry value, $Res Function(FileSystemEntry) then) =
      _$FileSystemEntryCopyWithImpl<$Res, FileSystemEntry>;
  @useResult
  $Res call({String name, String path, bool isDirectory, int? size});
}

/// @nodoc
class _$FileSystemEntryCopyWithImpl<$Res, $Val extends FileSystemEntry>
    implements $FileSystemEntryCopyWith<$Res> {
  _$FileSystemEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FileSystemEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? path = null,
    Object? isDirectory = null,
    Object? size = freezed,
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FileSystemEntryImplCopyWith<$Res>
    implements $FileSystemEntryCopyWith<$Res> {
  factory _$$FileSystemEntryImplCopyWith(_$FileSystemEntryImpl value,
          $Res Function(_$FileSystemEntryImpl) then) =
      __$$FileSystemEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String path, bool isDirectory, int? size});
}

/// @nodoc
class __$$FileSystemEntryImplCopyWithImpl<$Res>
    extends _$FileSystemEntryCopyWithImpl<$Res, _$FileSystemEntryImpl>
    implements _$$FileSystemEntryImplCopyWith<$Res> {
  __$$FileSystemEntryImplCopyWithImpl(
      _$FileSystemEntryImpl _value, $Res Function(_$FileSystemEntryImpl) _then)
      : super(_value, _then);

  /// Create a copy of FileSystemEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? path = null,
    Object? isDirectory = null,
    Object? size = freezed,
  }) {
    return _then(_$FileSystemEntryImpl(
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FileSystemEntryImpl implements _FileSystemEntry {
  const _$FileSystemEntryImpl(
      {required this.name,
      required this.path,
      required this.isDirectory,
      this.size});

  factory _$FileSystemEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$FileSystemEntryImplFromJson(json);

  @override
  final String name;
  @override
  final String path;
  @override
  final bool isDirectory;
  @override
  final int? size;

  @override
  String toString() {
    return 'FileSystemEntry(name: $name, path: $path, isDirectory: $isDirectory, size: $size)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FileSystemEntryImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.isDirectory, isDirectory) ||
                other.isDirectory == isDirectory) &&
            (identical(other.size, size) || other.size == size));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, path, isDirectory, size);

  /// Create a copy of FileSystemEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FileSystemEntryImplCopyWith<_$FileSystemEntryImpl> get copyWith =>
      __$$FileSystemEntryImplCopyWithImpl<_$FileSystemEntryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FileSystemEntryImplToJson(
      this,
    );
  }
}

abstract class _FileSystemEntry implements FileSystemEntry {
  const factory _FileSystemEntry(
      {required final String name,
      required final String path,
      required final bool isDirectory,
      final int? size}) = _$FileSystemEntryImpl;

  factory _FileSystemEntry.fromJson(Map<String, dynamic> json) =
      _$FileSystemEntryImpl.fromJson;

  @override
  String get name;
  @override
  String get path;
  @override
  bool get isDirectory;
  @override
  int? get size;

  /// Create a copy of FileSystemEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FileSystemEntryImplCopyWith<_$FileSystemEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
