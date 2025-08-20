import 'dart:convert';
import 'dart:io' as io;

import 'package:context_for_ai/features/code_combiner/data/datasources/file_system_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

/// Test the enhanced combineAndExportFiles with summary header functionality
void main() {
  group('Summary Header Test', () {
    late FileSystemDataSourceImpl dataSource;
    late io.Directory testDirectory;
    late io.Directory exportDirectory;

    setUpAll(() async {
      testDirectory = await io.Directory.systemTemp.createTemp('summary_test_');
      exportDirectory = await io.Directory.systemTemp.createTemp('summary_output_');

      // Create test files
      await io.File(path.join(testDirectory.path, 'success1.dart'))
          .writeAsString('void main() { print("Hello World"); }');
      await io.File(path.join(testDirectory.path, 'success2.txt'))
          .writeAsString('This is a successful text file');
      await io.File(path.join(testDirectory.path, 'success3.json'))
          .writeAsString('{"status": "success", "data": [1,2,3]}');
      
      // Create a binary file that will fail
      await io.File(path.join(testDirectory.path, 'binary.exe'))
          .writeAsBytes([0x4D, 0x5A, 0x90, 0x00]);
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
          'fileSplitSizeInMB': 10,
          'maxTokenWarningLimit': 50000,
          'warnOnTokenExceed': true,
          'stripCommentsFromCode': false,
          'defaultExportLocation': exportDirectory.path,
        }),
      });
    });

    test('should include summary header with successful and failed files', () async {
      // Arrange - Mix of successful and failing files
      final testFiles = [
        path.join(testDirectory.path, 'success1.dart'),
        path.join(testDirectory.path, 'success2.txt'),
        path.join(testDirectory.path, 'success3.json'),
        path.join(testDirectory.path, 'binary.exe'), // Will fail - binary
        path.join(testDirectory.path, 'nonexistent.txt'), // Will fail - doesn't exist
      ];

      // Act
      final result = await dataSource.combineAndExportFiles(testFiles);

      // Assert
      expect(result.successedReturnedFiles, isNotEmpty);
      final combinedFile = result.successedReturnedFiles.first;
      final content = await combinedFile.readAsString();

      print('\n📄 Generated Combined File Content:');
      print('=' * 80);
      print(content);
      print('=' * 80);

      // Verify summary header is present
      expect(content, contains('EXPORT SUMMARY'));
      expect(content, contains('=============='));
      expect(content, contains('Total Files Processed: 5'));
      expect(content, contains('Successfully Combined: 3 files'));
      expect(content, contains('Failed Files: 2 files'));

      // Verify successful files section
      expect(content, contains('SUCCESSFULLY COMBINED FILES:'));
      expect(content, contains('✅'));
      expect(content, contains('success1.dart'));
      expect(content, contains('success2.txt'));
      expect(content, contains('success3.json'));

      // Verify failed files section with reasons
      expect(content, contains('FAILED FILES:'));
      expect(content, contains('❌'));
      expect(content, contains('binary.exe'));
      expect(content, contains('Binary file - skipped'));
      expect(content, contains('nonexistent.txt'));
      expect(content, contains('File not found'));

      // Verify combined content separator
      expect(content, contains('COMBINED CONTENT:'));
      expect(content, contains('================='));

      // Verify actual file content is still there
      expect(content, contains('=== '));
      expect(content, contains('void main() { print("Hello World"); }'));
      expect(content, contains('This is a successful text file'));
      expect(content, contains('{"status": "success", "data": [1,2,3]}'));
    });

    test('should show correct format for all successful files', () async {
      // Arrange - Only successful files
      final successfulFiles = [
        path.join(testDirectory.path, 'success1.dart'),
        path.join(testDirectory.path, 'success2.txt'),
      ];

      // Act
      final result = await dataSource.combineAndExportFiles(successfulFiles);

      // Assert
      final content = await result.successedReturnedFiles.first.readAsString();

      print('\n📄 All Successful Files Format:');
      print('=' * 60);
      print(content.split('COMBINED CONTENT:')[0]); // Show only summary part
      print('=' * 60);

      // Should show no failed files
      expect(content, contains('Total Files Processed: 2'));
      expect(content, contains('Successfully Combined: 2 files'));
      expect(content, contains('Failed Files: 0 files'));
      expect(content, isNot(contains('FAILED FILES:')));
      
      // Should have successful files section
      expect(content, contains('SUCCESSFULLY COMBINED FILES:'));
      expect(content, contains('success1.dart'));
      expect(content, contains('success2.txt'));
    });

    test('should handle all failed files correctly', () async {
      // Arrange - Only files that will fail
      final failedFiles = [
        path.join(testDirectory.path, 'binary.exe'), // Binary file
        path.join(testDirectory.path, 'missing1.txt'), // Doesn't exist
        path.join(testDirectory.path, 'missing2.json'), // Doesn't exist
      ];

      // Act
      final result = await dataSource.combineAndExportFiles(failedFiles);

      // Assert
      final content = await result.successedReturnedFiles.first.readAsString();

      print('\n📄 All Failed Files Format:');
      print('=' * 60);
      print(content.split('COMBINED CONTENT:')[0]); // Show only summary part
      print('=' * 60);

      // Should show all files failed
      expect(content, contains('Total Files Processed: 3'));
      expect(content, contains('Successfully Combined: 0 files'));
      expect(content, contains('Failed Files: 3 files'));
      expect(content, isNot(contains('SUCCESSFULLY COMBINED FILES:')));
      
      // Should have detailed failed files section
      expect(content, contains('FAILED FILES:'));
      expect(content, contains('binary.exe'));
      expect(content, contains('Binary file - skipped'));
      expect(content, contains('missing1.txt'));
      expect(content, contains('File not found'));
    });

    test('should demonstrate complete workflow with summary', () async {
      // Arrange - Realistic mix of files
      final mixedFiles = [
        path.join(testDirectory.path, 'success1.dart'),
        path.join(testDirectory.path, 'success2.txt'),
        path.join(testDirectory.path, 'binary.exe'),
      ];

      // Act
      final result = await dataSource.combineAndExportFiles(mixedFiles);

      // Assert & Demonstrate
      final content = await result.successedReturnedFiles.first.readAsString();
      
      print('\n🎯 Complete Workflow Demo:');
      print('📁 Export Location: ${result.successedReturnedFiles.first.path}');
      print('📊 ExportPreview Stats:');
      print('  • Total Files: ${result.totalFiles}');
      print('  • Successful: ${result.successfulCombinedFilesPaths.length}');
      print('  • Failed: ${result.failedFiles}');
      print('  • Estimated Tokens: ${result.estimatedTokenCount}');
      print('  • File Size: ${result.estimatedSizeInMB.toStringAsFixed(3)} MB');
      
      print('\n📄 File Content Preview:');
      final lines = content.split('\n');
      for (var i = 0; i < (lines.length > 20 ? 20 : lines.length); i++) {
        print('${(i + 1).toString().padLeft(2)}: ${lines[i]}');
      }
      if (lines.length > 20) print('... (truncated ${lines.length - 20} more lines)');

      // Verify comprehensive functionality
      expect(result.totalFiles, equals(3));
      expect(result.successfulCombinedFilesPaths.length, equals(2));
      expect(result.failedFiles, equals(1));
      expect(content, contains('EXPORT SUMMARY'));
      expect(content, contains('SUCCESSFULLY COMBINED FILES:'));
      expect(content, contains('FAILED FILES:'));
      expect(content, contains('COMBINED CONTENT:'));
    });
  });
}