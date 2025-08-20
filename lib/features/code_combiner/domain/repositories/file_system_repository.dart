import 'package:context_for_ai/core/typedefs/type.dart';
import 'package:context_for_ai/features/code_combiner/data/models/export_preview.dart';
import 'package:context_for_ai/features/code_combiner/data/models/file_node.dart';

abstract class FileSystemRepository {
  ResultFuture<Map<String, FileNode>> scanDirectory(String directoryPath);

  ResultFuture<String> readFileContent(String filePath);

  ResultFuture<ExportPreview> combineAndExportFiles(List<String> filePaths);
}