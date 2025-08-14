import 'dart:io';

import 'package:context_for_ai/core/error/exception.dart';
import 'package:context_for_ai/features/code_combiner/data/models/file_node.dart';
import 'package:context_for_ai/features/code_combiner/data/models/node_type.dart';
import 'package:context_for_ai/features/code_combiner/data/models/selection_state.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

abstract class FileSystemDataSource {
  /// Purpose: Scan directory structure and build file tree nodes map
  Future<Map<String, FileNode>> scanDirectory(String directoryPath);

  /// Purpose: Read content from a single file with proper encoding detection
  Future<String> readFileContent(String filePath);

  /// Purpose: Read multiple files in parallel batches for better performance
  Future<Map<String, String>> readMultipleFiles(List<String> filePaths);
}

class FileSystemDataSourceImpl implements FileSystemDataSource {
  final Uuid _uuid = const Uuid();

  /// Purpose: Scan directory structure and build file tree nodes map
  @override
  Future<Map<String, FileNode>> scanDirectory(String directoryPath) async {
    try {
      // Input validation
      if (directoryPath.isEmpty) {
        throw const FileSystemException(
          methodName: 'scanDirectory',
          originalError: 'Directory path is empty',
          userMessage: 'Please provide a valid directory path',
          title: 'Invalid Directory Path',
        );
      }

      final normalizedPath = _normalizePath(directoryPath);

      if (!_isValidPath(normalizedPath)) {
        throw FileSystemException(
          methodName: 'scanDirectory',
          originalError: 'Invalid directory path: $normalizedPath',
          userMessage: 'The provided directory path is not valid',
          title: 'Invalid Directory Path',
        );
      }

      final directory = Directory(normalizedPath);

      // Check if directory exists and is accessible
      if (!directory.existsSync()) {
        throw FileSystemException(
          methodName: 'scanDirectory',
          originalError: 'Directory does not exist: $normalizedPath',
          userMessage: 'The selected directory does not exist',
          title: 'Directory Not Found',
        );
      }

      if (!await isAccessible(normalizedPath)) {
        throw const FileSystemException(
          methodName: 'scanDirectory',
          originalError: 'Permission denied to access directory',
          userMessage: 'Access denied. Please check directory permissions',
          title: 'Permission Denied',
        );
      }

      // Initialize the nodes map
      final nodes = <String, FileNode>{};

      // Create root directory node
      final rootId = _uuid.v4();
      // use to create top folder node
      final rootNode = _createFileNode(directory, null);

      final rootNodeWithId = FileNode(
        id: rootId,
        name: rootNode.name,
        path: rootNode.path,
        type: rootNode.type,
        selectionState: rootNode.selectionState,
        isExpanded: false,
        childIds: [],
      );

      nodes[rootId] = rootNodeWithId;

      // Recursively scan the directory
      await _scanDirectoryRecursive(directory, rootId, nodes);

      return nodes;
    } on FileSystemException {
      rethrow;
    } catch (e, stackTrace) {
      throw FileSystemException(
        methodName: 'scanDirectory',
        originalError: e.toString(),
        userMessage: 'Failed to scan directory structure',
        title: 'Directory Scan Failed',
        stackTrace: stackTrace.toString(),
        debugDetails: 'Directory path: $directoryPath',
      );
    }
  }

  /// Purpose: Validate if the provided path is valid and safe
  bool _isValidPath(String pathString) {
    try {
      if (pathString.isEmpty) return false;

      // Check for null bytes which could be security risks
      if (pathString.contains('\x00')) return false;

      // Check if path is absolute
      if (!path.isAbsolute(pathString)) return false;

      // Check for dangerous path traversal patterns
      if (pathString.contains('..')) return false;

      return true;
    } on FileSystemException {
      return false;
    }
  }

  /// Purpose: Normalize the path for consistent handling across platforms
  String _normalizePath(String pathString) {
    try {
      // Normalize the path using the path package
      // it erase all the extra spaces characters
      return path.normalize(pathString.trim());
    } on Exception catch (_) {
      return pathString.trim();
    }
  }

