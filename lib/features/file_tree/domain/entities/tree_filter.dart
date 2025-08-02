import 'package:freezed_annotation/freezed_annotation.dart';
import 'tree_entry.dart';

part 'tree_filter.freezed.dart';

@freezed
class TreeFilter with _$TreeFilter {
  const factory TreeFilter({
    @Default([]) List<String> allowedExtensions,
    @Default(['.git', 'node_modules', '.DS_Store']) List<String> excludedFolders,
    @Default([]) List<String> excludedExtensions,
    @Default(false) bool showHiddenFiles,
    @Default('') String searchQuery,
  }) = _TreeFilter;

}