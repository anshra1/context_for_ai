// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'file_tree_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$FileTreeState {
// Tree Data
  Map<String, List<TreeEntry>> get cachedFolders =>
      throw _privateConstructorUsedError;
  Map<String, List<TreeEntry>> get filteredFolders =>
      throw _privateConstructorUsedError;
  Set<String> get expandedFolders => throw _privateConstructorUsedError;
  Set<String> get loadedFolders =>
      throw _privateConstructorUsedError; // Selection State (separated from tree data)
  Map<String, SelectionState> get selectionStates =>
      throw _privateConstructorUsedError;
  Set<String> get selectedFilePaths => throw _privateConstructorUsedError;
  Map<String, int> get tokenCounts =>
      throw _privateConstructorUsedError; // Filter & Search
  TreeFilter get currentFilter =>
      throw _privateConstructorUsedError; // UI State
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isUpdatingSelection => throw _privateConstructorUsedError;
  Map<String, bool> get folderLoadingStates =>
      throw _privateConstructorUsedError;
  Map<String, String> get folderErrors =>
      throw _privateConstructorUsedError; // Current Context
  String? get rootPath => throw _privateConstructorUsedError; // Statistics
  int get totalSelectedFiles => throw _privateConstructorUsedError;
  int get totalTokens => throw _privateConstructorUsedError;

  /// Create a copy of FileTreeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FileTreeStateCopyWith<FileTreeState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FileTreeStateCopyWith<$Res> {
  factory $FileTreeStateCopyWith(
          FileTreeState value, $Res Function(FileTreeState) then) =
      _$FileTreeStateCopyWithImpl<$Res, FileTreeState>;
  @useResult
  $Res call(
      {Map<String, List<TreeEntry>> cachedFolders,
      Map<String, List<TreeEntry>> filteredFolders,
      Set<String> expandedFolders,
      Set<String> loadedFolders,
      Map<String, SelectionState> selectionStates,
      Set<String> selectedFilePaths,
      Map<String, int> tokenCounts,
      TreeFilter currentFilter,
      bool isLoading,
      bool isUpdatingSelection,
      Map<String, bool> folderLoadingStates,
      Map<String, String> folderErrors,
      String? rootPath,
      int totalSelectedFiles,
      int totalTokens});

  $TreeFilterCopyWith<$Res> get currentFilter;
}

