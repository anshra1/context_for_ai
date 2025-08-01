import 'dart:io' as io;

import 'package:context_for_ai/core/error/exception.dart';
import 'package:context_for_ai/features/file_combiner/domain/entity/file_system_entry.dart';
import 'package:context_for_ai/features/file_combiner/domain/entity/workspace_entry.dart';
import 'package:context_for_ai/features/file_combiner/domain/hive_model/workspace_entry_hive.dart';
import 'package:context_for_ai/features/setting/data/datasource/setting_datasource.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class CombineFilesResult {
  const CombineFilesResult({
    required this.files,
    required this.totalFiles,
    required this.totalTokens,
    required this.saveLocation,
  });

  final List<io.File> files;
  final int totalFiles;
  final int totalTokens;
  final String saveLocation;
}

abstract class CombinerDataSource {
  Future<List<WorkspaceEntry>> loadFolderHistory();
  Future<void> saveToRecentWorkspaces(String path);
  Future<void> removeFromRecent(String path);
  Future<void> markAsFavorite(String path);
  Future<List<FileSystemEntry>> fetchFolderContents(
    String folderPath, {
    List<String>? allowedExtensions,
  });
  Future<CombineFilesResult> combineFiles(List<String> filePaths);
}

class CombinerDataSourceImpl implements CombinerDataSource {
  // Value constructor for easy testing
  const CombinerDataSourceImpl({
    required Box<WorkspaceEntryHive> workspaceBox,
    required SettingsDataSource settingsDataSource,
  }) : _workspaceBox = workspaceBox,
       _settingsDataSource = settingsDataSource;

  final Box<WorkspaceEntryHive> _workspaceBox;
  final SettingsDataSource _settingsDataSource;

  @override
  Future<List<WorkspaceEntry>> loadFolderHistory() async {
    // 1. Get reference to the injected workspace box
    final box = _workspaceBox;

    // 2. Check if the box is open, if not throw an exception
    if (!box.isOpen) {
      throw const StorageException(
        userMessage: 'Workspace history storage is not available',
        methodName: 'loadFolderHistory',
        originalError: 'Hive box is not open',
        title: 'Storage Error',
        isRecoverable: false,
      );
    }

    // 3. If no entries exist, return empty list
    if (box.isEmpty) {
      return <WorkspaceEntry>[];
    }

    // 4. Retrieve all values and convert them to WorkspaceEntry objects
    final entries = <WorkspaceEntry>[];

    for (final hiveEntry in box.values) {
      entries.add(hiveEntry.toEntity());
    }

    // 5. Sort entries: favorites first, then by last accessed (newest first)
    entries.sort((a, b) {
      if (a.isFavorite && !b.isFavorite) return -1;
      if (!a.isFavorite && b.isFavorite) return 1;
      return b.lastAccessedAt.compareTo(a.lastAccessedAt);
    });

    // 6. Return the sorted list
    return entries;
  }

  @override
  Future<void> markAsFavorite(String path) async {
    // 1. Validate input path
    if (path.isEmpty || path.trim().isEmpty) {
      throw ValidationException(
        userMessage: 'Workspace path cannot be null or empty',
        methodName: 'markAsFavorite',
        originalError: 'Invalid path provided: $path',
        title: 'Invalid Path',
        isRecoverable: false,
      );
    }

    // 2. Get reference to the Hive box for workspace entries
    final box = _workspaceBox;

    // 3. Check if the box is open, if not throw an exception
    if (!box.isOpen) {
      throw const StorageException(
        userMessage: 'Workspace history storage is not available',
        methodName: 'markAsFavorite',
        originalError: 'Hive box is not open',
        title: 'Storage Error',
        isRecoverable: false,
      );
    }

    try {
      // 4. Find entry with matching path
      String? keyToFavorite;
      WorkspaceEntryHive? entryToFavorite;

      for (final entry in box.toMap().entries) {
        try {
          final workspaceEntry = entry.value;
          if (workspaceEntry.path == path) {
            keyToFavorite = entry.key as String;
            entryToFavorite = workspaceEntry;
            break;
          }
        } on Exception catch (_) {
          // Skip invalid entries
          continue;
        }
      }

      // 5. If found: mark as favorite and update timestamp
      if (entryToFavorite != null && keyToFavorite != null) {
        final updatedEntry = WorkspaceEntryHive(
          uuid: entryToFavorite.uuid,
          path: entryToFavorite.path,
          isFavorite: true, // Mark as favorite
          lastAccessedAt: DateTime.now(),
          // Update timestamp
        );

        await box.put(keyToFavorite, updatedEntry);
      }
      // 6. If not found: throw WorkspaceNotFoundException
      else {
        throw StorageException(
          userMessage: 'Workspace not found in recent history',
          methodName: 'markAsFavorite',
          originalError: 'No workspace found with path: $path',
          title: 'Workspace Not Found',
          debugDetails: 'Path: $path',
          isRecoverable: false,
        );
      }
    } catch (e, stack) {
      // 8. Handle errors appropriately
      // If it's already our custom exception, rethrow it
      if (e is AppException) {
        rethrow;
      }

      throw StorageException(
        userMessage: 'Failed to mark workspace as favorite',
        methodName: 'markAsFavorite',
        originalError: e.toString(),
        title: 'Storage Error',
        debugDetails: 'Path: $path',
        stackTrace: stack.toString(),
      );
    }
  }

