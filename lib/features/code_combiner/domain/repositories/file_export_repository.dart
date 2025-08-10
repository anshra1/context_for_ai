abstract class FileExportRepository {
  Future<void> writeToFile(String filePath, String content);
  Future<List<String>> writeSplitFiles(String baseFilePath, String content, int splitSizeInMB);
  Future<String?> pickSaveLocation(String defaultFileName);
  Future<bool> isDirectoryWritable(String directoryPath);
  Future<int> getAvailableSpace(String directoryPath);
}