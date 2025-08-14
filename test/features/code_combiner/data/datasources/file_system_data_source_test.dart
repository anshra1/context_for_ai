import 'dart:io' as io;

import 'package:context_for_ai/core/error/exception.dart';
import 'package:context_for_ai/features/code_combiner/data/datasources/file_system_data_source.dart';
import 'package:context_for_ai/features/code_combiner/data/models/file_node.dart';
import 'package:context_for_ai/features/code_combiner/data/models/node_type.dart';
import 'package:context_for_ai/features/code_combiner/data/models/selection_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

void main() {
  group('FileSystemDataSourceImpl', () {
    late FileSystemDataSourceImpl dataSource;
    late String testDirectoryPath;
    late io.Directory testDirectory;

    setUpAll(() async {
      // Create temporary test directory structure
      testDirectory = await io.Directory.systemTemp.createTemp('file_system_test_');
      testDirectoryPath = testDirectory.path;

      // Create test directory structure:
      // test_dir/
      // ├── file1.dart
      // ├── file2.txt
      // ├── .hidden_file.log
      // ├── nested_folder/
      // │   ├── nested_file.json
      // │   └── deep_folder/
      // │       └── deep_file.md
      // ├── empty_folder/
      // └── binary_file.exe

      await io.File(path.join(testDirectoryPath, 'file1.dart')).writeAsString('void main() {print("Hello");}');
      await io.File(path.join(testDirectoryPath, 'file2.txt')).writeAsString('Sample text content');
      await io.File(path.join(testDirectoryPath, '.hidden_file.log')).writeAsString('Hidden log content');
      
      final nestedFolder = io.Directory(path.join(testDirectoryPath, 'nested_folder'));
      await nestedFolder.create();
      await io.File(path.join(nestedFolder.path, 'nested_file.json')).writeAsString('{"key": "value"}');
      
      final deepFolder = io.Directory(path.join(nestedFolder.path, 'deep_folder'));
      await deepFolder.create();
      await io.File(path.join(deepFolder.path, 'deep_file.md')).writeAsString('# Deep File');
      
      final emptyFolder = io.Directory(path.join(testDirectoryPath, 'empty_folder'));
      await emptyFolder.create();
      
      // Create binary-like file
      await io.File(path.join(testDirectoryPath, 'binary_file.exe')).writeAsBytes([0x4D, 0x5A, 0x90, 0x00]);
    });

    tearDownAll(() async {
      // Clean up test directory
      if (testDirectory.existsSync()) {
        await testDirectory.delete(recursive: true);
      }
    });

    setUp(() {
      dataSource = FileSystemDataSourceImpl();
    });

    group('scanDirectory()', () {
      group('input validation', () {
        test('should throw FileSystemException for null directory path', () async {
          // Arrange - Act - Assert
          expect(
            () => dataSource.scanDirectory(''),
            throwsA(
              isA<FileSystemException>()
                  .having((e) => e.methodName, 'methodName', 'scanDirectory')
                  .having((e) => e.userMessage, 'userMessage', 'Please provide a valid directory path'),
            ),
          );
        });

        test('should throw FileSystemException for empty directory path', () async {
          // Arrange - Act - Assert
          expect(
            () => dataSource.scanDirectory('   '),
            throwsA(
              isA<FileSystemException>()
                  .having((e) => e.methodName, 'methodName', 'scanDirectory')
                  .having((e) => e.userMessage, 'userMessage', 'Please provide a valid directory path'),
            ),
          );
        });

        test('should throw FileSystemException for path with null bytes', () async {
          // Arrange
          const maliciousPath = '/test/path\x00/injection';

          // Act & Assert
          expect(
            () => dataSource.scanDirectory(maliciousPath),
            throwsA(
              isA<FileSystemException>()
                  .having((e) => e.debugDetails, 'debugDetails', contains('security violation')),
            ),
          );
        });

        test('should throw FileSystemException for path traversal attempts', () async {
          // Arrange
          const traversalPath = '/test/../../../etc/passwd';

          // Act & Assert
          expect(
            () => dataSource.scanDirectory(traversalPath),
            throwsA(
              isA<FileSystemException>()
                  .having((e) => e.debugDetails, 'debugDetails', contains('security violation')),
            ),
          );
        });

        test('should throw FileSystemException for non-existent directory', () async {
          // Arrange
          const nonExistentPath = '/this/path/does/not/exist';

          // Act & Assert
          expect(
            () => dataSource.scanDirectory(nonExistentPath),
            throwsA(
              isA<FileSystemException>()
                  .having((e) => e.userMessage, 'userMessage', 'The selected directory does not exist')
                  .having((e) => e.originalError, 'originalError', contains(nonExistentPath)),
            ),
          );
        });
      });

      group('success scenarios', () {
        test('should scan directory and return file tree map', () async {
          // Arrange - Act
          final result = await dataSource.scanDirectory(testDirectoryPath);

          // Assert
          expect(result, isA<Map<String, FileNode>>());
          expect(result, isNotEmpty);
          
          // Verify root directory is included
          final rootNode = result.values.firstWhere((node) => node.parentId == null);
          expect(rootNode.type, equals(NodeType.folder));
          expect(rootNode.path, equals(testDirectoryPath));
          
          // Verify files are included
          final dartFile = result.values.where((node) => 
              node.name == 'file1.dart' && node.type == NodeType.file).firstOrNull;
          expect(dartFile, isNotNull);
          expect(dartFile!.selectionState, equals(SelectionState.unchecked));
          expect(dartFile.isExpanded, equals(false));
          
          // Verify folders are included
          final nestedFolder = result.values.where((node) => 
              node.name == 'nested_folder' && node.type == NodeType.folder).firstOrNull;
          expect(nestedFolder, isNotNull);
          expect(nestedFolder!.childIds, isNotEmpty);
        });

        test('should create proper parent-child relationships', () async {
          // Arrange - Act
          final result = await dataSource.scanDirectory(testDirectoryPath);

          // Assert
          final rootNode = result.values.firstWhere((node) => node.parentId == null);
          final nestedFolder = result.values.firstWhere((node) => node.name == 'nested_folder');
          final nestedFile = result.values.firstWhere((node) => node.name == 'nested_file.json');
          
          // Verify nested folder has root as parent
          expect(nestedFolder.parentId, equals(rootNode.id));
          expect(rootNode.childIds, contains(nestedFolder.id));
          
          // Verify nested file has nested folder as parent
          expect(nestedFile.parentId, equals(nestedFolder.id));
          expect(nestedFolder.childIds, contains(nestedFile.id));
        });

        test('should handle deeply nested directory structures', () async {
          // Arrange - Act
          final result = await dataSource.scanDirectory(testDirectoryPath);

          // Assert
          final deepFile = result.values.where((node) => node.name == 'deep_file.md').firstOrNull;
          expect(deepFile, isNotNull);
          
          final deepFolder = result.values.where((node) => node.name == 'deep_folder').firstOrNull;
          expect(deepFolder, isNotNull);
          expect(deepFile!.parentId, equals(deepFolder!.id));
          
          // Verify complete hierarchy: root -> nested_folder -> deep_folder -> deep_file.md
          final nestedFolder = result[deepFolder.parentId!]!;
          final rootNode = result[nestedFolder.parentId!]!;
          expect(rootNode.parentId, isNull); // Root has no parent
        });

        test('should handle empty directories correctly', () async {
          // Arrange - Act
          final result = await dataSource.scanDirectory(testDirectoryPath);

          // Assert
          final emptyFolder = result.values.where((node) => node.name == 'empty_folder').firstOrNull;
          expect(emptyFolder, isNotNull);
          expect(emptyFolder!.type, equals(NodeType.folder));
          expect(emptyFolder.childIds, isEmpty);
        });

        test('should assign unique IDs to all nodes', () async {
          // Arrange - Act
          final result = await dataSource.scanDirectory(testDirectoryPath);

          // Assert
          final allIds = result.keys.toSet();
          expect(allIds.length, equals(result.length)); // No duplicate IDs
          
          // Verify all IDs are valid UUIDs (36 characters with hyphens)
          for (final id in allIds) {
            expect(id.length, equals(36));
            expect(id, matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')));
          }
        });

        test('should initialize all nodes with correct default states', () async {
          // Arrange - Act
          final result = await dataSource.scanDirectory(testDirectoryPath);

          // Assert
          for (final node in result.values) {
            expect(node.selectionState, equals(SelectionState.unchecked));
            expect(node.isExpanded, equals(false));
            expect(node.id, isNotEmpty);
            expect(node.name, isNotEmpty);
            expect(node.path, isNotEmpty);
          }
        });
      });

      group('edge cases', () {
        test('should filter hidden files by default', () async {
          // Arrange - Act
          final result = await dataSource.scanDirectory(testDirectoryPath);

          // Assert
          final hiddenFile = result.values.where((node) => node.name.startsWith('.')).toList();
          expect(hiddenFile, isEmpty, reason: 'Hidden files should be filtered out by default');
        });

        test('should handle files with no extension', () async {
          // Arrange
          await io.File(path.join(testDirectoryPath, 'README')).writeAsString('No extension file');
          
          // Act
          final result = await dataSource.scanDirectory(testDirectoryPath);

          // Assert
          final noExtFile = result.values.where((node) => node.name == 'README').firstOrNull;
          expect(noExtFile, isNotNull);
          expect(noExtFile!.type, equals(NodeType.file));
        });

        test('should handle very long file names', () async {
          // Arrange
          final longFileName = 'a' * 100 + '.txt';
          await io.File(path.join(testDirectoryPath, longFileName)).writeAsString('Long name content');
          
          // Act
          final result = await dataSource.scanDirectory(testDirectoryPath);

          // Assert
          final longNameFile = result.values.where((node) => node.name == longFileName).firstOrNull;
          expect(longNameFile, isNotNull);
          expect(longNameFile!.name.length, equals(104));
        });

        test('should handle special characters in file names', () async {
          // Arrange
          const specialFileName = 'special-file_name (1) & [test].txt';
          await io.File(path.join(testDirectoryPath, specialFileName)).writeAsString('Special chars content');
          
          // Act
          final result = await dataSource.scanDirectory(testDirectoryPath);

          // Assert
          final specialFile = result.values.where((node) => node.name == specialFileName).firstOrNull;
          expect(specialFile, isNotNull);
          expect(specialFile!.name, equals(specialFileName));
        });
      });

      group('error handling', () {
        test('should handle permission denied gracefully', () async {
          // Arrange - Create restricted directory (if possible on test system)
          final restrictedDir = io.Directory(path.join(testDirectoryPath, 'restricted'));
          await restrictedDir.create();
          
          // This test may not work on all systems due to permission restrictions
          try {
            // Act
            final result = await dataSource.scanDirectory(testDirectoryPath);
            
            // Assert - Should complete without throwing, might skip restricted files
            expect(result, isA<Map<String, FileNode>>());
          } on FileSystemException catch (e) {
            // If permission error occurs, verify it's handled properly
            expect(e.methodName, equals('scanDirectory'));
            expect(e.userMessage, contains('Error scanning directory'));
          }
        });

        test('should handle corrupted file system entries gracefully', () async {
          // Arrange - This test simulates what happens when file system has issues
          // We can't easily create actual corruption, so we test the general error handling
          
          // Act & Assert - Should not crash on file system anomalies
          final result = await dataSource.scanDirectory(testDirectoryPath);
          expect(result, isA<Map<String, FileNode>>());
        });

        test('should stop execution on critical file system errors', () async {
          // Arrange - Try to access a system path that should cause critical error
          const systemPath = '/proc/1/mem'; // Linux system path that should be restricted
          
          // Act & Assert
          expect(
            () => dataSource.scanDirectory(systemPath),
            throwsA(
              isA<FileSystemException>()
                  .having((e) => e.userMessage, 'userMessage', contains('not found or inaccessible')),
            ),
          );
        });
      });

      group('performance scenarios', () {
        test('should handle moderately large directory structure', () async {
          // Arrange - Create a moderate number of files for performance testing
          final perfTestDir = io.Directory(path.join(testDirectoryPath, 'perf_test'));
          await perfTestDir.create();
          
          // Create 50 files and 10 directories
          for (var i = 0; i < 50; i++) {
            await io.File(path.join(perfTestDir.path, 'file_$i.txt')).writeAsString('Content $i');
          }
          for (var i = 0; i < 10; i++) {
            final dir = io.Directory(path.join(perfTestDir.path, 'dir_$i'));
            await dir.create();
            await io.File(path.join(dir.path, 'nested_$i.txt')).writeAsString('Nested $i');
          }
          
          // Act
          final stopwatch = Stopwatch()..start();
          final result = await dataSource.scanDirectory(perfTestDir.path);
          stopwatch.stop();
          
          // Assert
          expect(result.length, greaterThan(60)); // At least 60+ nodes
          expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // Should complete within 5 seconds
        });
      });

      group('data consistency', () {
        test('should maintain referential integrity in parent-child relationships', () async {
          // Arrange - Act
          final result = await dataSource.scanDirectory(testDirectoryPath);

          // Assert
          for (final node in result.values) {
            // Every non-root node should have valid parent reference
            if (node.parentId != null) {
              expect(result.containsKey(node.parentId), isTrue,
                  reason: 'Parent ID ${node.parentId} should exist in result map');
              
              final parent = result[node.parentId!]!;
              expect(parent.childIds, contains(node.id),
                  reason: 'Parent should contain child ID in its childIds list');
            }
            
            // Every child ID should exist in result map
            for (final childId in node.childIds) {
              expect(result.containsKey(childId), isTrue,
                  reason: 'Child ID $childId should exist in result map');
              
              final child = result[childId]!;
              expect(child.parentId, equals(node.id),
                  reason: 'Child should reference this node as parent');
            }
          }
        });

        test('should ensure single root node exists', () async {
          // Arrange - Act
          final result = await dataSource.scanDirectory(testDirectoryPath);

          // Assert
          final rootNodes = result.values.where((node) => node.parentId == null).toList();
          expect(rootNodes, hasLength(1), reason: 'Should have exactly one root node');
          
          final rootNode = rootNodes.first;
          expect(rootNode.type, equals(NodeType.folder));
          expect(rootNode.path, equals(testDirectoryPath));
        });

        test('should have consistent file paths', () async {
          // Arrange - Act
          final result = await dataSource.scanDirectory(testDirectoryPath);

          // Assert
          for (final node in result.values) {
            // All paths should be absolute
            expect(path.isAbsolute(node.path), isTrue,
                reason: 'All paths should be absolute: ${node.path}');
            
            // File/folder should actually exist at the specified path
            final entity = node.type == NodeType.file 
                ? io.File(node.path) 
                : io.Directory(node.path);
            expect(entity.existsSync(), isTrue,
                reason: 'Entity should exist at path: ${node.path}');
            
            // Name should match the last segment of the path
            expect(path.basename(node.path), equals(node.name),
                reason: 'Name should match path basename');
          }
        });
      });
    });

    group('helper methods', () {
      group('isAccessible()', () {
        test('should return true for accessible file', () async {
          // Arrange
          final testFile = path.join(testDirectoryPath, 'file1.dart');
          
          // Act
          final result = await dataSource.isAccessible(testFile);
          
          // Assert
          expect(result, isTrue);
        });

        test('should return true for accessible directory', () async {
          // Arrange - Act
          final result = await dataSource.isAccessible(testDirectoryPath);
          
          // Assert
          expect(result, isTrue);
        });

        test('should return false for non-existent path', () async {
          // Arrange
          const nonExistentPath = '/this/does/not/exist';
          
          // Act
          final result = await dataSource.isAccessible(nonExistentPath);
          
          // Assert
          expect(result, isFalse);
        });
      });

      group('getFileSize()', () {
        test('should return correct file size in bytes', () async {
          // Arrange
          final testFile = path.join(testDirectoryPath, 'file1.dart');
          final actualSize = await io.File(testFile).length();
          
          // Act
          final result = await dataSource.getFileSize(testFile);
          
          // Assert
          expect(result, equals(actualSize));
          expect(result, greaterThan(0));
        });

        test('should throw FileSystemException for non-existent file', () async {
          // Arrange
          const nonExistentFile = '/this/file/does/not/exist.txt';
          
          // Act & Assert
          expect(
            () => dataSource.getFileSize(nonExistentFile),
            throwsA(
              isA<FileSystemException>()
                  .having((e) => e.methodName, 'methodName', 'getFileSize'),
            ),
          );
        });
      });

      group('isBinaryFile()', () {
        test('should return true for binary file extensions', () {
          // Arrange - Act - Assert
          expect(dataSource.isBinaryFile('test.exe'), isTrue);
          expect(dataSource.isBinaryFile('image.png'), isTrue);
          expect(dataSource.isBinaryFile('archive.zip'), isTrue);
          expect(dataSource.isBinaryFile('library.dll'), isTrue);
        });

        test('should return false for text file extensions', () {
          // Arrange - Act - Assert
          expect(dataSource.isBinaryFile('code.dart'), isFalse);
          expect(dataSource.isBinaryFile('data.json'), isFalse);
          expect(dataSource.isBinaryFile('style.css'), isFalse);
          expect(dataSource.isBinaryFile('readme.md'), isFalse);
          expect(dataSource.isBinaryFile('script.js'), isFalse);
        });

        test('should return false for files without extension', () {
          // Arrange - Act - Assert
          expect(dataSource.isBinaryFile('README'), isFalse);
          expect(dataSource.isBinaryFile('Makefile'), isFalse);
          expect(dataSource.isBinaryFile('dockerfile'), isFalse);
        });

        test('should be case insensitive', () {
          // Arrange - Act - Assert
          expect(dataSource.isBinaryFile('TEST.EXE'), isTrue);
          expect(dataSource.isBinaryFile('Image.PNG'), isTrue);
          expect(dataSource.isBinaryFile('Code.DART'), isFalse);
          expect(dataSource.isBinaryFile('Data.JSON'), isFalse);
        });
      });

      group('isValidDirectory()', () {
        test('should return true for valid existing directory', () async {
          // Arrange - Act
          final result = await dataSource.isValidDirectory(testDirectoryPath);
          
          // Assert
          expect(result, isTrue);
        });

        test('should return false for file path', () async {
          // Arrange
          final filePath = path.join(testDirectoryPath, 'file1.dart');
          
          // Act
          final result = await dataSource.isValidDirectory(filePath);
          
          // Assert
          expect(result, isFalse);
        });

        test('should return false for non-existent directory', () async {
          // Arrange
          const nonExistentDir = '/this/directory/does/not/exist';
          
          // Act
          final result = await dataSource.isValidDirectory(nonExistentDir);
          
          // Assert
          expect(result, isFalse);
        });

        test('should return false for empty path', () async {
          // Arrange - Act
          final result = await dataSource.isValidDirectory('');
          
          // Assert
          expect(result, isFalse);
        });
      });
    });
  });
}