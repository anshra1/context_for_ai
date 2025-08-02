import 'dart:io';

import 'package:context_for_ai/core/typedefs/type.dart';
import 'package:context_for_ai/features/file_combiner/data/datasource/combiner_data_source.dart';
import 'package:context_for_ai/features/file_combiner/domain/entity/file_system_entry.dart';
import 'package:context_for_ai/features/file_combiner/domain/entity/workspace_entry.dart';

abstract class CombinerRepository {
  ResultFuture<List<WorkspaceEntry>> loadFolderHistory();
  ResultFuture<void> saveToRecentWorkspaces(String path);
  ResultFuture<void> removeFromRecent(String path);
  ResultFuture<void> markAsFavorite(String path);
  ResultFuture<List<FileSystemEntry>> fetchFolderContents(
    String folderPath, {
    List<String>? allowedExtensions,
  });
  ResultFuture<CombineFilesResult> combineFiles(List<String> filePaths);
}