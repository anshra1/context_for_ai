import 'dart:io';

import 'package:context_for_ai/core/error/error_mapper.dart';
import 'package:context_for_ai/core/typedefs/type.dart';
import 'package:context_for_ai/file_combiner/data/datasource/combiner_data_source.dart';
import 'package:context_for_ai/file_combiner/domain/entity/file_system_entry.dart';
import 'package:context_for_ai/file_combiner/domain/entity/workspace_entry.dart';
import 'package:context_for_ai/file_combiner/domain/repository/combiner_repository.dart';
import 'package:dartz/dartz.dart';

class CombinerRepositoryImpl implements CombinerRepository {
  CombinerRepositoryImpl(this.dataSource);

  final CombinerDataSource dataSource;

  @override
  ResultFuture<List<WorkspaceEntry>> loadFolderHistory() async {
    try {
      final result = await dataSource.loadFolderHistory();
      return Right(result);
    } on Exception catch (e) {
      return Left(ErrorMapper.mapErrorToFailure(e));
    }
  }

  @override
  ResultFuture<void> saveToRecentWorkspaces(String path) async {
    try {
      final result = await dataSource.saveToRecentWorkspaces(path);
      return Right(result);
    } on Exception catch (e) {
      return Left(ErrorMapper.mapErrorToFailure(e));
    }
  }

  @override
  ResultFuture<void> removeFromRecent(String path) async {
    try {
      final result = await dataSource.removeFromRecent(path);
      return Right(result);
    } on Exception catch (e) {
      return Left(ErrorMapper.mapErrorToFailure(e));
    }
  }

  @override
  ResultFuture<void> markAsFavorite(String path) async {
    try {
      final result = await dataSource.markAsFavorite(path);
      return Right(result);
    } on Exception catch (e) {
      return Left(ErrorMapper.mapErrorToFailure(e));
    }
  }

  @override
  ResultFuture<List<FileSystemEntry>> fetchFolderContents(
    String folderPath, {
    List<String>? allowedExtensions,
  }) async {
    try {
      final result = await dataSource.fetchFolderContents(
        folderPath,
        allowedExtensions: allowedExtensions,
      );
      return Right(result);
    } on Exception catch (e) {
      return Left(ErrorMapper.mapErrorToFailure(e));
    }
  }

  @override
  ResultFuture<File> combineFiles(List<String> filePaths) async {
    try {
      final result = await dataSource.combineFiles(filePaths);
      return Right(result);
    } on Exception catch (e) {
      return Left(ErrorMapper.mapErrorToFailure(e));
    }
  }
}