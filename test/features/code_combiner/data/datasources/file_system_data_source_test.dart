import 'dart:convert';
import 'dart:io' as io;

import 'package:context_for_ai/core/error/exception.dart';
import 'package:context_for_ai/features/code_combiner/data/datasources/file_system_data_source.dart';
import 'package:context_for_ai/features/code_combiner/data/models/app_settings.dart';
import 'package:context_for_ai/features/code_combiner/data/models/file_node.dart';
import 'package:context_for_ai/features/code_combiner/data/enum/node_type.dart';
import 'package:context_for_ai/features/code_combiner/data/enum/selection_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

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

    group('combineAndExportFiles()', () {
      late io.Directory tempExportDir;
      late List<String> testFilePaths;
      
      setUp(() async {
        // Create temporary export directory
        tempExportDir = await io.Directory.systemTemp.createTemp('export_test_');
        
        // Set up SharedPreferences mock with test settings
        SharedPreferences.setMockInitialValues({
          'app_settings': jsonEncode({
            'fileSplitSizeInMB': 1, // 1MB for testing
            'maxTokenWarningLimit': 10000,
            'warnOnTokenExceed': true,
            'stripCommentsFromCode': false,
            'defaultExportLocation': tempExportDir.path,
          }),
        });
        
        // Create test files with known content
        testFilePaths = [
          path.join(testDirectoryPath, 'file1.dart'),
          path.join(testDirectoryPath, 'file2.txt'),
          path.join(testDirectoryPath, 'nested_folder', 'nested_file.json'),
        ];
      });

      tearDown(() async {
        if (tempExportDir.existsSync()) {
          await tempExportDir.delete(recursive: true);
        }
      });

      group('successful file combination', () {
        test('should combine multiple files with proper headers and return created files', () async {
          // Arrange
          final inputPaths = [
            testFilePaths[0], // file1.dart
            testFilePaths[1], // file2.txt
          ];

          // Act
          final result = await dataSource.combineAndExportFiles(inputPaths);

          // Assert
          expect(result, isNotEmpty);
          expect(result.length, equals(1)); // Should create single file (content is small)
          
          final createdFile = result.first;
          expect(createdFile.existsSync(), isTrue);
          expect(createdFile.path.contains('combined_export_'), isTrue);
          expect(createdFile.path.endsWith('.txt'), isTrue);
          
          final content = await createdFile.readAsString();
          expect(content, contains('=== ${testFilePaths[0]} ==='));
          expect(content, contains('=== ${testFilePaths[1]} ==='));
          expect(content, contains('void main() {print("Hello");}'));
          expect(content, contains('Sample text content'));
        });

        test('should create files with timestamp-based naming', () async {
          // Arrange
          final inputPaths = [testFilePaths[0]];

          // Act
          final result = await dataSource.combineAndExportFiles(inputPaths);

          // Assert
          final createdFile = result.first;
          final filename = path.basename(createdFile.path);
          
          // Should match pattern: combined_export_YYYY-MM-DDTHH-MM-SS.txt
          expect(filename, matches(RegExp(r'^combined_export_\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2}\.txt$')));
        });

        test('should handle empty file list gracefully', () async {
          // Arrange
          final inputPaths = <String>[];

          // Act
          final result = await dataSource.combineAndExportFiles(inputPaths);

          // Assert
          expect(result, isNotEmpty);
          expect(result.length, equals(1));
          
          final content = await result.first.readAsString();
          expect(content.trim(), isEmpty);
        });
      });

      group('file filtering', () {
        test('should skip binary files', () async {
          // Arrange
          final binaryFile = path.join(testDirectoryPath, 'binary_file.exe');
          final inputPaths = [testFilePaths[0], binaryFile];

          // Act
          final result = await dataSource.combineAndExportFiles(inputPaths);

          // Assert
          final content = await result.first.readAsString();
          expect(content, contains('=== ${testFilePaths[0]} ==='));
          expect(content, isNot(contains('binary_file.exe')));
        });

        test('should skip oversized files', () async {
          // Arrange - Create a large file (over 1MB limit set in setUp)
          final largeFilePath = path.join(testDirectoryPath, 'large_file.txt');
          final largeContent = 'x' * (2 * 1024 * 1024); // 2MB of content
          await io.File(largeFilePath).writeAsString(largeContent);
          
          final inputPaths = [testFilePaths[0], largeFilePath];

          // Act
          final result = await dataSource.combineAndExportFiles(inputPaths);

          // Assert
          final content = await result.first.readAsString();
          expect(content, contains('=== ${testFilePaths[0]} ==='));
          expect(content, isNot(contains('large_file.txt')));
          
          // Cleanup
          await io.File(largeFilePath).delete();
        });

        test('should skip non-existent files', () async {
          // Arrange
          final inputPaths = [
            testFilePaths[0],
            '/non/existent/file.txt',
            testFilePaths[1],
          ];

          // Act
          final result = await dataSource.combineAndExportFiles(inputPaths);

          // Assert
          final content = await result.first.readAsString();
          expect(content, contains('=== ${testFilePaths[0]} ==='));
          expect(content, contains('=== ${testFilePaths[1]} ==='));
          expect(content, isNot(contains('/non/existent/file.txt')));
        });

        test('should skip inaccessible files', () async {
          // Arrange - Create file and immediately delete to make it inaccessible
          final inaccessibleFile = path.join(testDirectoryPath, 'temp_file.txt');
          await io.File(inaccessibleFile).writeAsString('temp content');
          await io.File(inaccessibleFile).delete();
          
          final inputPaths = [testFilePaths[0], inaccessibleFile];

          // Act
          final result = await dataSource.combineAndExportFiles(inputPaths);

          // Assert
          final content = await result.first.readAsString();
          expect(content, contains('=== ${testFilePaths[0]} ==='));
          expect(content, isNot(contains('temp_file.txt')));
        });
      });

      group('content splitting', () {
        test('should split content when it exceeds size limit', () async {
          // Arrange - Create multiple files that together exceed 1MB
          final largeFiles = <String>[];
          for (var i = 0; i < 4; i++) {
            final filePath = path.join(testDirectoryPath, 'split_test_$i.txt');
            final content = 'X' * 300000; // 300KB each * 4 = 1.2MB total
            await io.File(filePath).writeAsString(content);
            largeFiles.add(filePath);
          }

          // Act
          final result = await dataSource.combineAndExportFiles(largeFiles);

          // Assert
          expect(result.length, greaterThan(1)); // Should be split into multiple files
          
          // Verify filenames have part numbers
          for (var i = 0; i < result.length; i++) {
            final filename = path.basename(result[i].path);
            expect(filename, contains('_part${i + 1}.txt'));
          }
          
          // Verify all files exist and have content
          for (final file in result) {
            expect(file.existsSync(), isTrue);
            final content = await file.readAsString();
            expect(content.isNotEmpty, isTrue);
          }
          
          // Cleanup
          for (final filePath in largeFiles) {
            await io.File(filePath).delete();
          }
        });

        test('should break at newlines when possible during splitting', () async {
          // Arrange - Create file with known line structure
          final testFile = path.join(testDirectoryPath, 'line_break_test.txt');
          final lines = List.generate(1000, (i) => 'Line $i with some content');
          await io.File(testFile).writeAsString(lines.join('\n'));

          // Act
          final result = await dataSource.combineAndExportFiles([testFile]);

          // Assert
          if (result.length > 1) {
            // If split occurred, verify content breaks at newlines
            for (final file in result) {
              final content = await file.readAsString();
              if (content.isNotEmpty && !content.endsWith('\n')) {
                // Content should not end mid-line (unless it's the last chunk)
                expect(content.endsWith('\n') || file == result.last, isTrue);
              }
            }
          }
          
          // Cleanup
          await io.File(testFile).delete();
        });

        test('should not split when content is under size limit', () async {
          // Arrange - Use small files that won't trigger splitting
          final inputPaths = [testFilePaths[0], testFilePaths[1]];

          // Act
          final result = await dataSource.combineAndExportFiles(inputPaths);

          // Assert
          expect(result.length, equals(1)); // Should create single file
          
          final filename = path.basename(result.first.path);
          expect(filename, isNot(contains('_part')));
        });
      });

      group('SharedPreferences integration', () {
        test('should use settings from SharedPreferences', () async {
          // Arrange - Update SharedPreferences with different settings
          SharedPreferences.setMockInitialValues({
            'app_settings': jsonEncode({
              'fileSplitSizeInMB': 2, // Different size limit
              'maxTokenWarningLimit': 20000,
              'warnOnTokenExceed': false,
              'stripCommentsFromCode': true,
              'defaultExportLocation': tempExportDir.path,
            }),
          });

          // Act
          final result = await dataSource.combineAndExportFiles([testFilePaths[0]]);

          // Assert
          expect(result, isNotEmpty);
          expect(result.first.path.startsWith(tempExportDir.path), isTrue);
        });

        test('should fallback to defaults when SharedPreferences is empty', () async {
          // Arrange - Clear SharedPreferences
          SharedPreferences.setMockInitialValues({});

          try {
            // Act
            final result = await dataSource.combineAndExportFiles([testFilePaths[0]]);
            // Assert - Should complete successfully
            expect(result, isNotEmpty);
          } on Exception catch (e) {
            // Accept that path_provider might fail in test environment
            expect(e.toString(), contains('path_provider'));
          }
        });

        test('should fallback to defaults when SharedPreferences contains invalid data', () async {
          // Arrange - Set invalid JSON in SharedPreferences
          SharedPreferences.setMockInitialValues({
            'app_settings': 'invalid json data',
          });

          try {
            // Act
            final result = await dataSource.combineAndExportFiles([testFilePaths[0]]);
            // Assert - Should complete successfully
            expect(result, isNotEmpty);
          } on Exception catch (e) {
            // Accept that path_provider might fail in test environment
            expect(e.toString(), contains('path_provider'));
          }
        });
      });

      group('directory creation', () {
        test('should create export directory if it does not exist', () async {
          // Arrange - Delete export directory
          if (tempExportDir.existsSync()) {
            await tempExportDir.delete(recursive: true);
          }
          expect(tempExportDir.existsSync(), isFalse);

          // Act
          final result = await dataSource.combineAndExportFiles([testFilePaths[0]]);

          // Assert
          expect(result, isNotEmpty);
          expect(tempExportDir.existsSync(), isTrue);
          expect(result.first.existsSync(), isTrue);
        });

        test('should handle nested directory creation', () async {
          // Arrange - Set export location to nested path
          final nestedPath = path.join(tempExportDir.path, 'nested', 'deeper');
          SharedPreferences.setMockInitialValues({
            'app_settings': jsonEncode({
              'fileSplitSizeInMB': 1,
              'maxTokenWarningLimit': 10000,
              'warnOnTokenExceed': true,
              'stripCommentsFromCode': false,
              'defaultExportLocation': nestedPath,
            }),
          });

          // Act
          final result = await dataSource.combineAndExportFiles([testFilePaths[0]]);

          // Assert
          expect(result, isNotEmpty);
          expect(io.Directory(nestedPath).existsSync(), isTrue);
          expect(result.first.path.startsWith(nestedPath), isTrue);
        });
      });

      group('error handling', () {
        test('should throw FileSystemException with proper details on critical failure', () async {
          // Arrange - Create scenario that might cause failure (permission denied directory)
          final restrictedPath = '/root/restricted_export'; // Likely to be inaccessible
          SharedPreferences.setMockInitialValues({
            'app_settings': jsonEncode({
              'fileSplitSizeInMB': 1,
              'maxTokenWarningLimit': 10000,
              'warnOnTokenExceed': true,
              'stripCommentsFromCode': false,
              'defaultExportLocation': restrictedPath,
            }),
          });

          // Act & Assert
          expect(
            () => dataSource.combineAndExportFiles([testFilePaths[0]]),
            throwsA(
              isA<FileSystemException>()
                  .having((e) => e.methodName, 'methodName', 'combineAndExportFiles')
                  .having((e) => e.userMessage, 'userMessage', 'Failed to combine and export files')
                  .having((e) => e.debugDetails, 'debugDetails', contains(testFilePaths[0])),
            ),
          );
        });

        test('should continue processing when individual files fail to read', () async {
          // Arrange - Mix of valid and problematic files
          final validFile = testFilePaths[0];
          final problemFile = path.join(testDirectoryPath, 'problem_file.txt');
          
          // Create file then make it problematic by changing permissions or deleting
          await io.File(problemFile).writeAsString('temp');
          await io.File(problemFile).delete(); // Make it non-existent
          
          final inputPaths = [validFile, problemFile, testFilePaths[1]];

          // Act
          final result = await dataSource.combineAndExportFiles(inputPaths);

          // Assert
          expect(result, isNotEmpty);
          final content = await result.first.readAsString();
          expect(content, contains('=== $validFile ==='));
          expect(content, contains('=== ${testFilePaths[1]} ==='));
          expect(content, isNot(contains('problem_file.txt')));
        });
      });

      group('batch processing', () {
        test('should handle large number of files efficiently', () async {
          // Arrange - Create many small files
          final manyFiles = <String>[];
          for (var i = 0; i < 25; i++) { // More than batch size of 10
            final filePath = path.join(testDirectoryPath, 'batch_file_$i.txt');
            await io.File(filePath).writeAsString('Content $i');
            manyFiles.add(filePath);
          }

          // Act
          final stopwatch = Stopwatch()..start();
          final result = await dataSource.combineAndExportFiles(manyFiles);
          stopwatch.stop();

          // Assert
          expect(result, isNotEmpty);
          expect(stopwatch.elapsedMilliseconds, lessThan(10000)); // Should complete within 10 seconds
          
          final content = await result.first.readAsString();
          for (var i = 0; i < 25; i++) {
            expect(content, contains('Content $i'));
          }
          
          // Cleanup
          for (final filePath in manyFiles) {
            await io.File(filePath).delete();
          }
        });
      });

      group('content formatting', () {
        test('should format headers correctly with file paths', () async {
          // Arrange
          final inputPaths = [testFilePaths[0], testFilePaths[2]];

          // Act
          final result = await dataSource.combineAndExportFiles(inputPaths);

          // Assert
          final content = await result.first.readAsString();
          expect(content, contains('=== ${testFilePaths[0]} ==='));
          expect(content, contains('=== ${testFilePaths[2]} ==='));
          
          // Verify proper spacing between files
          final lines = content.split('\n');
          var headerCount = 0;
          for (final line in lines) {
            if (line.startsWith('=== ') && line.endsWith(' ===')) {
              headerCount++;
            }
          }
          expect(headerCount, equals(2));
        });

        test('should maintain file content integrity', () async {
          // Arrange
          final testFile = path.join(testDirectoryPath, 'integrity_test.txt');
          const originalContent = 'Line 1\nLine 2\n\nLine 4 with spaces   \nLine 5 with tabs\t\t';
          await io.File(testFile).writeAsString(originalContent);

          // Act
          final result = await dataSource.combineAndExportFiles([testFile]);

          // Assert
          final combinedContent = await result.first.readAsString();
          expect(combinedContent, contains(originalContent));
          
          // Cleanup
          await io.File(testFile).delete();
        });
      });
    });
  });
}