/// @nodoc
class _$FileTreeStateCopyWithImpl<$Res, $Val extends FileTreeState>
    implements $FileTreeStateCopyWith<$Res> {
  _$FileTreeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FileTreeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cachedFolders = null,
    Object? filteredFolders = null,
    Object? expandedFolders = null,
    Object? loadedFolders = null,
    Object? selectionStates = null,
    Object? selectedFilePaths = null,
    Object? tokenCounts = null,
    Object? currentFilter = null,
    Object? isLoading = null,
    Object? isUpdatingSelection = null,
    Object? folderLoadingStates = null,
    Object? folderErrors = null,
    Object? rootPath = freezed,
    Object? totalSelectedFiles = null,
    Object? totalTokens = null,
  }) {
    return _then(_value.copyWith(
      cachedFolders: null == cachedFolders
          ? _value.cachedFolders
          : cachedFolders // ignore: cast_nullable_to_non_nullable
              as Map<String, List<TreeEntry>>,
      filteredFolders: null == filteredFolders
          ? _value.filteredFolders
          : filteredFolders // ignore: cast_nullable_to_non_nullable
              as Map<String, List<TreeEntry>>,
      expandedFolders: null == expandedFolders
          ? _value.expandedFolders
          : expandedFolders // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      loadedFolders: null == loadedFolders
          ? _value.loadedFolders
          : loadedFolders // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      selectionStates: null == selectionStates
          ? _value.selectionStates
          : selectionStates // ignore: cast_nullable_to_non_nullable
              as Map<String, SelectionState>,
      selectedFilePaths: null == selectedFilePaths
          ? _value.selectedFilePaths
          : selectedFilePaths // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      tokenCounts: null == tokenCounts
          ? _value.tokenCounts
          : tokenCounts // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      currentFilter: null == currentFilter
          ? _value.currentFilter
          : currentFilter // ignore: cast_nullable_to_non_nullable
              as TreeFilter,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isUpdatingSelection: null == isUpdatingSelection
          ? _value.isUpdatingSelection
          : isUpdatingSelection // ignore: cast_nullable_to_non_nullable
              as bool,
      folderLoadingStates: null == folderLoadingStates
          ? _value.folderLoadingStates
          : folderLoadingStates // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
      folderErrors: null == folderErrors
          ? _value.folderErrors
          : folderErrors // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      rootPath: freezed == rootPath
          ? _value.rootPath
          : rootPath // ignore: cast_nullable_to_non_nullable
              as String?,
      totalSelectedFiles: null == totalSelectedFiles
          ? _value.totalSelectedFiles
          : totalSelectedFiles // ignore: cast_nullable_to_non_nullable
              as int,
      totalTokens: null == totalTokens
          ? _value.totalTokens
          : totalTokens // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }

  /// Create a copy of FileTreeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TreeFilterCopyWith<$Res> get currentFilter {
    return $TreeFilterCopyWith<$Res>(_value.currentFilter, (value) {
      return _then(_value.copyWith(currentFilter: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FileTreeStateImplCopyWith<$Res>
    implements $FileTreeStateCopyWith<$Res> {
  factory _$$FileTreeStateImplCopyWith(
          _$FileTreeStateImpl value, $Res Function(_$FileTreeStateImpl) then) =
      __$$FileTreeStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Map<String, List<TreeEntry>> cachedFolders,
      Map<String, List<TreeEntry>> filteredFolders,
      Set<String> expandedFolders,
      Set<String> loadedFolders,
      Map<String, SelectionState> selectionStates,
      Set<String> selectedFilePaths,
      Map<String, int> tokenCounts,
      TreeFilter currentFilter,
      bool isLoading,
      bool isUpdatingSelection,
      Map<String, bool> folderLoadingStates,
      Map<String, String> folderErrors,
      String? rootPath,
      int totalSelectedFiles,
      int totalTokens});

  @override
  $TreeFilterCopyWith<$Res> get currentFilter;
}

/// @nodoc
class __$$FileTreeStateImplCopyWithImpl<$Res>
    extends _$FileTreeStateCopyWithImpl<$Res, _$FileTreeStateImpl>
    implements _$$FileTreeStateImplCopyWith<$Res> {
  __$$FileTreeStateImplCopyWithImpl(
      _$FileTreeStateImpl _value, $Res Function(_$FileTreeStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of FileTreeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cachedFolders = null,
    Object? filteredFolders = null,
    Object? expandedFolders = null,
    Object? loadedFolders = null,
    Object? selectionStates = null,
    Object? selectedFilePaths = null,
    Object? tokenCounts = null,
    Object? currentFilter = null,
    Object? isLoading = null,
    Object? isUpdatingSelection = null,
    Object? folderLoadingStates = null,
    Object? folderErrors = null,
    Object? rootPath = freezed,
    Object? totalSelectedFiles = null,
    Object? totalTokens = null,
  }) {
    return _then(_$FileTreeStateImpl(
      cachedFolders: null == cachedFolders
          ? _value._cachedFolders
          : cachedFolders // ignore: cast_nullable_to_non_nullable
              as Map<String, List<TreeEntry>>,
      filteredFolders: null == filteredFolders
          ? _value._filteredFolders
          : filteredFolders // ignore: cast_nullable_to_non_nullable
              as Map<String, List<TreeEntry>>,
      expandedFolders: null == expandedFolders
          ? _value._expandedFolders
          : expandedFolders // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      loadedFolders: null == loadedFolders
          ? _value._loadedFolders
          : loadedFolders // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      selectionStates: null == selectionStates
          ? _value._selectionStates
          : selectionStates // ignore: cast_nullable_to_non_nullable
              as Map<String, SelectionState>,
      selectedFilePaths: null == selectedFilePaths
          ? _value._selectedFilePaths
          : selectedFilePaths // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      tokenCounts: null == tokenCounts
          ? _value._tokenCounts
          : tokenCounts // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      currentFilter: null == currentFilter
          ? _value.currentFilter
          : currentFilter // ignore: cast_nullable_to_non_nullable
              as TreeFilter,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isUpdatingSelection: null == isUpdatingSelection
          ? _value.isUpdatingSelection
          : isUpdatingSelection // ignore: cast_nullable_to_non_nullable
              as bool,
      folderLoadingStates: null == folderLoadingStates
          ? _value._folderLoadingStates
          : folderLoadingStates // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
      folderErrors: null == folderErrors
          ? _value._folderErrors
          : folderErrors // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      rootPath: freezed == rootPath
          ? _value.rootPath
          : rootPath // ignore: cast_nullable_to_non_nullable
              as String?,
      totalSelectedFiles: null == totalSelectedFiles
          ? _value.totalSelectedFiles
          : totalSelectedFiles // ignore: cast_nullable_to_non_nullable
              as int,
      totalTokens: null == totalTokens
          ? _value.totalTokens
          : totalTokens // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$FileTreeStateImpl extends _FileTreeState {
  const _$FileTreeStateImpl(
      {final Map<String, List<TreeEntry>> cachedFolders = const {},
      final Map<String, List<TreeEntry>> filteredFolders = const {},
      final Set<String> expandedFolders = const {},
      final Set<String> loadedFolders = const {},
      final Map<String, SelectionState> selectionStates = const {},
      final Set<String> selectedFilePaths = const {},
      final Map<String, int> tokenCounts = const {},
      this.currentFilter = const TreeFilter(),
      this.isLoading = false,
      this.isUpdatingSelection = false,
      final Map<String, bool> folderLoadingStates = const {},
      final Map<String, String> folderErrors = const {},
      this.rootPath,
      this.totalSelectedFiles = 0,
      this.totalTokens = 0})
      : _cachedFolders = cachedFolders,
        _filteredFolders = filteredFolders,
        _expandedFolders = expandedFolders,
        _loadedFolders = loadedFolders,
        _selectionStates = selectionStates,
        _selectedFilePaths = selectedFilePaths,
        _tokenCounts = tokenCounts,
        _folderLoadingStates = folderLoadingStates,
        _folderErrors = folderErrors,
        super._();

// Tree Data
  final Map<String, List<TreeEntry>> _cachedFolders;
// Tree Data
  @override
  @JsonKey()
  Map<String, List<TreeEntry>> get cachedFolders {
    if (_cachedFolders is EqualUnmodifiableMapView) return _cachedFolders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_cachedFolders);
  }

  final Map<String, List<TreeEntry>> _filteredFolders;
  @override
  @JsonKey()
  Map<String, List<TreeEntry>> get filteredFolders {
    if (_filteredFolders is EqualUnmodifiableMapView) return _filteredFolders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_filteredFolders);
  }

  final Set<String> _expandedFolders;
  @override
  @JsonKey()
  Set<String> get expandedFolders {
    if (_expandedFolders is EqualUnmodifiableSetView) return _expandedFolders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_expandedFolders);
  }

  final Set<String> _loadedFolders;
  @override
  @JsonKey()
  Set<String> get loadedFolders {
    if (_loadedFolders is EqualUnmodifiableSetView) return _loadedFolders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_loadedFolders);
  }

// Selection State (separated from tree data)
  final Map<String, SelectionState> _selectionStates;
// Selection State (separated from tree data)
  @override
  @JsonKey()
  Map<String, SelectionState> get selectionStates {
    if (_selectionStates is EqualUnmodifiableMapView) return _selectionStates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_selectionStates);
  }

  final Set<String> _selectedFilePaths;
  @override
  @JsonKey()
  Set<String> get selectedFilePaths {
    if (_selectedFilePaths is EqualUnmodifiableSetView)
      return _selectedFilePaths;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_selectedFilePaths);
  }

  final Map<String, int> _tokenCounts;
  @override
  @JsonKey()
  Map<String, int> get tokenCounts {
    if (_tokenCounts is EqualUnmodifiableMapView) return _tokenCounts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_tokenCounts);
  }

// Filter & Search
  @override
  @JsonKey()
  final TreeFilter currentFilter;
// UI State
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isUpdatingSelection;
  final Map<String, bool> _folderLoadingStates;
  @override
  @JsonKey()
  Map<String, bool> get folderLoadingStates {
    if (_folderLoadingStates is EqualUnmodifiableMapView)
      return _folderLoadingStates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_folderLoadingStates);
  }

  final Map<String, String> _folderErrors;
  @override
  @JsonKey()
  Map<String, String> get folderErrors {
    if (_folderErrors is EqualUnmodifiableMapView) return _folderErrors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_folderErrors);
  }

