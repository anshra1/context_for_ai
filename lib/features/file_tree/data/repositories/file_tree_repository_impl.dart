import 'package:context_for_ai/core/error/error_mapper.dart';
import 'package:context_for_ai/core/error/exception.dart';
import 'package:context_for_ai/core/error/failure.dart';
import 'package:context_for_ai/core/typedefs/type.dart';
import 'package:context_for_ai/features/file_tree/data/datasources/file_tree_data_source.dart';
import 'package:context_for_ai/features/file_tree/domain/entities/tree_entry.dart';
import 'package:context_for_ai/features/file_tree/domain/entities/tree_filter.dart';
import 'package:context_for_ai/features/file_tree/domain/repositories/file_tree_repository.dart';
import 'package:dartz/dartz.dart';

class FileTreeRepositoryImpl implements FileTreeRepository {
  const FileTreeRepositoryImpl({
    required this.dataSource,
  });
  final FileTreeDataSource dataSource;

  @override
  ResultFuture<List<TreeEntry>> loadFolderContents(String folderPath) async {
    try {
      final modelsResult = await dataSource.loadFolderContents(folderPath);
      final entities = modelsResult.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on AppException catch (e) {
      return Left(ErrorMapper.mapErrorToFailure(e));
    } catch (e) {
      return Left(ErrorMapper.mapErrorToFailure(e));
    }
  }

  @override
  ResultFuture<List<TreeEntry>> loadFilteredFolderContents(
    String folderPath,
    TreeFilter filter,
  ) async {
    try {
      final modelsResult = await dataSource.loadFilteredFolderContents(folderPath, filter);
      final entities = modelsResult.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on AppException catch (e) {
      return Left(ErrorMapper.mapErrorToFailure(e));
    } catch (e) {
      return Left(ErrorMapper.mapErrorToFailure(e));
    }
  }

  @override
  ResultFuture<List<TreeEntry>> applyFilter(
    List<TreeEntry> entries,
    TreeFilter filter,
  ) async {
    try {
      // Since filtering is now done in data source, this method can be simplified
      // For backward compatibility, we can still provide this method
      // but in practice, use loadFilteredFolderContents for better performance
      final dataSource = this.dataSource;
      
      // We need the folder path to use the filtered method
      // For now, return the entries as-is since filtering should be done at load time
      return Right(entries);
    } catch (e) {
      return Left(ErrorMapper.mapErrorToFailure(e));
    }
  }

  @override
  ResultFuture<int> calculateTokenCount(String filePath) async {
    try {
      final tokenCount = await dataSource.calculateTokenCount(filePath);
      return Right(tokenCount);
    } catch (e) {
      return Left(ErrorMapper.mapErrorToFailure(e));
    }
  }

  @override
  ResultFuture<bool> checkFileReadability(String filePath) async {
    try {
      final isReadable = await dataSource.checkFileReadability(filePath);
      return Right(isReadable);
    } catch (e) {
      return Left(ErrorMapper.mapErrorToFailure(e));
    }
  }

  @override
  ResultFuture<TreeFilter> getGlobalFilter() async {
    try {
      final filterModel = await dataSource.getGlobalFilter();
      final filterEntity = filterModel.toEntity();
      return Right(filterEntity);
    } catch (e) {
      return Left(ErrorMapper.mapErrorToFailure(e));
    }
  }

  @override
  ResultFuture<bool> validatePath(String path) async {
    try {
      final isValid = await dataSource.validatePath(path);
      return Right(isValid);
    } catch (e) {
      return Left(ErrorMapper.mapErrorToFailure(e));
    }
  }
}
