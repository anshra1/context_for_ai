import 'package:context_for_ai/core/typedefs/type.dart';
import 'package:context_for_ai/features/code_combiner/data/models/app_settings.dart';
import 'package:context_for_ai/features/code_combiner/data/models/filter_settings.dart';
import 'package:context_for_ai/features/code_combiner/data/models/recent_workspace.dart';

abstract class LocalStorageRepository {
  ResultFuture<List<RecentWorkspace>> addRecentWorkspace(String workspacePath);

  ResultFuture<List<RecentWorkspace>> removeRecentWorkspace(String workspacePath);

  ResultFuture<List<RecentWorkspace>> loadRecentWorkspaces();

  ResultFuture<List<RecentWorkspace>> clearRecentWorkspaces();

  ResultFuture<bool> saveFilterSettings(FilterSettings settings);

  ResultFuture<FilterSettings> loadFilterSettings();

  ResultFuture<void> saveAppSettings(AppSettings settings);

  ResultFuture<AppSettings> loadAppSettings();
}