  @override
  Future<void> saveToRecentWorkspaces(String path) async {
    // 1. Validate input path
    if (path.isEmpty) {
      throw const ValidationException(
        userMessage: 'Workspace path cannot be empty',
        methodName: 'saveToRecentWorkspaces',
        originalError: 'Empty path provided',
        title: 'Invalid Path',
        isRecoverable: false,
      );
    }

    // 2. Get reference to the Hive box for workspace entries
    final box = _workspaceBox;

    // 3. Check if the box is open, if not throw an exception
    if (!box.isOpen) {
      throw const StorageException(
        userMessage: 'Workspace history storage is not available',
        methodName: 'saveToRecentWorkspaces',
        originalError: 'Hive box is not open',
        title: 'Storage Error',
        isRecoverable: false,
      );
    }

    try {
      // 4. Check if path already exists in the box
      WorkspaceEntryHive? existingEntry;

      for (final entry in box.values) {
        if (entry.path == path) {
          existingEntry = entry;
          break;
        }
      }

      if (existingEntry != null) {
        // 5. If exists: update timestamp only
        final updatedEntry = WorkspaceEntryHive(
          uuid: existingEntry.uuid,
          path: existingEntry.path,
          isFavorite: existingEntry.isFavorite,
          lastAccessedAt: DateTime.now(),
        );
        await box.put(updatedEntry.uuid, updatedEntry);
      } else {
        // 6. If not exists: create new entry

        final newEntry = WorkspaceEntryHive(
          uuid: const Uuid().v4(),
          path: path,
          isFavorite: false,
          lastAccessedAt: DateTime.now(),
        );

        await box.put(newEntry.uuid, newEntry);
      }
    } catch (e, stack) {
      // 7. Handle errors appropriately
      throw StorageException(
        userMessage: 'Failed to save workspace to recent history',
        methodName: 'saveToRecentWorkspaces',
        originalError: e.toString(),
        title: 'Storage Error',
        debugDetails: 'Path: $path',
        stackTrace: stack.toString(),
      );
    }
  }

  @override
  Future<void> removeFromRecent(String path) async {
    // 1. Validate input path
    if (path.isEmpty || path.trim().isEmpty) {
      throw ValidationException(
        userMessage: 'Workspace path cannot be null or empty',
        methodName: 'removeFromRecent',
        originalError: 'Invalid path provided: $path',
        title: 'Invalid Path',
        isRecoverable: false,
      );
    }

    // 2. Get reference to the Hive box for workspace entries
    final box = _workspaceBox;

    // 3. Check if the box is open, if not throw an exception
    if (!box.isOpen) {
      throw const StorageException(
        userMessage: 'Workspace history storage is not available',
        methodName: 'removeFromRecent',
        originalError: 'Hive box is not open',
        title: 'Storage Error',
        isRecoverable: false,
      );
    }

    try {
      // 4. Find entry with matching path
      String? keyToRemove;

      for (final entry in box.toMap().entries) {
        try {
          final workspaceEntry = entry.value;
          if (workspaceEntry.path == path) {
            keyToRemove = entry.key as String;
            break;
          }
        } on Exception catch (_) {
          // Skip invalid entries
          continue;
        }
      }

      // 5. If found: remove it from Hive
      if (keyToRemove != null) {
        await box.delete(keyToRemove);
      }
      // 6. If not found: silently return (no-op)
    } catch (e, stack) {
      // 7. Handle errors appropriately
      throw StorageException(
        userMessage: 'Failed to remove workspace from recent history',
        methodName: 'removeFromRecent',
        originalError: e.toString(),
        title: 'Storage Error',
        debugDetails: 'Path: $path',
        stackTrace: stack.toString(),
      );
    }
  }