  /// Purpose: Create a FileNode from FileSystemEntity
  FileNode _createFileNode(FileSystemEntity entity, String? parentId) {
    final entityPath = entity.path;
    final entityName = path.basename(entityPath);
    final isDirectory = entity is Directory;

    return FileNode(
      id: _uuid.v4(),
      name: entityName,
      path: entityPath,
      type: isDirectory ? NodeType.folder : NodeType.file,
      selectionState: SelectionState.unchecked,
      isExpanded: false,
      parentId: parentId,
      childIds: [],
    );
  }

  /// Purpose: Get all child paths from a directory
  Future<List<String>> _getChildPaths(String directoryPath) async {
    try {
      final directory = Directory(directoryPath);
      final entities = await directory.list().toList();
      return entities.map((entity) => entity.path).toList();
    } on FileSystemException {
      // Log the error but return empty list to continue scanning
      return [];
    }
  }

  /// Purpose: Read content from a single file with proper validation and size checking
  @override
  Future<String> readFileContent(String filePath) async {
    try {
      // 1. Validate Input - Check if filePath is empty/null
      if (filePath.isEmpty) {
        throw const FileSystemException(
          methodName: 'readFileContent',
          originalError: 'File path is empty',
          userMessage: 'Invalid file path',
          title: 'Invalid File Path',
        );
      }

      // 2. Check File Exists - Verify file exists using File(filePath).existsSync()
      final file = File(filePath);
      if (!file.existsSync()) {
        throw FileSystemException(
          methodName: 'readFileContent',
          originalError: 'File not found: $filePath',
          userMessage: 'File does not exist',
          title: 'File Not Found',
        );
      }

      // 3. Check Accessibility - Use existing isAccessible() method
      if (!await isAccessible(filePath)) {
        throw FileSystemException(
          methodName: 'readFileContent',
          originalError: 'Permission denied: $filePath',
          userMessage: 'Permission denied to read file',
          title: 'Permission Denied',
        );
      }

      // 4. Check if Binary - Use existing isBinaryFile() method
      if (isBinaryFile(filePath)) {
        throw FileSystemException(
          methodName: 'readFileContent',
          originalError: 'Binary file detected: $filePath',
          userMessage: 'Cannot read binary file as text',
          title: 'Binary File Error',
        );
      }

      // 5. Get File Size - Use existing getFileSize() method
      final fileSizeBytes = await getFileSize(filePath);

      // 6. Size Check - If > 5MB, throw FileSystemException with "File too large (X MB)" message
      const maxSizeBytes = 5 * 1024 * 1024; // 5MB in bytes
      if (fileSizeBytes > maxSizeBytes) {
        final fileSizeMB = _convertBytesToMB(fileSizeBytes);
        throw FileSystemException(
          methodName: 'readFileContent',
          originalError: 'File size exceeds limit: $fileSizeMB MB',
          userMessage: 'File too large ($fileSizeMB MB). Use external editor.',
          title: 'File Too Large',
        );
      }

      // 7. Read File - Use File(filePath).readAsString() for files ≤ 5MB
      final content = await file.readAsString();

      // 8. Return content - Return the file content as String
      return content;
    } on FileSystemException {
      rethrow;
    } catch (e, stackTrace) {
      throw FileSystemException(
        methodName: 'readFileContent',
        originalError: e.toString(),
        userMessage: 'Failed to read file content',
        title: 'File Read Error',
        stackTrace: stackTrace.toString(),
        debugDetails: 'File path: $filePath',
      );
    }
  }

  Future<bool> _isFileReadable(String filePath) async {
    throw UnimplementedError();
  }

  String _detectFileEncoding(String filePath) {
    throw UnimplementedError();
  }

  Future<String> _readWithEncoding(String filePath, String encoding) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, String>> readMultipleFiles(List<String> filePaths) async {
    throw UnimplementedError();
  }

  List<List<String>> _createBatches(List<String> filePaths, int batchSize) {
    throw UnimplementedError();
  }

  Future<Map<String, String>> _processBatch(List<String> batch) async {
    throw UnimplementedError();
  }

  /// Purpose: Check if the path is accessible for reading

