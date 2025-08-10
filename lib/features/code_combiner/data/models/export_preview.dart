class ExportPreview {
  final int selectedFileCount;
  final int estimatedTokenCount;
  final double estimatedSizeInMB;
  final int estimatedPartsCount;
  final List<String> selectedFilePaths;
  final bool willExceedTokenLimit;
  
  ExportPreview({
    required this.selectedFileCount,
    required this.estimatedTokenCount,
    required this.estimatedSizeInMB,
    required this.estimatedPartsCount,
    required this.selectedFilePaths,
    required this.willExceedTokenLimit,
  });
}