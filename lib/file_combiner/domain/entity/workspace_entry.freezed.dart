// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workspace_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WorkspaceEntry _$WorkspaceEntryFromJson(Map<String, dynamic> json) {
  return _WorkspaceEntry.fromJson(json);
}

/// @nodoc
mixin _$WorkspaceEntry {
  String get uuid => throw _privateConstructorUsedError;
  String get path =>
      throw _privateConstructorUsedError; // Full absolute directory path
  bool get isFavorite => throw _privateConstructorUsedError; // Starred or not
  DateTime get lastAccessedAt => throw _privateConstructorUsedError;

  /// Serializes this WorkspaceEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorkspaceEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkspaceEntryCopyWith<WorkspaceEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkspaceEntryCopyWith<$Res> {
  factory $WorkspaceEntryCopyWith(
          WorkspaceEntry value, $Res Function(WorkspaceEntry) then) =
      _$WorkspaceEntryCopyWithImpl<$Res, WorkspaceEntry>;
  @useResult
  $Res call(
      {String uuid, String path, bool isFavorite, DateTime lastAccessedAt});
}

/// @nodoc
class _$WorkspaceEntryCopyWithImpl<$Res, $Val extends WorkspaceEntry>
    implements $WorkspaceEntryCopyWith<$Res> {
  _$WorkspaceEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkspaceEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uuid = null,
    Object? path = null,
    Object? isFavorite = null,
    Object? lastAccessedAt = null,
  }) {
    return _then(_value.copyWith(
      uuid: null == uuid
          ? _value.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      path: null == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      lastAccessedAt: null == lastAccessedAt
          ? _value.lastAccessedAt
          : lastAccessedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkspaceEntryImplCopyWith<$Res>
    implements $WorkspaceEntryCopyWith<$Res> {
  factory _$$WorkspaceEntryImplCopyWith(_$WorkspaceEntryImpl value,
          $Res Function(_$WorkspaceEntryImpl) then) =
      __$$WorkspaceEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String uuid, String path, bool isFavorite, DateTime lastAccessedAt});
}

/// @nodoc
class __$$WorkspaceEntryImplCopyWithImpl<$Res>
    extends _$WorkspaceEntryCopyWithImpl<$Res, _$WorkspaceEntryImpl>
    implements _$$WorkspaceEntryImplCopyWith<$Res> {
  __$$WorkspaceEntryImplCopyWithImpl(
      _$WorkspaceEntryImpl _value, $Res Function(_$WorkspaceEntryImpl) _then)
      : super(_value, _then);

  /// Create a copy of WorkspaceEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uuid = null,
    Object? path = null,
    Object? isFavorite = null,
    Object? lastAccessedAt = null,
  }) {
    return _then(_$WorkspaceEntryImpl(
      uuid: null == uuid
          ? _value.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      path: null == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      lastAccessedAt: null == lastAccessedAt
          ? _value.lastAccessedAt
          : lastAccessedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkspaceEntryImpl implements _WorkspaceEntry {
  const _$WorkspaceEntryImpl(
      {required this.uuid,
      required this.path,
      required this.isFavorite,
      required this.lastAccessedAt});

  factory _$WorkspaceEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkspaceEntryImplFromJson(json);

  @override
  final String uuid;
  @override
  final String path;
// Full absolute directory path
  @override
  final bool isFavorite;
// Starred or not
  @override
  final DateTime lastAccessedAt;

  @override
  String toString() {
    return 'WorkspaceEntry(uuid: $uuid, path: $path, isFavorite: $isFavorite, lastAccessedAt: $lastAccessedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkspaceEntryImpl &&
            (identical(other.uuid, uuid) || other.uuid == uuid) &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            (identical(other.lastAccessedAt, lastAccessedAt) ||
                other.lastAccessedAt == lastAccessedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, uuid, path, isFavorite, lastAccessedAt);

  /// Create a copy of WorkspaceEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkspaceEntryImplCopyWith<_$WorkspaceEntryImpl> get copyWith =>
      __$$WorkspaceEntryImplCopyWithImpl<_$WorkspaceEntryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkspaceEntryImplToJson(
      this,
    );
  }
}

abstract class _WorkspaceEntry implements WorkspaceEntry {
  const factory _WorkspaceEntry(
      {required final String uuid,
      required final String path,
      required final bool isFavorite,
      required final DateTime lastAccessedAt}) = _$WorkspaceEntryImpl;

  factory _WorkspaceEntry.fromJson(Map<String, dynamic> json) =
      _$WorkspaceEntryImpl.fromJson;

  @override
  String get uuid;
  @override
  String get path; // Full absolute directory path
  @override
  bool get isFavorite; // Starred or not
  @override
  DateTime get lastAccessedAt;

  /// Create a copy of WorkspaceEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkspaceEntryImplCopyWith<_$WorkspaceEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
