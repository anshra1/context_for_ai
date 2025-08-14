class FileExportDataSource {
  FileExportDataSource();

  Future<void> writeToFile(String filePath, String content) async {
    throw UnimplementedError();
  }

  Future<void> _ensureDirectoryExists(String filePath) async {
    throw UnimplementedError();
  }

  bool _isValidFileName(String fileName) {
    throw UnimplementedError();
  }

  Future<bool> _hasWritePermission(String directoryPath) async {
    throw UnimplementedError();
  }

  Future<List<String>> writeSplitFiles(
    String baseFilePath,
    String content,
    int splitSizeInMB,
  ) async {
    throw UnimplementedError();
  }

  List<String> _splitContentBySize(String content, int splitSizeInMB) {
    throw UnimplementedError();
  }

  String _generatePartFileName(String baseFilePath, int partNumber) {
    throw UnimplementedError();
  }

  int _calculateTotalParts(String content, int splitSizeInMB) {
    throw UnimplementedError();
  }

  Future<String?> pickSaveLocation(String defaultFileName) async {
    throw UnimplementedError();
  }

  String _getDefaultDirectory() {
    throw UnimplementedError();
  }

  String _sanitizeFileName(String fileName) {
    throw UnimplementedError();
  }

  Future<bool> isDirectoryWritable(String directoryPath) async {
    throw UnimplementedError();
  }

  Future<bool> _testWritePermission(String directoryPath) async {
    throw UnimplementedError();
  }

  bool _directoryExists(String directoryPath) {
    throw UnimplementedError();
  }

  Future<int> getAvailableSpace(String directoryPath) async {
    throw UnimplementedError();
  }

  int _convertBytesToMB(int bytes) {
    throw UnimplementedError();
  }

  Future<int> _getDiskSpaceForPath(String path) async {
    throw UnimplementedError();
  }
}
