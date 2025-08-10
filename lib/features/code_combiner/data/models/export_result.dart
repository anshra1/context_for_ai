class ExportResult {
  final bool success;
  final int totalFiles;
  final int successfulFiles;
  final int failedFiles;
  final List<String> failedFilePaths;
  final String? exportPath;
  final String? errorMessage;
  
  ExportResult({
    required this.success,
    required this.totalFiles,
    required this.successfulFiles,
    required this.failedFiles,
    required this.failedFilePaths,
    this.exportPath,
    this.errorMessage,
  });
}