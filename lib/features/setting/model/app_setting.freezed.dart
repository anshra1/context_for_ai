// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_setting.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) {
  return _AppSettings.fromJson(json);
}

/// @nodoc
mixin _$AppSettings {
  List<String> get excludedFileExtensions => throw _privateConstructorUsedError;
  List<String> get excludedNames => throw _privateConstructorUsedError;
  bool get showHiddenFiles => throw _privateConstructorUsedError;
  int? get maxTokenCount => throw _privateConstructorUsedError;
  bool get stripComments => throw _privateConstructorUsedError;
  bool get warnOnTokenExceed => throw _privateConstructorUsedError;

  /// Serializes this AppSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppSettingsCopyWith<AppSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppSettingsCopyWith<$Res> {
  factory $AppSettingsCopyWith(
          AppSettings value, $Res Function(AppSettings) then) =
      _$AppSettingsCopyWithImpl<$Res, AppSettings>;
  @useResult
  $Res call(
      {List<String> excludedFileExtensions,
      List<String> excludedNames,
      bool showHiddenFiles,
      int? maxTokenCount,
      bool stripComments,
      bool warnOnTokenExceed});
}

/// @nodoc
class _$AppSettingsCopyWithImpl<$Res, $Val extends AppSettings>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? excludedFileExtensions = null,
    Object? excludedNames = null,
    Object? showHiddenFiles = null,
    Object? maxTokenCount = freezed,
    Object? stripComments = null,
    Object? warnOnTokenExceed = null,
  }) {
    return _then(_value.copyWith(
      excludedFileExtensions: null == excludedFileExtensions
          ? _value.excludedFileExtensions
          : excludedFileExtensions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      excludedNames: null == excludedNames
          ? _value.excludedNames
          : excludedNames // ignore: cast_nullable_to_non_nullable
              as List<String>,
      showHiddenFiles: null == showHiddenFiles
          ? _value.showHiddenFiles
          : showHiddenFiles // ignore: cast_nullable_to_non_nullable
              as bool,
      maxTokenCount: freezed == maxTokenCount
          ? _value.maxTokenCount
          : maxTokenCount // ignore: cast_nullable_to_non_nullable
              as int?,
      stripComments: null == stripComments
          ? _value.stripComments
          : stripComments // ignore: cast_nullable_to_non_nullable
              as bool,
      warnOnTokenExceed: null == warnOnTokenExceed
          ? _value.warnOnTokenExceed
          : warnOnTokenExceed // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppSettingsImplCopyWith<$Res>
    implements $AppSettingsCopyWith<$Res> {
  factory _$$AppSettingsImplCopyWith(
          _$AppSettingsImpl value, $Res Function(_$AppSettingsImpl) then) =
      __$$AppSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<String> excludedFileExtensions,
      List<String> excludedNames,
      bool showHiddenFiles,
      int? maxTokenCount,
      bool stripComments,
      bool warnOnTokenExceed});
}

/// @nodoc
class __$$AppSettingsImplCopyWithImpl<$Res>
    extends _$AppSettingsCopyWithImpl<$Res, _$AppSettingsImpl>
    implements _$$AppSettingsImplCopyWith<$Res> {
  __$$AppSettingsImplCopyWithImpl(
      _$AppSettingsImpl _value, $Res Function(_$AppSettingsImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? excludedFileExtensions = null,
    Object? excludedNames = null,
    Object? showHiddenFiles = null,
    Object? maxTokenCount = freezed,
    Object? stripComments = null,
    Object? warnOnTokenExceed = null,
  }) {
    return _then(_$AppSettingsImpl(
      excludedFileExtensions: null == excludedFileExtensions
          ? _value._excludedFileExtensions
          : excludedFileExtensions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      excludedNames: null == excludedNames
          ? _value._excludedNames
          : excludedNames // ignore: cast_nullable_to_non_nullable
              as List<String>,
      showHiddenFiles: null == showHiddenFiles
          ? _value.showHiddenFiles
          : showHiddenFiles // ignore: cast_nullable_to_non_nullable
              as bool,
      maxTokenCount: freezed == maxTokenCount
          ? _value.maxTokenCount
          : maxTokenCount // ignore: cast_nullable_to_non_nullable
              as int?,
      stripComments: null == stripComments
          ? _value.stripComments
          : stripComments // ignore: cast_nullable_to_non_nullable
              as bool,
      warnOnTokenExceed: null == warnOnTokenExceed
          ? _value.warnOnTokenExceed
          : warnOnTokenExceed // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AppSettingsImpl implements _AppSettings {
  const _$AppSettingsImpl(
      {required final List<String> excludedFileExtensions,
      required final List<String> excludedNames,
      required this.showHiddenFiles,
      required this.maxTokenCount,
      required this.stripComments,
      required this.warnOnTokenExceed})
      : _excludedFileExtensions = excludedFileExtensions,
        _excludedNames = excludedNames;

  factory _$AppSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppSettingsImplFromJson(json);

  final List<String> _excludedFileExtensions;
  @override
  List<String> get excludedFileExtensions {
    if (_excludedFileExtensions is EqualUnmodifiableListView)
      return _excludedFileExtensions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_excludedFileExtensions);
  }

  final List<String> _excludedNames;
  @override
  List<String> get excludedNames {
    if (_excludedNames is EqualUnmodifiableListView) return _excludedNames;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_excludedNames);
  }

  @override
  final bool showHiddenFiles;
  @override
  final int? maxTokenCount;
  @override
  final bool stripComments;
  @override
  final bool warnOnTokenExceed;

  @override
  String toString() {
    return 'AppSettings(excludedFileExtensions: $excludedFileExtensions, excludedNames: $excludedNames, showHiddenFiles: $showHiddenFiles, maxTokenCount: $maxTokenCount, stripComments: $stripComments, warnOnTokenExceed: $warnOnTokenExceed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppSettingsImpl &&
            const DeepCollectionEquality().equals(
                other._excludedFileExtensions, _excludedFileExtensions) &&
            const DeepCollectionEquality()
                .equals(other._excludedNames, _excludedNames) &&
            (identical(other.showHiddenFiles, showHiddenFiles) ||
                other.showHiddenFiles == showHiddenFiles) &&
            (identical(other.maxTokenCount, maxTokenCount) ||
                other.maxTokenCount == maxTokenCount) &&
            (identical(other.stripComments, stripComments) ||
                other.stripComments == stripComments) &&
            (identical(other.warnOnTokenExceed, warnOnTokenExceed) ||
                other.warnOnTokenExceed == warnOnTokenExceed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_excludedFileExtensions),
      const DeepCollectionEquality().hash(_excludedNames),
      showHiddenFiles,
      maxTokenCount,
      stripComments,
      warnOnTokenExceed);

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppSettingsImplCopyWith<_$AppSettingsImpl> get copyWith =>
      __$$AppSettingsImplCopyWithImpl<_$AppSettingsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppSettingsImplToJson(
      this,
    );
  }
}

abstract class _AppSettings implements AppSettings {
  const factory _AppSettings(
      {required final List<String> excludedFileExtensions,
      required final List<String> excludedNames,
      required final bool showHiddenFiles,
      required final int? maxTokenCount,
      required final bool stripComments,
      required final bool warnOnTokenExceed}) = _$AppSettingsImpl;

  factory _AppSettings.fromJson(Map<String, dynamic> json) =
      _$AppSettingsImpl.fromJson;

  @override
  List<String> get excludedFileExtensions;
  @override
  List<String> get excludedNames;
  @override
  bool get showHiddenFiles;
  @override
  int? get maxTokenCount;
  @override
  bool get stripComments;
  @override
  bool get warnOnTokenExceed;

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppSettingsImplCopyWith<_$AppSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
