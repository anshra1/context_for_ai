import '../../data/models/recent_workspace.dart';
import '../../data/models/filter_settings.dart';
import '../../data/models/app_settings.dart';

abstract class LocalStorageRepository {
  Future<void> initialize();
  Future<void> saveRecentWorkspaces(List<RecentWorkspace> workspaces);
  Future<List<RecentWorkspace>> loadRecentWorkspaces();
  Future<void> saveFilterSettings(FilterSettings settings);
  Future<FilterSettings> loadFilterSettings();
  Future<void> saveAppSettings(AppSettings settings);
  Future<AppSettings> loadAppSettings();
}