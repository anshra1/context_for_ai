import 'dart:io';

import 'package:context_for_ai/core/typedefs/type.dart';
import 'package:context_for_ai/core/usecase/usecase.dart';
import 'package:context_for_ai/file_combiner/domain/entity/file_system_entry.dart';
import 'package:context_for_ai/file_combiner/domain/entity/workspace_entry.dart';
import 'package:context_for_ai/file_combiner/domain/repository/combiner_repository.dart';

class LoadWorkspaceHistory extends FutureUseCaseWithoutParams<List<WorkspaceEntry>> {
  LoadWorkspaceHistory({required this.repository});

  final CombinerRepository repository;

  @override
  ResultFuture<List<WorkspaceEntry>> call() {
    return repository.loadFolderHistory();
  }
}

class SaveWorkspace extends FutureUseCaseWithParams<void, SaveWorkspaceParams> {
  SaveWorkspace({required this.repository});

  final CombinerRepository repository;

  @override
  ResultFuture<void> call(SaveWorkspaceParams params) {
    return repository.saveToRecentWorkspaces(params.path);
  }
}

class SaveWorkspaceParams {
  SaveWorkspaceParams({required this.path});
  final String path;
}

class RemoveWorkspace extends FutureUseCaseWithParams<void, RemoveWorkspaceParams> {
  RemoveWorkspace({required this.repository});

  final CombinerRepository repository;

  @override
  ResultFuture<void> call(RemoveWorkspaceParams params) {
    return repository.removeFromRecent(params.path);
  }
}

class RemoveWorkspaceParams {
  RemoveWorkspaceParams({required this.path});
  final String path;
}

class ToggleFavorite extends FutureUseCaseWithParams<void, ToggleFavoriteParams> {
  ToggleFavorite({required this.repository});

  final CombinerRepository repository;

  @override
  ResultFuture<void> call(ToggleFavoriteParams params) {
    return repository.markAsFavorite(params.path);
  }
}

class ToggleFavoriteParams {
  ToggleFavoriteParams({required this.path});
  final String path;
}

class BrowseFolderContents extends FutureUseCaseWithParams<List<FileSystemEntry>, BrowseFolderContentsParams> {
  BrowseFolderContents({required this.repository});

  final CombinerRepository repository;

  @override
  ResultFuture<List<FileSystemEntry>> call(BrowseFolderContentsParams params) {
    return repository.fetchFolderContents(
      params.folderPath,
      allowedExtensions: params.allowedExtensions,
    );
  }
}

class BrowseFolderContentsParams {
  BrowseFolderContentsParams({
    required this.folderPath,
    this.allowedExtensions,
  });
  final String folderPath;
  final List<String>? allowedExtensions;
}

class CombineFiles extends FutureUseCaseWithParams<File, CombineFilesParams> {
  CombineFiles({required this.repository});

  final CombinerRepository repository;

  @override
  ResultFuture<File> call(CombineFilesParams params) {
    return repository.combineFiles(params.filePaths);
  }
}

class CombineFilesParams {
  CombineFilesParams({required this.filePaths});
  final List<String> filePaths;
}