  Future<bool> isAccessible(String path) async {
    try {
      // Determine what the path points to without following symlinks.
      // Returns one of: file, directory, link, notFound.
      final entity = FileSystemEntity.typeSync(path);
      if (entity == FileSystemEntityType.notFound) {
        return false;
      }

      if (entity == FileSystemEntityType.directory) {
        final directory = Directory(path);
        // Try to list contents to check read permission
        await directory.list(followLinks: false).take(1).toList();
        return true;
      } else {
        // Try to read file stats to check accessibility
        File(path).statSync();
        return true;
      }
    } on Exception catch (_) {
      return false;
    }
  }

  /// Purpose: Recursively scan directory and build file tree structure
  Future<void> _scanDirectoryRecursive(
    Directory directory,
    String parentId,
    Map<String, FileNode> nodes,
  ) async {
    try {
      final entities = await directory.list(followLinks: false).toList();

      final childIds = <String>[];

      for (final entity in entities) {
        try {
          // Skip if not accessible
          if (!await isAccessible(entity.path)) {
            continue;
          }

          final childNode = _createFileNode(entity, parentId);
          nodes[childNode.id] = childNode;
          childIds.add(childNode.id);

          // If it's a directory, recursively scan it
          if (entity is Directory) {
            await _scanDirectoryRecursive(entity, childNode.id, nodes);
          }
        } on FileSystemException {
          // Log the error but continue scanning other files
          // This ensures one problematic file doesn't stop the entire scan
          continue;
        }
      }

      // Update parent node with child IDs
      final parentNode = nodes[parentId];
      if (parentNode != null) {
        nodes[parentId] = parentNode.copyWith(childIds: childIds);
      }
    } on FileSystemException {
      // If we can't scan this directory, just continue
      // The parent will have an empty childIds list
      return;
    }
  }

  bool _checkPermissions(String path) {
    try {
      final entity = File(path).existsSync() ? File(path) : Directory(path);
      if (!entity.existsSync()) return false;

      // Try to access the entity to test permissions
      if (entity is Directory) {
        entity.listSync();
      } else {
        (entity as File).readAsStringSync();
      }
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        throw FileSystemException(
          methodName: 'getFileSize',
          originalError: 'File not found: $filePath',
          userMessage: 'The specified file does not exist',
          title: 'File Not Found',
        );
      }
      return await file.length();
    } catch (e) {
      throw FileSystemException(
        methodName: 'getFileSize',
        originalError: e.toString(),
        userMessage: 'Unable to determine file size',
        title: 'File Access Error',
      );
    }
  }

  int _convertBytesToMB(int bytes) {
    return (bytes / (1024 * 1024)).round();
  }

  bool isBinaryFile(String filePath) {
    final extension = _extractFileExtension(filePath).toLowerCase();
    return _getBinaryExtensions().contains(extension);
  }

  String _extractFileExtension(String filePath) {
    return path.extension(filePath);
  }

  Set<String> _getBinaryExtensions() {
    return {
      '.exe',
      '.dll',
      '.so',
      '.dylib',
      '.png',
      '.jpg',
      '.jpeg',
      '.gif',
      '.ico',
      '.bmp',
      '.tiff',
      '.zip',
      '.tar',
      '.gz',
      '.rar',
      '.7z',
      '.bz2',
      '.pdf',
      '.doc',
      '.docx',
      '.xls',
      '.xlsx',
      '.ppt',
      '.pptx',
      '.mp3',
      '.mp4',
      '.avi',
      '.mov',
      '.wav',
      '.flv',
      '.bin',
      '.iso',
      '.dmg',
      '.pkg',
      '.deb',
      '.rpm',
    };
  }

  Future<bool> isValidDirectory(String path) async {
    try {
      if (path.isEmpty) return false;
      final directory = Directory(path);
      return directory.existsSync() &&
          _isActualDirectory(path) &&
          _hasReadPermission(path);
    } on Exception catch (_) {
      return false;
    }
  }

  bool _directoryExists(String path) {
    throw UnimplementedError();
  }

  bool _hasReadPermission(String path) {
    try {
      final directory = Directory(path);
      if (!directory.existsSync()) return false;

      // Try to list directory contents to test read permission
      directory.listSync();
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  bool _isActualDirectory(String path) {
    try {
      final entity = Directory(path);
      return entity.existsSync() &&
          entity.statSync().type == FileSystemEntityType.directory;
    } on Exception catch (_) {
      return false;
    }
  }
}
