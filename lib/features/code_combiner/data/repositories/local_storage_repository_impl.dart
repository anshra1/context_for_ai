import 'package:dartz/dartz.dart';
import 'package:context_for_ai/core/error/error_mapper.dart' show ErrorMapper;
import 'package:context_for_ai/core/typedefs/type.dart';
import 'package:context_for_ai/features/code_combiner/data/datasources/local_storage_data_source.dart';
import 'package:context_for_ai/features/code_combiner/data/models/app_settings.dart';
import 'package:context_for_ai/features/code_combiner/data/models/filter_settings.dart';
import 'package:context_for_ai/features/code_combiner/data/models/recent_workspace.dart';
import 'package:context_for_ai/features/code_combiner/domain/repositories/local_storage_repository.dart';

class LocalStorageRepositoryImpl implements LocalStorageRepository {
  LocalStorageRepositoryImpl(this.localStorageDataSource);

  final LocalStorageDataSource localStorageDataSource;

  @override
  ResultFuture<List<RecentWorkspace>> addRecentWorkspace(String workspacePath) async {
    try {
      final result = await localStorageDataSource.addRecentWorkspace(workspacePath);
      return Right(result);
    } on Exception catch (e) {
      return Left(ErrorMapper.mapErrorToFailure(e));
    }
  }

  @override
  ResultFuture<List<RecentWorkspace>> removeRecentWorkspace(String workspacePath) async {
    try {
      final result = await localStorageDataSource.removeRecentWorkspace(workspacePath);
      return Right(result);
    } on Exception catch (e) {
      return Left(ErrorMapper.mapErrorToFailure(e));
    }
  }

  @override
  ResultFuture<List<RecentWorkspace>> loadRecentWorkspaces() async {
    try {
      final result = await localStorageDataSource.loadRecentWorkspaces();
      return Right(result);
    } on Exception catch (e) {
      return Left(ErrorMapper.mapErrorToFailure(e));
    }
  }

  @override
  ResultFuture<List<RecentWorkspace>> clearRecentWorkspaces() async {
    try {
      final result = await localStorageDataSource.clearRecentWorkspaces();
      return Right(result);
    } on Exception catch (e) {
      return Left(ErrorMapper.mapErrorToFailure(e));
    }
  }

  @override
  ResultFuture<bool> saveFilterSettings(FilterSettings settings) async {
    try {
      final result = await localStorageDataSource.saveFilterSettings(settings);
      return Right(result);
    } on Exception catch (e) {
      return Left(ErrorMapper.mapErrorToFailure(e));
    }
  }

  @override
  ResultFuture<FilterSettings> loadFilterSettings() async {
    try {
      final result = await localStorageDataSource.loadFilterSettings();
      return Right(result);
    } on Exception catch (e) {
      return Left(ErrorMapper.mapErrorToFailure(e));
    }
  }

  @override
  ResultFuture<void> saveAppSettings(AppSettings settings) async {
    try {
      await localStorageDataSource.saveAppSettings(settings);
      return const Right(null);
    } on Exception catch (e) {
      return Left(ErrorMapper.mapErrorToFailure(e));
    }
  }

  @override
  ResultFuture<AppSettings> loadAppSettings() async {
    try {
      final result = await localStorageDataSource.loadAppSettings();
      return Right(result);
    } on Exception catch (e) {
      return Left(ErrorMapper.mapErrorToFailure(e));
    }
  }
}