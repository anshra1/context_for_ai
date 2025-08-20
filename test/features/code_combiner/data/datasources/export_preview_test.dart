import 'dart:convert';
import 'dart:io' as io;

import 'package:context_for_ai/features/code_combiner/data/datasources/file_system_data_source.dart';
import 'package:context_for_ai/features/code_combiner/data/models/export_preview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

/// Test for the updated combineAndExportFiles method that returns ExportPreview
void main() {
  group('ExportPreview Integration Test', () {
    late FileSystemDataSourceImpl dataSource;
    late io.Directory testDirectory;
    late io.Directory exportDirectory;

    setUpAll(() async {
      testDirectory = await io.Directory.systemTemp.createTemp('export_preview_test_');
      exportDirectory = await io.Directory.systemTemp.createTemp('export_output_');

      // Create test files
      await io.File(path.join(testDirectory.path, 'file1.dart'))
          .writeAsString('class TestClass1 { void method() {} }');
      await io.File(path.join(testDirectory.path, 'file2.txt'))
          .writeAsString('Sample text content for testing');
      await io.File(path.join(testDirectory.path, 'file3.json'))
          .writeAsString('{"test": "json", "data": 123}');

      // Create a binary file that should be skipped
      await io.File(path.join(testDirectory.path, 'binary.exe'))
          .writeAsBytes([0x4D, 0x5A, 0x90, 0x00]);

      // Create a non-existent file path for testing failures
    });

    tearDownAll(() async {
      if (testDirectory.existsSync()) {
        await testDirectory.delete(recursive: true);
      }
      if (exportDirectory.existsSync()) {
        await exportDirectory.delete(recursive: true);
      }
    });

    setUp(() {
      dataSource = FileSystemDataSourceImpl();

      SharedPreferences.setMockInitialValues({
        'app_settings': jsonEncode({
          'fileSplitSizeInMB': 1,
          'maxTokenWarningLimit': 10000,
          'warnOnTokenExceed': true,
          'stripCommentsFromCode': false,
          'defaultExportLocation': exportDirectory.path,
        }),
      });
    });

    test('should return detailed ExportPreview with all statistics', () async {
      // Arrange
      final testFiles = [
        path.join(testDirectory.path, 'file1.dart'),
        path.join(testDirectory.path, 'file2.txt'),
        path.join(testDirectory.path, 'file3.json'),
        path.join(testDirectory.path, 'binary.exe'), // Should be skipped
        path.join(testDirectory.path, 'nonexistent.txt'), // Should fail
      ];

      // Act
      final result = await dataSource.combineAndExportFiles(testFiles);

      // Assert
      expect(result, isA<ExportPreview>());

      // Verify statistics
      expect(result.totalFiles, equals(5));
      expect(result.failedFiles, equals(2)); // binary.exe + nonexistent.txt
      expect(result.successfulCombinedFilesPaths.length, equals(3)); // 3 valid files
      expect(result.successedReturnedFiles, isNotEmpty);

      // Verify failed files are tracked
      expect(result.failedFilePaths, contains(path.join(testDirectory.path, 'binary.exe')));
      expect(result.failedFilePaths, contains(path.join(testDirectory.path, 'nonexistent.txt')));

      // Verify successful files are tracked
      expect(result.successfulCombinedFilesPaths, contains(path.join(testDirectory.path, 'file1.dart')));
      expect(result.successfulCombinedFilesPaths, contains(path.join(testDirectory.path, 'file2.txt')));
      expect(result.successfulCombinedFilesPaths, contains(path.join(testDirectory.path, 'file3.json')));

      // Verify estimated calculations
      expect(result.estimatedTokenCount, greaterThan(0));
      expect(result.estimatedSizeInMB, greaterThan(0));
      expect(result.estimatedPartsCount, equals(1)); // Should be 1 part (small files)

      // Verify created files exist
      expect(result.successedReturnedFiles.length, equals(1));
      expect(result.successedReturnedFiles.first.existsSync(), isTrue);

      print('✅ ExportPreview Results:');
      print('  📊 Total files: ${result.totalFiles}');
      print('  ✅ Successful: ${result.successfulCombinedFilesPaths.length}');
      print('  ❌ Failed: ${result.failedFiles}');
      print('  🎯 Estimated tokens: ${result.estimatedTokenCount}');
      print('  📏 Estimated size: ${result.estimatedSizeInMB.toStringAsFixed(3)} MB');
      print('  📄 Parts: ${result.estimatedPartsCount}');
      print('  💾 Created files: ${result.successedReturnedFiles.length}');
    });

    test('should handle empty file list correctly', () async {
      // Arrange
      final emptyFileList = <String>[];

      // Act
      final result = await dataSource.combineAndExportFiles(emptyFileList);

      // Assert
      expect(result.totalFiles, equals(0));
      expect(result.failedFiles, equals(0));
      expect(result.successfulCombinedFilesPaths, isEmpty);
      expect(result.estimatedTokenCount, equals(0));
      expect(result.estimatedSizeInMB, equals(0));
      expect(result.estimatedPartsCount, equals(1)); // Always at least 1 part
      expect(result.successedReturnedFiles, isNotEmpty); // Empty file still created
    });

    test('should calculate token estimation correctly', () async {
      // Arrange - Create file with known content
      const testContent = 'This is a test sentence with exactly twenty five words to verify token count estimation works correctly and precisely for our testing purposes.';
      final testFile = path.join(testDirectory.path, 'token_test.txt');
      await io.File(testFile).writeAsString(testContent);

      // Act
      final result = await dataSource.combineAndExportFiles([testFile]);

      // Assert
      final expectedTokens = (testContent.length / 4).round(); // Our approximation
      expect(result.estimatedTokenCount, greaterThanOrEqualTo(expectedTokens));
      expect(result.estimatedTokenCount, greaterThan(20)); // Should be reasonable for the content

      print('📝 Token Estimation Test:');
      print('  Content length: ${testContent.length} chars');
      print('  Estimated tokens: ${result.estimatedTokenCount}');
      print('  Ratio: ${(testContent.length / result.estimatedTokenCount).toStringAsFixed(1)} chars/token');
    });

    test('should demonstrate comprehensive export preview functionality', () async {
      // Arrange - Create a mix of files including some that will fail
      final mixedFiles = [
        path.join(testDirectory.path, 'file1.dart'),
        path.join(testDirectory.path, 'file2.txt'),
        path.join(testDirectory.path, 'binary.exe'), // Will fail (binary)
        '/nonexistent/path/file.txt', // Will fail (doesn't exist)
      ];

      // Act
      final result = await dataSource.combineAndExportFiles(mixedFiles);

      // Assert & Demonstrate
      print('\n🎯 Comprehensive ExportPreview Demo:');
      print('=' * 50);
      print('📁 Input Analysis:');
      print('  • Total files requested: ${result.totalFiles}');
      print('  • Files successfully processed: ${result.successfulCombinedFilesPaths.length}');
      print('  • Files that failed: ${result.failedFiles}');
      
      print('\n📊 Content Statistics:');
      print('  • Estimated tokens: ${result.estimatedTokenCount}');
      print('  • Estimated size: ${result.estimatedSizeInMB.toStringAsFixed(3)} MB');
      print('  • Output parts: ${result.estimatedPartsCount}');
      
      print('\n✅ Successful Files:');
      for (final filePath in result.successfulCombinedFilesPaths) {
        print('  • ${path.basename(filePath)}');
      }
      
      print('\n❌ Failed Files:');
      for (final filePath in result.failedFilePaths) {
        print('  • ${path.basename(filePath)}');
      }
      
      print('\n💾 Output Files:');
      for (final file in result.successedReturnedFiles) {
        final size = await file.length();
        print('  • ${path.basename(file.path)} ($size bytes)');
      }
      print('=' * 50);

      // Verify the structure makes sense
      expect(result.totalFiles, equals(mixedFiles.length));
      expect(result.successfulCombinedFilesPaths.length + result.failedFiles, equals(result.totalFiles));
      expect(result.failedFilePaths.length, equals(result.failedFiles));
    });
  });
}