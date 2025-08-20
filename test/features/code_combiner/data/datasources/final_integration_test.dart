import 'dart:convert';
import 'dart:io' as io;

import 'package:context_for_ai/features/code_combiner/data/datasources/file_system_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

/// Final Integration Test: Combine real datasources with enhanced summary header
void main() {
  group('Final Enhanced Integration Test', () {
    late FileSystemDataSourceImpl dataSource;
    late String datasourcesPath;
    late List<String> datasourceFiles;

    setUpAll(() async {
      final currentDir = io.Directory.current;
      datasourcesPath = path.join(
        currentDir.path,
        'lib',
        'features',
        'code_combiner',
        'data',
        'datasources',
      );

      final datasourcesDir = io.Directory(datasourcesPath);
      final files = await datasourcesDir
          .list()
          .where((entity) => entity is io.File && entity.path.endsWith('_data_source.dart'))
          .cast<io.File>()
          .toList();

      datasourceFiles = files.map((file) => file.path).toList();
      datasourceFiles.sort();

      print('🔍 Found datasource files: ${datasourceFiles.length}');
    });

    setUp(() {
      dataSource = FileSystemDataSourceImpl();

      SharedPreferences.setMockInitialValues({
        'app_settings': jsonEncode({
          'fileSplitSizeInMB': 10,
          'maxTokenWarningLimit': 100000,
          'warnOnTokenExceed': true,
          'stripCommentsFromCode': false,
          'defaultExportLocation': datasourcesPath,
        }),
      });
    });

    test('Enhanced datasources combination with summary header', () async {
      // Add a non-existent file to demonstrate failure tracking
      final testFiles = [
        ...datasourceFiles,
        path.join(datasourcesPath, 'nonexistent_datasource.dart'), // Will fail
      ];

      // Act
      final result = await dataSource.combineAndExportFiles(testFiles);

      // Assert and demonstrate
      expect(result.totalFiles, equals(testFiles.length));
      expect(result.successfulCombinedFilesPaths.length, equals(datasourceFiles.length));
      expect(result.failedFiles, equals(1));

      final combinedFile = result.successedReturnedFiles.first;
      final content = await combinedFile.readAsString();

      print('\n🎯 Enhanced Datasources Export Results:');
      print('=' * 60);
      print('📁 Export File: ${path.basename(combinedFile.path)}');
      print('📊 Statistics:');
      print('  • Total Files Requested: ${result.totalFiles}');
      print('  • Successfully Combined: ${result.successfulCombinedFilesPaths.length}');
      print('  • Failed Files: ${result.failedFiles}');
      print('  • Estimated Tokens: ${result.estimatedTokenCount}');
      print('  • File Size: ${result.estimatedSizeInMB.toStringAsFixed(3)} MB');
      print('  • Output Parts: ${result.estimatedPartsCount}');

      print('\n📄 Summary Header Preview:');
      final lines = content.split('\n');
      var lineCount = 0;
      for (final line in lines) {
        lineCount++;
        print('${lineCount.toString().padLeft(2)}: $line');
        if (lineCount >= 20) break; // Show first 20 lines
      }
      print('... (content continues with actual file contents)');

      print('\n✅ Successful Files:');
      for (final filePath in result.successfulCombinedFilesPaths) {
        print('  • ${path.basename(filePath)}');
      }

      print('\n❌ Failed Files:');
      for (final filePath in result.failedFilePaths) {
        print('  • ${path.basename(filePath)}');
      }

      print('=' * 60);

      // Verify summary structure
      expect(content, contains('EXPORT SUMMARY'));
      expect(content, contains('Total Files Processed: ${testFiles.length}'));
      expect(content, contains('Successfully Combined: ${datasourceFiles.length} files'));
      expect(content, contains('Failed Files: 1 files'));
      expect(content, contains('SUCCESSFULLY COMBINED FILES:'));
      expect(content, contains('FAILED FILES:'));
      expect(content, contains('nonexistent_datasource.dart'));
      expect(content, contains('File not found'));
      expect(content, contains('COMBINED CONTENT:'));

      // Verify actual datasource content is included
      expect(content, contains('class FileSystemDataSourceImpl'));
      expect(content, contains('combineAndExportFiles'));

      print('\n🎉 Enhanced integration test completed successfully!');
      print('✅ Summary header with file tracking working perfectly');
      print('✅ ExportPreview with detailed statistics working');
      print('✅ Real-world datasource combination working');
    });
  });
}