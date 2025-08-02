import 'package:context_for_ai/features/setting/model/app_setting.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/tree_filter.dart';

part 'tree_filter_model.freezed.dart';
part 'tree_filter_model.g.dart';

@freezed
class TreeFilterModel with _$TreeFilterModel {
  const factory TreeFilterModel({
    @Default([]) List<String> allowedExtensions,
    @Default(['.git', 'node_modules', '.DS_Store']) List<String> excludedFolders,
    @Default([]) List<String> excludedExtensions,
    @Default(false) bool showHiddenFiles,
    @Default('') String searchQuery,
  }) = _TreeFilterModel;

  const TreeFilterModel._();

  factory TreeFilterModel.fromJson(Map<String, dynamic> json) =>
      _$TreeFilterModelFromJson(json);

  /// Convert from domain entity
  factory TreeFilterModel.fromEntity(TreeFilter entity) {
    return TreeFilterModel(
      allowedExtensions: entity.allowedExtensions,
      excludedFolders: entity.excludedFolders,
      excludedExtensions: entity.excludedExtensions,
      showHiddenFiles: entity.showHiddenFiles,
      searchQuery: entity.searchQuery,
    );
  }

  /// Convert to domain entity
  TreeFilter toEntity() {
    return TreeFilter(
      allowedExtensions: allowedExtensions,
      excludedFolders: excludedFolders,
      excludedExtensions: excludedExtensions,
      showHiddenFiles: showHiddenFiles,
      searchQuery: searchQuery,
    );
  }

  /// Create from app settings
  factory TreeFilterModel.fromAppSettings({
    required AppSettings appSettings,
    List<String> allowedExtensions = const [],
    String searchQuery = '',
  }) {
    return TreeFilterModel(
      allowedExtensions: allowedExtensions,
      excludedFolders: appSettings.excludedNames,
      excludedExtensions: appSettings.excludedFileExtensions,
      showHiddenFiles: appSettings.showHiddenFiles,
      searchQuery: searchQuery,
    );
  }

  /// Merge with app settings to create global filter
  TreeFilterModel mergeWithAppSettings(AppSettings appSettings) {
    return copyWith(
      excludedFolders: appSettings.excludedNames,
      excludedExtensions: appSettings.excludedFileExtensions,
      showHiddenFiles: appSettings.showHiddenFiles,
    );
  }
}