class FilterSettings {
  final Set<String> blockedExtensions;
  final Set<String> blockedFilePaths;
  final Set<String> blockedFileNames;
  final Set<String> blockedFolderNames;
  final int maxFileSizeInMB;
  final bool includeHiddenFiles;
  final Set<String> allowedExtensions;
  final bool enablePositiveFiltering;
  
  FilterSettings({
    required this.blockedExtensions,
    required this.blockedFilePaths,
    required this.blockedFileNames, 
    required this.blockedFolderNames,
    required this.maxFileSizeInMB,
    required this.includeHiddenFiles,
    required this.allowedExtensions,
    required this.enablePositiveFiltering,
  });
  
  FilterSettings copyWith({
    Set<String>? blockedExtensions,
    Set<String>? blockedFilePaths,
    Set<String>? blockedFileNames,
    Set<String>? blockedFolderNames,
    int? maxFileSizeInMB,
    bool? includeHiddenFiles,
    Set<String>? allowedExtensions,
    bool? enablePositiveFiltering,
  }) {
    return FilterSettings(
      blockedExtensions: blockedExtensions ?? this.blockedExtensions,
      blockedFilePaths: blockedFilePaths ?? this.blockedFilePaths,
      blockedFileNames: blockedFileNames ?? this.blockedFileNames,
      blockedFolderNames: blockedFolderNames ?? this.blockedFolderNames,
      maxFileSizeInMB: maxFileSizeInMB ?? this.maxFileSizeInMB,
      includeHiddenFiles: includeHiddenFiles ?? this.includeHiddenFiles,
      allowedExtensions: allowedExtensions ?? this.allowedExtensions,
      enablePositiveFiltering: enablePositiveFiltering ?? this.enablePositiveFiltering,
    );
  }
}