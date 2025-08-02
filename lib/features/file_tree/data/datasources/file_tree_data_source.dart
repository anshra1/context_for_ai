import 'dart:io' as io;
import 'package:path/path.dart' as path;
import 'package:context_for_ai/core/error/exception.dart';
import 'package:context_for_ai/features/setting/data/datasource/setting_datasource.dart';
import '../models/tree_entry_model.dart';
import '../models/tree_filter_model.dart';
import '../../domain/services/tree_filter_service.dart';
import '../../domain/entities/tree_filter.dart';

abstract class FileTreeDataSource {
  /// Load raw folder contents from file system
  Future<List<TreeEntryModel>> loadFolderContents(String folderPath);

  /// Load folder contents with filtering applied
  Future<List<TreeEntryModel>> loadFilteredFolderContents(
    String folderPath, 
    TreeFilter filter,
  );

  /// Calculate token count for a file
  Future<int> calculateTokenCount(String filePath);

  /// Check if file is readable
  Future<bool> checkFileReadability(String filePath);

  /// Get global filter from app settings
  Future<TreeFilterModel> getGlobalFilter();

  /// Validate path exists and is accessible
  Future<bool> validatePath(String path);
}

class FileTreeDataSourceImpl implements FileTreeDataSource {
  final SettingsDataSource settingsDataSource;
  final TreeFilterService filterService;

  const FileTreeDataSourceImpl({
    required this.settingsDataSource,
    required this.filterService,
  });

  @override
  Future<List<TreeEntryModel>> loadFolderContents(String folderPath) async {
    try {
      // Validate path
      if (folderPath.isEmpty) {
        throw const ValidationException(
          userMessage: 'Folder path cannot be empty',
          methodName: 'loadFolderContents',
          originalError: 'Empty path provided',
          title: 'Invalid Path',
          isRecoverable: false,
        );
      }

      final directory = io.Directory(folderPath);

      // Check if directory exists
      if (!await directory.exists()) {
        throw StorageException(
          userMessage: 'The specified folder does not exist',
          methodName: 'loadFolderContents',
          originalError: 'Path not found: $folderPath',
          title: 'Folder Not Found',
          debugDetails: 'Path: $folderPath',
          isRecoverable: false,
        );
      }

      // Check readability
      try {
        await directory.list().take(1).toList();
      } on io.FileSystemException catch (e) {
        if (e.osError?.errorCode == 13 || e.message.toLowerCase().contains('permission')) {
          throw StorageException(
            userMessage: 'Permission denied. Cannot access the folder',
            methodName: 'loadFolderContents',
            originalError: e.message,
            title: 'Permission Denied',
            debugDetails: 'Path: $folderPath',
            isRecoverable: false,
          );
        }
        rethrow;
      }

      // List directory contents
      final entities = await directory.list().toList();
      final entries = <TreeEntryModel>[];

      // Process each entity
      for (final entity in entities) {
        try {
          final name = path.basename(entity.path);
          final entityPath = entity.path;
          final isDirectory = entity is io.Directory;

          // Get file info
          int? size;
          DateTime? lastModified;
          bool isReadable = true;

          if (!isDirectory) {
            try {
              final file = entity as io.File;
              final stat = await file.stat();
              size = stat.size;
              lastModified = stat.modified;

              // Test readability
              await file.readAsBytes();
            } catch (e) {
              // File is not readable
              isReadable = false;
            }
          } else {
            try {
              final stat = await entity.stat();
              lastModified = stat.modified;
            } catch (e) {
              // Directory stat failed
              isReadable = false;
            }
          }

          final entry = TreeEntryModel.fromFileSystemEntity(
            name: name,
            path: entityPath,
            isDirectory: isDirectory,
            size: size,
            lastModified: lastModified,
            isReadable: isReadable,
          );

          entries.add(entry);
        } catch (e) {
          // Skip problematic entries
          continue;
        }
      }

      // Sort: directories first, then alphabetically
      entries.sort((a, b) {
        if (a.isDirectory && !b.isDirectory) return -1;
        if (!a.isDirectory && b.isDirectory) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      return entries;
    } on AppException {
      rethrow;
    } on io.FileSystemException catch (e, stack) {
      if (e.osError?.errorCode == 13) {
        throw StorageException(
          userMessage: 'Permission denied',
          methodName: 'loadFolderContents',
          originalError: e.message,
          title: 'Permission Error',
          debugDetails: 'Path: $folderPath',
          stackTrace: stack.toString(),
        );
      }
      throw StorageException(
        userMessage: 'Failed to load folder contents',
        methodName: 'loadFolderContents',
        originalError: e.message,
        title: 'File System Error',
        debugDetails: 'Path: $folderPath',
        stackTrace: stack.toString(),
      );
    } catch (e, stack) {
      throw StorageException(
        userMessage: 'An unexpected error occurred while loading folder',
        methodName: 'loadFolderContents',
        originalError: e.toString(),
        title: 'Unexpected Error',
        debugDetails: 'Path: $folderPath',
        stackTrace: stack.toString(),
      );
    }
  }

  @override
  Future<List<TreeEntryModel>> loadFilteredFolderContents(
    String folderPath,
    TreeFilter filter,
  ) async {
    try {
      // Load all entries first
      final allEntries = await loadFolderContents(folderPath);
      
      // Convert to entities for filtering
      final entities = allEntries.map((model) => model.toEntity()).toList();
      
      // Apply filter using the service
      final filteredEntities = filterService.applyFilter(entities, filter);
      
      // Convert back to models
      return filteredEntities
          .map((entity) => TreeEntryModel.fromEntity(entity))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<int> calculateTokenCount(String filePath) async {
    try {
      final file = io.File(filePath);
      
      if (!await file.exists()) {
        return 0;
      }

      final content = await file.readAsString();
      return _estimateTokenCount(content);
    } catch (e) {
      // Return 0 for unreadable files
      return 0;
    }
  }

  @override
  Future<bool> checkFileReadability(String filePath) async {
    try {
      final file = io.File(filePath);
      
      if (!await file.exists()) {
        return false;
      }

      // Try to read the file
      await file.readAsBytes();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<TreeFilterModel> getGlobalFilter() async {
    try {
      final appSettings = await settingsDataSource.loadSettings();
      
      return TreeFilterModel.fromAppSettings(
        appSettings: appSettings,
        allowedExtensions: [], // Will be set by presentation layer
        searchQuery: '', // Default empty
      );
    } catch (e) {
      // Return default filter if settings loading fails
      return const TreeFilterModel();
    }
  }

  @override
  Future<bool> validatePath(String path) async {
    try {
      if (path.isEmpty) return false;
      
      final directory = io.Directory(path);
      
      if (!await directory.exists()) {
        return false;
      }

      // Test if we can list the directory
      await directory.list().take(1).toList();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Private: Estimate token count from content
  int _estimateTokenCount(String content) {
    if (content.trim().isEmpty) return 0;
    
    // Simple approximation: 1 token ≈ 4 characters or 1 word
    final wordCount = content.split(RegExp(r'\s+')).length;
    final charCount = content.length;
    
    return (wordCount + (charCount / 4)).round();
  }
}