  @override
  Future<List<FileSystemEntry>> fetchFolderContents(
    String folderPath, {
    List<String>? allowedExtensions,
  }) async {
    // 1. Validate input folderPath
    if (folderPath.isEmpty || folderPath.trim().isEmpty) {
      throw ValidationException(
        userMessage: 'Folder path cannot be null or empty',
        methodName: 'fetchFolderContents',
        originalError: 'Invalid folder path provided: $folderPath',
        title: 'Invalid Path',
        isRecoverable: false,
      );
    }

    try {
      // 2. Access Directory at folderPath
      final directory = io.Directory(folderPath);

      // 3. Check if directory exists and is readable
      final exists = await directory.exists();
      if (!exists) {
        throw StorageException(
          userMessage: 'The specified folder does not exist',
          methodName: 'fetchFolderContents',
          originalError: 'Path not found: $folderPath',
          title: 'Folder Not Found',
          debugDetails: 'Path: $folderPath',
          isRecoverable: false,
        );
      }

      // Check readability (attempt to list, which will fail if not readable)
      await directory.list().take(1).toList();
    } on io.FileSystemException catch (e, stack) {
      // This catches permission denied and other file system errors
      if (e.osError?.errorCode == 13 || e.message.toLowerCase().contains('permission')) {
        throw StorageException(
          userMessage: 'Permission denied. Cannot access the folder',
          methodName: 'fetchFolderContents',
          originalError: e.message,
          title: 'Permission Denied',
          debugDetails: 'Path: $folderPath',
          stackTrace: stack.toString(),
          isRecoverable: false,
        );
      } else {
        throw StorageException(
          userMessage: 'Failed to access the folder',
          methodName: 'fetchFolderContents',
          originalError: e.message,
          title: 'File System Error',
          debugDetails: 'Path: $folderPath',
          stackTrace: stack.toString(),
        );
      }
    } catch (e, stack) {
      // Catch any other unexpected errors during existence/readability check
      throw StorageException(
        userMessage: 'An unexpected error occurred while accessing the folder',
        methodName: 'fetchFolderContents',
        originalError: e.toString(),
        title: 'Unexpected Error',
        debugDetails: 'Path: $folderPath',
        stackTrace: stack.toString(),
      );
    }

    try {
      // 4. Load current settings for filtering
      final currentSettings = await _settingsDataSource.loadSettings();

      // 5. List contents using Directory.list()
      final directory = io.Directory(folderPath);
      final entities = await directory.list().toList();

      // 6. Initialize empty result list
      final result = <FileSystemEntry>[];

      // 7. Iterate through FileSystemEntity items
      for (final entity in entities) {
        final name = path.basename(entity.path);
        final entityPath = entity.path;
        final isDirectory = entity is io.Directory;

        // 8. Apply Global Exclusion Filters (using real settings)

        // Filter 1: Exclude Hidden Files (if setting is disabled)
        if (!currentSettings.showHiddenFiles && _isHiddenFile(name)) {
          continue; // Skip hidden files/folders
        }

        // Filter 2: Exclude by Name/Path (Global Setting)
        var isExcludedByName = false;
        for (final excludedName in currentSettings.excludedNames) {
          // Normalize excluded name for comparison (remove trailing slashes for directory matching)
          final normalizedExcludedName = excludedName.replaceAll(RegExp(r'/+$'), '');

          // Check for exact name match (for files) or directory name match
          if (name == normalizedExcludedName) {
            isExcludedByName = true;
            break;
          }

          // Check if it's a directory and the directory name matches the excluded name
          if (isDirectory && path.basename(entityPath) == normalizedExcludedName) {
            isExcludedByName = true;
            break;
          }

          // Check for path-based exclusions (e.g., if excludedName is 'some/dir' and entityPath contains it)
          // This is a simpler check, you might want more robust path logic
          if (entityPath.contains('/$normalizedExcludedName/') ||
              entityPath.endsWith('/$normalizedExcludedName')) {
            isExcludedByName = true;
            break;
          }
        }
        if (isExcludedByName) {
          continue; // Skip this item
        }

        // Filter 3: Exclude by Extension (Global Setting)
        // Only applies to files, not directories
        if (!isDirectory) {
          var hasExcludedExtension = false;
          for (final excludedExt in currentSettings.excludedFileExtensions) {
            // Ensure extensions start with a dot for comparison
            final normalizedExcludedExt = excludedExt.startsWith('.')
                ? excludedExt.toLowerCase()
                : '.${excludedExt.toLowerCase()}';
            if (name.toLowerCase().endsWith(normalizedExcludedExt)) {
              hasExcludedExtension = true;
              break;
            }
          }
          if (hasExcludedExtension) {
            continue; // Skip this file
          }
        }

        // 9. If passes global filters, check allowedExtensions parameter
        if (allowedExtensions != null && allowedExtensions.isNotEmpty) {
          // This filter only applies to files
          if (!isDirectory) {
            var matchesAllowedExtension = false;
            for (final allowedExt in allowedExtensions) {
              // Ensure extensions start with a dot for comparison
              final normalizedAllowedExt = allowedExt.startsWith('.')
                  ? allowedExt.toLowerCase()
                  : '.${allowedExt.toLowerCase()}';
              if (name.toLowerCase().endsWith(normalizedAllowedExt)) {
                matchesAllowedExtension = true;
                break;
              }
            }
            if (!matchesAllowedExtension) {
              continue; // Skip this file as it doesn't match allowed extensions
            }
          }
          // If it's a directory and allowedExtensions is specified,
          // the current logic implies directories are not filtered by extension.
          // This is typical behavior.
        }

        // 10. If item passes all filters, create FileSystemEntry object
        int? size;
        if (!isDirectory) {
          try {
            size = await (entity as io.File).length();
          } on Exception catch (_) {
            // If we can't get the size, it's okay to leave it null
            size = null;
          }
        }

        final entry = FileSystemEntry(
          name: name,
          path: entityPath,
          isDirectory: isDirectory,
          size: size,
        );

        // 11. Add to result list
        result.add(entry);
      }

      // 12. Sort the result list (directories first, then alphabetically)
      result.sort((a, b) {
        // Directories first
        if (a.isDirectory && !b.isDirectory) return -1;
        if (!a.isDirectory && b.isDirectory) return 1;
        // Then alphabetical order (case-insensitive)
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      // 13. Return result list
      return result;
    } on io.FileSystemException catch (e, stack) {
      // Catch errors during listing (though most should be caught earlier)
      throw StorageException(
        userMessage: 'Failed to list folder contents',
        methodName: 'fetchFolderContents',
        originalError: e.message,
        title: 'File System Error',
        debugDetails: 'Path: $folderPath',
        stackTrace: stack.toString(),
      );
    } catch (e, stack) {
      // Catch any other unexpected errors during listing/processing
      // If it's already our custom exception, rethrow it
      if (e is AppException) {
        rethrow;
      }
      throw StorageException(
        userMessage: 'An unexpected error occurred while processing folder contents',
        methodName: 'fetchFolderContents',
        originalError: e.toString(),
        title: 'Unexpected Error',
        debugDetails: 'Path: $folderPath',
        stackTrace: stack.toString(),
      );
    }
  }

  @override
  Future<CombineFilesResult> combineFiles(List<String> filePaths) async {
    // 1. Validate input
    if (filePaths.isEmpty) {
      throw const ValidationException(
        userMessage: 'No files provided to combine',
        methodName: 'combineFiles',
        originalError: 'Empty file paths list',
        title: 'Invalid Input',
        isRecoverable: false,
      );
    }

    try {
      // 2. Load settings
      final settings = await _settingsDataSource.loadSettings();
      
      // 3. Get Documents directory and create ai_context folder
      final documentsDir = _getDocumentsDirectory();
      final aiContextDir = io.Directory('${documentsDir.path}/ai_context');
      
      if (!await aiContextDir.exists()) {
        await aiContextDir.create(recursive: true);
      }

      // 4. Create StringBuffer for content with header
      final buffer = StringBuffer();
      var totalTokens = 0;

      // Add header with file count and list
      buffer..writeln('// ========================================')
      ..writeln('// COMBINED FILES SUMMARY')
      ..writeln('// ========================================')
      ..writeln('// Total files: ${filePaths.length}')
      ..writeln('// Files included:');
      for (var i = 0; i < filePaths.length; i++) {
        buffer.writeln('//   ${i + 1}. ${filePaths[i]}');
      }
      buffer..writeln('// ========================================')
      ..writeln()
      ..writeln();

      // 5. Process each file
      for (var i = 0; i < filePaths.length; i++) {
        final filePath = filePaths[i];
        
        try {
          final file = io.File(filePath);
          
          // Check if file exists
          if (!await file.exists()) {
            buffer.writeln('// File not found: $filePath');
            continue;
          }

          // Add file header
          buffer..writeln('// ========================================')
          ..writeln('// File: $filePath')
          ..writeln('// ========================================')
          ..writeln();

          // Read and process file content
          var content = await file.readAsString();
          
          // Strip comments if enabled
          if (settings.stripComments) {
            content = _stripComments(content);
          }
          
          buffer.writeln(content);
          
          // Count tokens (approximate: word count)
          totalTokens += _countTokens(content);
          
          // Add separator between files (except for last file)
          if (i < filePaths.length - 1) {
            buffer..writeln()
            ..writeln();
          }
        } on Exception catch (e) {
          // Add error note for problematic files
          buffer..writeln('// Error reading file: $filePath - $e')
          ..writeln();
        }
      }

      // 6. Check if content exceeds token limit and split if necessary
      final combinedContent = buffer.toString();
      final maxTokens = settings.maxTokenCount;
      final createdFiles = <io.File>[];
      
      if (maxTokens != null && totalTokens > maxTokens) {
        // Split content into two parts
        final lines = combinedContent.split('\n');
        final midPoint = lines.length ~/ 2;
        
        final part1Content = lines.take(midPoint).join('\n');
        final part2Content = lines.skip(midPoint).join('\n');
        
        // Create two files
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final file1 = io.File('${aiContextDir.path}/combined_files_${timestamp}_part1.txt');
        final file2 = io.File('${aiContextDir.path}/combined_files_${timestamp}_part2.txt');
        
        await file1.writeAsString(part1Content);
        await file2.writeAsString(part2Content);
        
        createdFiles.addAll([file1, file2]);
      } else {
        // Create single file
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final combinedFile = io.File('${aiContextDir.path}/combined_files_$timestamp.txt');
        await combinedFile.writeAsString(combinedContent);
        createdFiles.add(combinedFile);
      }

      return CombineFilesResult(
        files: createdFiles,
        totalFiles: createdFiles.length,
        totalTokens: totalTokens,
        saveLocation: aiContextDir.path,
      );
    } catch (e, stack) {
      throw StorageException(
        userMessage: 'Failed to combine files',
        methodName: 'combineFiles',
        originalError: e.toString(),
        title: 'File Combination Error',
        debugDetails: 'Files: ${filePaths.join(', ')}',
        stackTrace: stack.toString(),
      );
    }
  }

  // --- Helper Methods ---
  /// Checks if a file or folder name is considered "hidden".
  /// On most systems, this means it starts with a dot ('.').
  bool _isHiddenFile(String name) {
    return name.startsWith('.');
  }

  /// Gets the Documents directory path based on the platform
  io.Directory _getDocumentsDirectory() {
    if (io.Platform.isWindows) {
      final userProfile = io.Platform.environment['USERPROFILE'];
      return io.Directory('$userProfile\\Documents');
    } else {
      final home = io.Platform.environment['HOME'];
      return io.Directory('$home/Documents');
    }
  }

  /// Strips comments that start with // from the content
  String _stripComments(String content) {
    final lines = content.split('\n');
    final filteredLines = <String>[];
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      if (!trimmedLine.startsWith('//')) {
        filteredLines.add(line);
      }
    }
    
    return filteredLines.join('\n');
  }

  /// Counts tokens (approximate word count)
  int _countTokens(String content) {
    if (content.trim().isEmpty) return 0;
    return content.split(RegExp(r'\s+')).length;
  }
}
