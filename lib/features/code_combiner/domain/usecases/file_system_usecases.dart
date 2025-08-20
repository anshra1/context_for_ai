import 'package:context_for_ai/core/typedefs/type.dart';
import 'package:context_for_ai/core/usecase/usecase.dart';
import 'package:context_for_ai/features/code_combiner/data/models/export_preview.dart';
import 'package:context_for_ai/features/code_combiner/data/models/file_node.dart';
import 'package:context_for_ai/features/code_combiner/domain/repositories/file_system_repository.dart';

class ScanDirectory extends FutureUseCaseWithParams<Map<String, FileNode>, String> {
  ScanDirectory({required this.fileSystemRepository});

  final FileSystemRepository fileSystemRepository;

  @override
  ResultFuture<Map<String, FileNode>> call(String directoryPath) {
    return fileSystemRepository.scanDirectory(directoryPath);
  }
}

class ReadFileContent extends FutureUseCaseWithParams<String, String> {
  ReadFileContent({required this.fileSystemRepository});

  final FileSystemRepository fileSystemRepository;

  @override
  ResultFuture<String> call(String filePath) {
    return fileSystemRepository.readFileContent(filePath);
  }
}

class CombineAndExportFiles extends FutureUseCaseWithParams<ExportPreview, List<String>> {
  CombineAndExportFiles({required this.fileSystemRepository});

  final FileSystemRepository fileSystemRepository;

  @override
  ResultFuture<ExportPreview> call(List<String> filePaths) {
    return fileSystemRepository.combineAndExportFiles(filePaths);
  }
}