// Current Context
  @override
  final String? rootPath;
// Statistics
  @override
  @JsonKey()
  final int totalSelectedFiles;
  @override
  @JsonKey()
  final int totalTokens;

  @override
  String toString() {
    return 'FileTreeState(cachedFolders: $cachedFolders, filteredFolders: $filteredFolders, expandedFolders: $expandedFolders, loadedFolders: $loadedFolders, selectionStates: $selectionStates, selectedFilePaths: $selectedFilePaths, tokenCounts: $tokenCounts, currentFilter: $currentFilter, isLoading: $isLoading, isUpdatingSelection: $isUpdatingSelection, folderLoadingStates: $folderLoadingStates, folderErrors: $folderErrors, rootPath: $rootPath, totalSelectedFiles: $totalSelectedFiles, totalTokens: $totalTokens)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FileTreeStateImpl &&
            const DeepCollectionEquality()
                .equals(other._cachedFolders, _cachedFolders) &&
            const DeepCollectionEquality()
                .equals(other._filteredFolders, _filteredFolders) &&
            const DeepCollectionEquality()
                .equals(other._expandedFolders, _expandedFolders) &&
            const DeepCollectionEquality()
                .equals(other._loadedFolders, _loadedFolders) &&
            const DeepCollectionEquality()
                .equals(other._selectionStates, _selectionStates) &&
            const DeepCollectionEquality()
                .equals(other._selectedFilePaths, _selectedFilePaths) &&
            const DeepCollectionEquality()
                .equals(other._tokenCounts, _tokenCounts) &&
            (identical(other.currentFilter, currentFilter) ||
                other.currentFilter == currentFilter) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isUpdatingSelection, isUpdatingSelection) ||
                other.isUpdatingSelection == isUpdatingSelection) &&
            const DeepCollectionEquality()
                .equals(other._folderLoadingStates, _folderLoadingStates) &&
            const DeepCollectionEquality()
                .equals(other._folderErrors, _folderErrors) &&
            (identical(other.rootPath, rootPath) ||
                other.rootPath == rootPath) &&
            (identical(other.totalSelectedFiles, totalSelectedFiles) ||
                other.totalSelectedFiles == totalSelectedFiles) &&
            (identical(other.totalTokens, totalTokens) ||
                other.totalTokens == totalTokens));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_cachedFolders),
      const DeepCollectionEquality().hash(_filteredFolders),
      const DeepCollectionEquality().hash(_expandedFolders),
      const DeepCollectionEquality().hash(_loadedFolders),
      const DeepCollectionEquality().hash(_selectionStates),
      const DeepCollectionEquality().hash(_selectedFilePaths),
      const DeepCollectionEquality().hash(_tokenCounts),
      currentFilter,
      isLoading,
      isUpdatingSelection,
      const DeepCollectionEquality().hash(_folderLoadingStates),
      const DeepCollectionEquality().hash(_folderErrors),
      rootPath,
      totalSelectedFiles,
      totalTokens);

  /// Create a copy of FileTreeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FileTreeStateImplCopyWith<_$FileTreeStateImpl> get copyWith =>
      __$$FileTreeStateImplCopyWithImpl<_$FileTreeStateImpl>(this, _$identity);
}

