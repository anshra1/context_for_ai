// Last Edited: 2025-08-11 15:30:00
// Edit History: 
//      - 2025-08-11 15:30:00: Added defaults() factory constructor with 
//        comprehensive filter settings - Purpose: Move domain logic to model
//        and provide sensible defaults for new installations
//      - 2025-08-11 14:39:15: Applied 80-character line limit to edit 
//        comments - Purpose: Improve readability and maintain consistent 
//        formatting
//      - 2025-08-11 14:36:15: Converted to Freezed model with JSON 
//        serialization - Purpose: Eliminate boilerplate code and enable 
//        persistent storage

import 'package:freezed_annotation/freezed_annotation.dart';

part 'filter_settings.freezed.dart';
part 'filter_settings.g.dart';

@freezed
class FilterSettings with _$FilterSettings {
  const factory FilterSettings({
    required Set<String> blockedExtensions,
    required Set<String> blockedFilePaths,
    required Set<String> blockedFileNames,
    required Set<String> blockedFolderNames,
    required int maxFileSizeInMB,
    required bool includeHiddenFiles,
    required Set<String> allowedExtensions,
    
  }) = _FilterSettings;

  factory FilterSettings.fromJson(Map<String, dynamic> json) =>
      _$FilterSettingsFromJson(json);

  /// Factory constructor providing sensible default filter settings for new installations
  factory FilterSettings.defaults() {
    return const FilterSettings(
      blockedExtensions: {
        '.exe', '.dll', '.so', '.dylib', '.a', '.lib',
        '.png', '.jpg', '.jpeg', '.gif', '.bmp', '.ico', '.svg',
        '.mp4', '.mp3', '.wav', '.avi', '.mov',
        '.zip', '.tar', '.gz', '.rar', '.7z',
        '.pdf', '.doc', '.docx', '.ppt', '.pptx',
        '.lock', '.tmp', '.cache', '.log',
      },
      blockedFilePaths: {},
      blockedFileNames: {
        'package-lock.json', 'yarn.lock',
        '.DS_Store', 'Thumbs.db',
        '.env', '.env.local', '.env.production',
      },
      blockedFolderNames: {
        'node_modules', '.git', '.svn', '.hg',
        'build', 'dist', 'out', 'target',
        '.dart_tool', '.packages', '.pub-cache',
        'android/build', 'ios/build', 'web/build',
        '.idea', '.vscode', '.vs',
        '__pycache__', '.pytest_cache',
        'vendor', 'composer.lock',
      },
      maxFileSizeInMB: 10,
      includeHiddenFiles: false,
      allowedExtensions: {},
     
    );
  }
}

/*











*/