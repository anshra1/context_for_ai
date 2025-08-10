import '../../data/models/file_node.dart';

abstract class FileSystemRepository {
  Future<Map<String, FileNode>> scanDirectory(String directoryPath);
  Future<String> readFileContent(String filePath);
  Future<Map<String, String>> readMultipleFiles(List<String> filePaths);
  Future<bool> isAccessible(String path);
  Future<int> getFileSize(String filePath);
  bool isBinaryFile(String filePath);
  Future<String?> pickDirectory();
  Future<bool> isValidDirectory(String path);
}