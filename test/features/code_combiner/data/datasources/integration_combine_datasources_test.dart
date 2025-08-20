import 'dart:convert';
import 'dart:io' as io;

import 'package:context_for_ai/features/code_combiner/data/datasources/file_system_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

/// Integration Test: Combine All Datasource Files
/// 
/// This test demonstrates the real-world usage of combineAndExportFiles
/// by combining all actual datasource files from the project and saving
/// them back to the datasources directory.
/// 
/// Purpose:
/// - Show practical usage of the combine functionality
/// - Create a backup/reference of all datasource files
/// - Demonstrate the method working with actual project code
/// - Generate a combined file useful for code reviews or AI analysis
void main() {
  group('Integration Test - Combine All Datasources', () {
    late FileSystemDataSourceImpl dataSource;
    late String datasourcesPath;
    late List<String> datasourceFiles;

    setUpAll(() async {
      // Get the actual datasources directory path
      final currentDir = io.Directory.current;
      datasourcesPath = path.join(
        currentDir.path, 
        'lib', 
        'features', 
        'code_combiner', 
        'data', 
        'datasources'
      );

      print('🔍 Scanning datasources directory: $datasourcesPath');
      
      // Find all datasource files
      final datasourcesDir = io.Directory(datasourcesPath);
      if (!datasourcesDir.existsSync()) {
        throw Exception('Datasources directory not found: $datasourcesPath');
      }

      final files = await datasourcesDir
          .list()
          .where((entity) => entity is io.File && entity.path.endsWith('_data_source.dart'))
          .cast<io.File>()
          .toList();

      datasourceFiles = files.map((file) => file.path).toList();
      datasourceFiles.sort(); // Sort for consistent ordering

      print('📁 Found ${datasourceFiles.length} datasource files:');
      for (final file in datasourceFiles) {
        final filename = path.basename(file);
        final size = await io.File(file).length();
        print('  • $filename (${_formatBytes(size)})');
      }
    });

    setUp(() {
      dataSource = FileSystemDataSourceImpl();

      // Set up SharedPreferences with realistic settings
      SharedPreferences.setMockInitialValues({
        'app_settings': jsonEncode({
          'fileSplitSizeInMB': 10, // 10MB should be enough for all datasources
          'maxTokenWarningLimit': 100000,
          'warnOnTokenExceed': true,
          'stripCommentsFromCode': false,
          'defaultExportLocation': datasourcesPath, // Save back to datasources folder
        }),
      });
    });

    test('Combine all datasource files and save to datasources directory', () async {
      // Verify we have files to combine
      expect(datasourceFiles, isNotEmpty, reason: 'Should find at least one datasource file');
      
      print('\n🚀 Starting combination process...');
      print('📄 Files to combine: ${datasourceFiles.length}');

      // Act: Combine all datasource files
      final stopwatch = Stopwatch()..start();
      final result = await dataSource.combineAndExportFiles(datasourceFiles);
      stopwatch.stop();

      // Assert: Verify the combination was successful
      expect(result, isNotEmpty, reason: 'Should create at least one combined file');
      
      final combinedFile = result.first;
      expect(combinedFile.existsSync(), isTrue, reason: 'Combined file should exist');
      expect(combinedFile.path, startsWith(datasourcesPath), 
          reason: 'File should be saved in datasources directory');

      // Verify filename format (the method uses 'combined_export_' prefix)
      final filename = path.basename(combinedFile.path);
      expect(filename, matches(RegExp(r'^combined_export_\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2}\.txt$')),
          reason: 'Should have correct timestamp format');

      // Read and verify the combined content
      final content = await combinedFile.readAsString();
      expect(content.isNotEmpty, isTrue, reason: 'Combined file should have content');

      // Verify each datasource file is included with proper headers
      for (final filePath in datasourceFiles) {
        final expectedHeader = '=== $filePath ===';
        expect(content, contains(expectedHeader), 
            reason: 'Should contain header for $filePath');
        
        // Verify actual file content is included
        final originalContent = await io.File(filePath).readAsString();
        final significantPortion = originalContent.substring(
          0, 
          originalContent.length > 100 ? 100 : originalContent.length
        ).trim();
        
        if (significantPortion.isNotEmpty) {
          expect(content, contains(significantPortion), 
              reason: 'Should contain content from ${path.basename(filePath)}');
        }
      }

      // Performance validation
      expect(stopwatch.elapsedMilliseconds, lessThan(10000), 
          reason: 'Should complete within 10 seconds');

      // Calculate statistics
      final totalLines = content.split('\n').length;
      final totalSize = content.length;
      final fileSize = await combinedFile.length();

      print('\n✅ SUCCESS! Combined datasources created');
      print('📁 Location: ${combinedFile.path}');
      print('📊 Statistics:');
      print('  • Source files: ${datasourceFiles.length}');
      print('  • Combined size: ${_formatBytes(fileSize)}');
      print('  • Total lines: $totalLines');
      print('  • Processing time: ${stopwatch.elapsedMilliseconds}ms');
      print('  • Output parts: ${result.length}');

      if (result.length > 1) {
        print('  • Part files:');
        for (var i = 0; i < result.length; i++) {
          final partFile = result[i];
          final partSize = await partFile.length();
          print('    - Part ${i + 1}: ${path.basename(partFile.path)} (${_formatBytes(partSize)})');
        }
      }

      print('\n🎯 Use Case Examples:');
      print('  • Code review: Share complete datasource context');
      print('  • AI analysis: Upload combined file to ChatGPT/Claude');
      print('  • Documentation: Reference all datasource implementations');
      print('  • Backup: Archive all datasource code in one file');
    });

    test('Verify individual datasource file integrity', () async {
      // This test ensures each datasource file is readable and valid
      for (final filePath in datasourceFiles) {
        final file = io.File(filePath);
        expect(file.existsSync(), isTrue, reason: 'File should exist: $filePath');
        
        final content = await file.readAsString();
        expect(content.isNotEmpty, isTrue, reason: 'File should not be empty: $filePath');
        
        // Basic Dart file validation
        expect(content, contains('class'), 
            reason: 'Should contain class definition: ${path.basename(filePath)}');
        
        final filename = path.basename(filePath);
        print('✅ Validated: $filename');
      }
      
      print('\n📋 All ${datasourceFiles.length} datasource files validated successfully');
    });

    test('Demonstrate content preview of combined output', () async {
      // Create the combined file and show a preview
      final result = await dataSource.combineAndExportFiles(datasourceFiles);
      final content = await result.first.readAsString();
      
      // Extract preview (first 1000 characters)
      final preview = content.length > 1000 
          ? '${content.substring(0, 1000)}...[TRUNCATED]' 
          : content;
      
      print('\n📄 Combined File Preview:');
      print('=' * 60);
      print(preview);
      print('=' * 60);
      
      // Count headers to verify all files are included (only count line-start headers)
      final headerCount = RegExp(r'^=== .* ===$', multiLine: true).allMatches(content).length;
      expect(headerCount, equals(datasourceFiles.length), 
          reason: 'Should have header for each datasource file');
      
      print('\n📈 Content Analysis:');
      print('  • Headers found: $headerCount');
      print('  • Expected files: ${datasourceFiles.length}');
      print('  • Match: ${headerCount == datasourceFiles.length ? "✅" : "❌"}');
    });
  });
}

/// Helper function to format bytes in human-readable format
String _formatBytes(int bytes) {
  if (bytes < 1024) return '${bytes}B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
  if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
}