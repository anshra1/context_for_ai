import 'dart:convert';
import 'dart:io' as io;

import 'package:context_for_ai/features/code_combiner/data/datasources/file_system_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

/// Summary test showcasing the combineAndExportFiles functionality
/// 
/// This test demonstrates the complete workflow:
/// 1. Create test files with known content
/// 2. Set up SharedPreferences with app settings
/// 3. Call combineAndExportFiles with file paths
/// 4. Verify files are combined with proper headers
/// 5. Verify files are saved with timestamp naming
/// 6. Verify content splitting works when needed
void main() {
  group('CombineAndExportFiles - Complete Workflow Demo', () {
    late FileSystemDataSourceImpl dataSource;
    late io.Directory testDirectory;
    late io.Directory exportDirectory;
    late List<String> testFilePaths;

    setUpAll(() async {
      // Create test directory structure
      testDirectory = await io.Directory.systemTemp.createTemp('combine_demo_');
      exportDirectory = await io.Directory.systemTemp.createTemp('export_demo_');

      // Create sample files
      final file1 = io.File(path.join(testDirectory.path, 'sample.dart'));
      await file1.writeAsString('''
class HelloWorld {
  void greet() {
    print('Hello, World!');
  }
}
''');

      final file2 = io.File(path.join(testDirectory.path, 'config.json'));
      await file2.writeAsString('''
{
  "app_name": "Code Combiner",
  "version": "1.0.0",
  "debug": true
}
''');

      final file3 = io.File(path.join(testDirectory.path, 'README.md'));
      await file3.writeAsString('''
# Code Combiner Demo

This is a demonstration of the file combination functionality.

## Features
- Combines multiple files
- Adds path headers
- Handles file size limits
- Creates timestamped exports
''');

      testFilePaths = [file1.path, file2.path, file3.path];
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

      // Set up mock SharedPreferences with demo settings
      SharedPreferences.setMockInitialValues({
        'app_settings': jsonEncode({
          'fileSplitSizeInMB': 5,
          'maxTokenWarningLimit': 50000,
          'warnOnTokenExceed': true,
          'stripCommentsFromCode': false,
          'defaultExportLocation': exportDirectory.path,
        }),
      });
    });

    test('Complete workflow: combine files, create export, verify content', () async {
      // Act: Combine and export files
      final result = await dataSource.combineAndExportFiles(testFilePaths);

      // Assert: Verify export was created
      expect(result, isNotEmpty);
      expect(result.length, equals(1)); // Single file (content under 5MB limit)

      final exportedFile = result.first;
      expect(exportedFile.existsSync(), isTrue);
      expect(exportedFile.path, contains('combined_export_'));
      expect(exportedFile.path, endsWith('.txt'));

      // Verify content format and headers
      final content = await exportedFile.readAsString();
      
      // Check for proper file headers
      expect(content, contains('=== ${testFilePaths[0]} ==='));
      expect(content, contains('=== ${testFilePaths[1]} ==='));
      expect(content, contains('=== ${testFilePaths[2]} ==='));

      // Check for actual file content
      expect(content, contains('class HelloWorld'));
      expect(content, contains('"app_name": "Code Combiner"'));
      expect(content, contains('# Code Combiner Demo'));

      // Verify timestamp-based naming
      final filename = path.basename(exportedFile.path);
      final timestampPattern = RegExp(r'^combined_export_\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2}\.txt$');
      expect(filename, matches(timestampPattern));

      // Verify file is saved in correct export directory
      expect(exportedFile.path, startsWith(exportDirectory.path));

      print('✅ Successfully combined ${testFilePaths.length} files');
      print('📁 Export location: ${exportedFile.path}');
      print('📊 Combined content size: ${content.length} characters');
      print('🕒 Export filename: $filename');
    });

    test('Demonstrate file filtering capabilities', () async {
      // Create additional test files to demonstrate filtering
      final binaryFile = io.File(path.join(testDirectory.path, 'image.png'));
      await binaryFile.writeAsBytes([137, 80, 78, 71]); // PNG header

      final largeFile = io.File(path.join(testDirectory.path, 'large.txt'));
      await largeFile.writeAsString('X' * (6 * 1024 * 1024)); // 6MB (over limit)

      final allFiles = [...testFilePaths, binaryFile.path, largeFile.path];

      // Act: Try to combine all files (including problematic ones)
      final result = await dataSource.combineAndExportFiles(allFiles);

      // Assert: Only valid files should be included
      final content = await result.first.readAsString();
      
      // Valid files should be included
      expect(content, contains('class HelloWorld'));
      expect(content, contains('"app_name": "Code Combiner"'));
      
      // Binary and oversized files should be excluded
      expect(content, isNot(contains('image.png')));
      expect(content, isNot(contains('large.txt')));

      print('✅ Filtering demo: Processed ${allFiles.length} files');
      print('📋 Valid files included: 3');
      print('🚫 Files filtered out: 2 (binary + oversized)');
    });

    test('Demonstrate content splitting for large datasets', () async {
      // Create multiple large files to trigger splitting
      final largeFiles = <String>[];
      
      for (var i = 0; i < 3; i++) {
        final file = io.File(path.join(testDirectory.path, 'large_$i.txt'));
        final content = '''
File $i Content
${'=' * 50}
${'Large content block ' * 50000}
''';
        await file.writeAsString(content);
        largeFiles.add(file.path);
      }

      // Update settings for smaller split size to trigger splitting
      SharedPreferences.setMockInitialValues({
        'app_settings': jsonEncode({
          'fileSplitSizeInMB': 1, // 1MB limit to force splitting
          'maxTokenWarningLimit': 50000,
          'warnOnTokenExceed': true,
          'stripCommentsFromCode': false,
          'defaultExportLocation': exportDirectory.path,
        }),
      });

      // Act: Combine large files
      final result = await dataSource.combineAndExportFiles(largeFiles);

      // Assert: Should create multiple files due to size limit
      expect(result.length, greaterThan(1));

      // Verify each part is properly named
      for (var i = 0; i < result.length; i++) {
        final filename = path.basename(result[i].path);
        expect(filename, contains('_part${i + 1}.txt'));
        expect(result[i].existsSync(), isTrue);
      }

      print('✅ Splitting demo: Created ${result.length} parts');
      print('📂 Part files: ${result.map((f) => path.basename(f.path)).join(', ')}');
      
      // Cleanup large test files
      for (final filePath in largeFiles) {
        await io.File(filePath).delete();
      }
    });
  });
}