abstract class _FileTreeState extends FileTreeState {
  const factory _FileTreeState(
      {final Map<String, List<TreeEntry>> cachedFolders,
      final Map<String, List<TreeEntry>> filteredFolders,
      final Set<String> expandedFolders,
      final Set<String> loadedFolders,
      final Map<String, SelectionState> selectionStates,
      final Set<String> selectedFilePaths,
      final Map<String, int> tokenCounts,
      final TreeFilter currentFilter,
      final bool isLoading,
      final bool isUpdatingSelection,
      final Map<String, bool> folderLoadingStates,
      final Map<String, String> folderErrors,
      final String? rootPath,
      final int totalSelectedFiles,
      final int totalTokens}) = _$FileTreeStateImpl;
  const _FileTreeState._() : super._();

// Tree Data
  @override
  Map<String, List<TreeEntry>> get cachedFolders;
  @override
  Map<String, List<TreeEntry>> get filteredFolders;
  @override
  Set<String> get expandedFolders;
  @override
  Set<String> get loadedFolders; // Selection State (separated from tree data)
  @override
  Map<String, SelectionState> get selectionStates;
  @override
  Set<String> get selectedFilePaths;
  @override
  Map<String, int> get tokenCounts; // Filter & Search
  @override
  TreeFilter get currentFilter; // UI State
  @override
  bool get isLoading;
  @override
  bool get isUpdatingSelection;
  @override
  Map<String, bool> get folderLoadingStates;
  @override
  Map<String, String> get folderErrors; // Current Context
  @override
  String? get rootPath; // Statistics
  @override
  int get totalSelectedFiles;
  @override
  int get totalTokens;

  /// Create a copy of FileTreeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FileTreeStateImplCopyWith<_$FileTreeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
