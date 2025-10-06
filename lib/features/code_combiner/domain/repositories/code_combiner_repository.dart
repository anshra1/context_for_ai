import 'package:context_for_ai/core/typedefs/type.dart';
import 'package:context_for_ai/features/code_combiner/data/models/app_settings.dart';
import 'package:context_for_ai/features/code_combiner/data/models/export_preview.dart';
import 'package:context_for_ai/features/code_combiner/data/models/file_node.dart';
import 'package:context_for_ai/features/code_combiner/data/models/filter_settings.dart';
import 'package:context_for_ai/features/code_combiner/data/models/recent_workspace.dart';

/// Single repository for all Code Combiner operations
/// Coordinates file system and local storage operations as one cohesive feature
abstract class CodeCombinerRepository {
  // ==================== Workspace Management ====================
  
  /// Open directory tree: scan directory + update recent workspaces + load settings
  ResultFuture<WorkspaceData> openDirectoryTree(String directoryPath);
  
  /// Get recent workspaces with validation
  ResultFuture<List<RecentWorkspace>> getRecentWorkspaces();
  
  /// Remove workspace from recent list
  ResultFuture<List<RecentWorkspace>> removeRecentWorkspace(String workspacePath);
  
  /// Clear all recent workspaces  
  ResultFuture<List<RecentWorkspace>> clearRecentWorkspaces();

  // ==================== File Operations ====================
  
  /// Read single file content with validation
  ResultFuture<String> readFileContent(String filePath);
  
  /// Export files workflow: read + combine + export + update settings
  ResultFuture<ExportPreview> exportFiles(List<String> filePaths);

  // ==================== Settings Management ====================
  
  /// Load user filter settings
  ResultFuture<FilterSettings> getFilterSettings();
  
  /// Save filter settings
  ResultFuture<bool> saveFilterSettings(FilterSettings settings);
  
  /// Load application settings
  ResultFuture<AppSettings> getAppSettings();
  
  /// Save application settings
  ResultFuture<void> saveAppSettings(AppSettings settings);
}

/// Data transfer object for workspace operations
class WorkspaceData {
  const WorkspaceData({
    required this.fileTree,
    required this.appSettings,
    required this.filterSettings,
    required this.workspacePath,
  });

  final Map<String, FileNode> fileTree;
  final AppSettings appSettings;
  final FilterSettings filterSettings;  
  final String workspacePath;
}