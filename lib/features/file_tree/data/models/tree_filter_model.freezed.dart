// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tree_filter_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TreeFilterModel _$TreeFilterModelFromJson(Map<String, dynamic> json) {
  return _TreeFilterModel.fromJson(json);
}

/// @nodoc
mixin _$TreeFilterModel {
  List<String> get allowedExtensions => throw _privateConstructorUsedError;
  List<String> get excludedFolders => throw _privateConstructorUsedError;
  List<String> get excludedExtensions => throw _privateConstructorUsedError;
  bool get showHiddenFiles => throw _privateConstructorUsedError;
  String get searchQuery => throw _privateConstructorUsedError;

  /// Serializes this TreeFilterModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TreeFilterModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TreeFilterModelCopyWith<TreeFilterModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TreeFilterModelCopyWith<$Res> {
  factory $TreeFilterModelCopyWith(
          TreeFilterModel value, $Res Function(TreeFilterModel) then) =
      _$TreeFilterModelCopyWithImpl<$Res, TreeFilterModel>;
  @useResult
  $Res call(
      {List<String> allowedExtensions,
      List<String> excludedFolders,
      List<String> excludedExtensions,
      bool showHiddenFiles,
      String searchQuery});
}

/// @nodoc
class _$TreeFilterModelCopyWithImpl<$Res, $Val extends TreeFilterModel>
    implements $TreeFilterModelCopyWith<$Res> {
  _$TreeFilterModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TreeFilterModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? allowedExtensions = null,
    Object? excludedFolders = null,
    Object? excludedExtensions = null,
    Object? showHiddenFiles = null,
    Object? searchQuery = null,
  }) {
    return _then(_value.copyWith(
      allowedExtensions: null == allowedExtensions
          ? _value.allowedExtensions
          : allowedExtensions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      excludedFolders: null == excludedFolders
          ? _value.excludedFolders
          : excludedFolders // ignore: cast_nullable_to_non_nullable
              as List<String>,
      excludedExtensions: null == excludedExtensions
          ? _value.excludedExtensions
          : excludedExtensions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      showHiddenFiles: null == showHiddenFiles
          ? _value.showHiddenFiles
          : showHiddenFiles // ignore: cast_nullable_to_non_nullable
              as bool,
      searchQuery: null == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TreeFilterModelImplCopyWith<$Res>
    implements $TreeFilterModelCopyWith<$Res> {
  factory _$$TreeFilterModelImplCopyWith(_$TreeFilterModelImpl value,
          $Res Function(_$TreeFilterModelImpl) then) =
      __$$TreeFilterModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<String> allowedExtensions,
      List<String> excludedFolders,
      List<String> excludedExtensions,
      bool showHiddenFiles,
      String searchQuery});
}

/// @nodoc
class __$$TreeFilterModelImplCopyWithImpl<$Res>
    extends _$TreeFilterModelCopyWithImpl<$Res, _$TreeFilterModelImpl>
    implements _$$TreeFilterModelImplCopyWith<$Res> {
  __$$TreeFilterModelImplCopyWithImpl(
      _$TreeFilterModelImpl _value, $Res Function(_$TreeFilterModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TreeFilterModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? allowedExtensions = null,
    Object? excludedFolders = null,
    Object? excludedExtensions = null,
    Object? showHiddenFiles = null,
    Object? searchQuery = null,
  }) {
    return _then(_$TreeFilterModelImpl(
      allowedExtensions: null == allowedExtensions
          ? _value._allowedExtensions
          : allowedExtensions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      excludedFolders: null == excludedFolders
          ? _value._excludedFolders
          : excludedFolders // ignore: cast_nullable_to_non_nullable
              as List<String>,
      excludedExtensions: null == excludedExtensions
          ? _value._excludedExtensions
          : excludedExtensions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      showHiddenFiles: null == showHiddenFiles
          ? _value.showHiddenFiles
          : showHiddenFiles // ignore: cast_nullable_to_non_nullable
              as bool,
      searchQuery: null == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TreeFilterModelImpl extends _TreeFilterModel {
  const _$TreeFilterModelImpl(
      {final List<String> allowedExtensions = const [],
      final List<String> excludedFolders = const [
        '.git',
        'node_modules',
        '.DS_Store'
      ],
      final List<String> excludedExtensions = const [],
      this.showHiddenFiles = false,
      this.searchQuery = ''})
      : _allowedExtensions = allowedExtensions,
        _excludedFolders = excludedFolders,
        _excludedExtensions = excludedExtensions,
        super._();

  factory _$TreeFilterModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TreeFilterModelImplFromJson(json);

  final List<String> _allowedExtensions;
  @override
  @JsonKey()
  List<String> get allowedExtensions {
    if (_allowedExtensions is EqualUnmodifiableListView)
      return _allowedExtensions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allowedExtensions);
  }

  final List<String> _excludedFolders;
  @override
  @JsonKey()
  List<String> get excludedFolders {
    if (_excludedFolders is EqualUnmodifiableListView) return _excludedFolders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_excludedFolders);
  }

  final List<String> _excludedExtensions;
  @override
  @JsonKey()
  List<String> get excludedExtensions {
    if (_excludedExtensions is EqualUnmodifiableListView)
      return _excludedExtensions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_excludedExtensions);
  }

  @override
  @JsonKey()
  final bool showHiddenFiles;
  @override
  @JsonKey()
  final String searchQuery;

  @override
  String toString() {
    return 'TreeFilterModel(allowedExtensions: $allowedExtensions, excludedFolders: $excludedFolders, excludedExtensions: $excludedExtensions, showHiddenFiles: $showHiddenFiles, searchQuery: $searchQuery)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TreeFilterModelImpl &&
            const DeepCollectionEquality()
                .equals(other._allowedExtensions, _allowedExtensions) &&
            const DeepCollectionEquality()
                .equals(other._excludedFolders, _excludedFolders) &&
            const DeepCollectionEquality()
                .equals(other._excludedExtensions, _excludedExtensions) &&
            (identical(other.showHiddenFiles, showHiddenFiles) ||
                other.showHiddenFiles == showHiddenFiles) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_allowedExtensions),
      const DeepCollectionEquality().hash(_excludedFolders),
      const DeepCollectionEquality().hash(_excludedExtensions),
      showHiddenFiles,
      searchQuery);

  /// Create a copy of TreeFilterModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TreeFilterModelImplCopyWith<_$TreeFilterModelImpl> get copyWith =>
      __$$TreeFilterModelImplCopyWithImpl<_$TreeFilterModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TreeFilterModelImplToJson(
      this,
    );
  }
}

abstract class _TreeFilterModel extends TreeFilterModel {
  const factory _TreeFilterModel(
      {final List<String> allowedExtensions,
      final List<String> excludedFolders,
      final List<String> excludedExtensions,
      final bool showHiddenFiles,
      final String searchQuery}) = _$TreeFilterModelImpl;
  const _TreeFilterModel._() : super._();

  factory _TreeFilterModel.fromJson(Map<String, dynamic> json) =
      _$TreeFilterModelImpl.fromJson;

  @override
  List<String> get allowedExtensions;
  @override
  List<String> get excludedFolders;
  @override
  List<String> get excludedExtensions;
  @override
  bool get showHiddenFiles;
  @override
  String get searchQuery;

  /// Create a copy of TreeFilterModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TreeFilterModelImplCopyWith<_$TreeFilterModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
