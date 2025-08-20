import 'package:context_for_ai/core/error/error_mapper.dart' show ErrorMapper;
import 'package:context_for_ai/core/typedefs/type.dart';
import 'package:context_for_ai/features/code_combiner/data/datasources/file_system_data_source.dart';
import 'package:context_for_ai/features/code_combiner/data/models/export_preview.dart';
import 'package:context_for_ai/features/code_combiner/data/models/file_node.dart';
import 'package:context_for_ai/features/code_combiner/domain/repositories/file_system_repository.dart';
import 'package:dartz/dartz.dart';

class FileSystemRepositoryImpl implements FileSystemRepository {
  FileSystemRepositoryImpl(this.fileSystemDataSource);

  final FileSystemDataSource fileSystemDataSource;

  @override
  ResultFuture<Map<String, FileNode>> scanDirectory(String directoryPath) async {
    try {
      final result = await fileSystemDataSource.scanDirectory(directoryPath);
      return Right(result);
    } on Exception catch (e) {
      return Left(ErrorMapper.mapErrorToFailure(e));
    }
  }

  @override
  ResultFuture<String> readFileContent(String filePath) async {
    try {
      final result = await fileSystemDataSource.readFileContent(filePath);
      return Right(result);
    } on Exception catch (e) {
      return Left(ErrorMapper.mapErrorToFailure(e));
    }
  }

  @override
  ResultFuture<ExportPreview> combineAndExportFiles(List<String> filePaths) async {
    try {
      final result = await fileSystemDataSource.combineAndExportFiles(filePaths);
      return Right(result);
    } on Exception catch (e) {
      return Left(ErrorMapper.mapErrorToFailure(e));
    }
  }
}
