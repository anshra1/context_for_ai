import 'dart:convert';
import 'dart:io' as io;

import 'package:context_for_ai/features/code_combiner/data/datasources/file_system_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

/// Complete Lib Folder Combination Test
///
/// This test demonstrates the ultimate use case of combineAndExportFiles:
/// - Scans the entire /lib folder recursively
/// - Finds ALL Dart files in the project
/// - Combines them into one comprehensive file
/// - Saves the result in the lib folder itself
/// - Provides complete project statistics and overview
void main() {
  group('Complete Lib Folder Combination', () {
    late FileSystemDataSourceImpl dataSource;
    late String libFolderPath;
    late List<String> allDartFiles;

    setUpAll(() async {
      // Get the lib folder path
      final currentDir = io.Directory.current;
      libFolderPath = path.join(currentDir.path, 'lib');

      print('🔍 Scanning lib folder: $libFolderPath');

      // Recursively find all Dart files in lib folder
      allDartFiles = await _findAllDartFiles(libFolderPath);
      allDartFiles.sort(); // Sort for consistent ordering

      print('📁 Found ${allDartFiles.length} Dart files in lib/ folder:');

      // Group files by directory for better overview
      final filesByDirectory = <String, List<String>>{};
      for (final filePath in allDartFiles) {
        final dir = path.dirname(path.relative(filePath, from: libFolderPath));
        filesByDirectory.putIfAbsent(dir, () => []).add(path.basename(filePath));
      }

      // Display organized file structure
      for (final entry in filesByDirectory.entries) {
        final dirName = entry.key == '.' ? 'lib/' : 'lib/${entry.key}/';
        print('  📂 $dirName (${entry.value.length} files)');
        for (final fileName in entry.value.take(3)) {
          print('    • $fileName');
        }
        if (entry.value.length > 3) {
          print('    • ... and ${entry.value.length - 3} more files');
        }
      }
    });

    setUp(() {
      dataSource = FileSystemDataSourceImpl();

      // Configure for large project combination
      SharedPreferences.setMockInitialValues({
        'app_settings': jsonEncode({
          'fileSplitSizeInMB': 50, // Large limit for complete project
          'maxTokenWarningLimit': 500000,
          'warnOnTokenExceed': true,
          'stripCommentsFromCode': false,
          'defaultExportLocation': libFolderPath, // Save in lib folder
        }),
      });
    });

    test('Combine entire lib folder into single comprehensive file', () async {
      // Ensure we have files to process
      expect(allDartFiles, isNotEmpty, reason: 'Should find Dart files in lib folder');

      print('\n🚀 Starting complete lib folder combination...');
      print('📊 Processing ${allDartFiles.length} Dart files');

      // Act: Combine the entire lib folder
      final stopwatch = Stopwatch()..start();
      final result = await dataSource.combineAndExportFiles(allDartFiles);
      stopwatch.stop();

      // Assert: Verify the combination was successful
      expect(result.totalFiles, equals(allDartFiles.length));
      expect(result.successedReturnedFiles, isNotEmpty);

      final combinedFile = result.successedReturnedFiles.first;
      expect(combinedFile.existsSync(), isTrue);
      expect(combinedFile.path, startsWith(libFolderPath));

      // Read and analyze the combined content
      final content = await combinedFile.readAsString();
      final fileSize = await combinedFile.length();

      print('\n✅ COMPLETE LIB COMBINATION SUCCESS!');
      print('=' * 80);
      print('📁 Combined File Location: ${combinedFile.path}');
      print('📊 Project Statistics:');
      print('  • Total Dart Files: ${result.totalFiles}');
      print('  • Successfully Combined: ${result.successfulCombinedFilesPaths.length}');
      print('  • Failed Files: ${result.failedFiles}');
      print('  • Estimated Tokens: ${result.estimatedTokenCount}');
      print(
        '  • Combined File Size: ${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB',
      );
      print('  • Processing Time: ${stopwatch.elapsedMilliseconds}ms');
      print('  • Output Parts: ${result.estimatedPartsCount}');

      if (result.failedFiles > 0) {
        print('\n❌ Failed Files:');
        for (final failedPath in result.failedFilePaths) {
          print('  • ${path.relative(failedPath, from: libFolderPath)}');
        }
      }

      print('\n📈 Content Analysis:');
      final lines = content.split('\n');
      print('  • Total Lines: ${lines.length}');
      print('  • Characters: ${content.length}');

      // Count different types of content
      var importCount = 0;
      var classCount = 0;
      var functionCount = 0;
      var commentLines = 0;

      for (final line in lines) {
        final trimmedLine = line.trim();
        if (trimmedLine.startsWith('import ')) importCount++;
        if (trimmedLine.startsWith('class ')) classCount++;
        if (trimmedLine.contains(' class ')) classCount++;
        if (trimmedLine.startsWith('void ') || trimmedLine.startsWith('Future<'))
          functionCount++;
        if (trimmedLine.startsWith('//') || trimmedLine.startsWith('/*')) commentLines++;
      }

      print('  • Import statements: $importCount');
      print('  • Class definitions: $classCount');
      print('  • Function definitions: ~$functionCount');
      print('  • Comment lines: $commentLines');

      print('\n📄 File Structure Overview:');
      final headerLines = content.split('COMBINED CONTENT:')[0].split('\n');
      var inSuccessSection = false;
      var successCount = 0;

      for (final line in headerLines) {
        if (line.contains('SUCCESSFULLY COMBINED FILES:')) {
          inSuccessSection = true;
          continue;
        }
        if (line.contains('FAILED FILES:')) {
          inSuccessSection = false;
        }
        if (inSuccessSection && line.startsWith('✅')) {
          successCount++;
          if (successCount <= 5) {
            final fileName = path.basename(line.substring(line.lastIndexOf('/') + 1));
            print('  ✅ $fileName');
          }
        }
      }
      if (successCount > 5) {
        print('  ... and ${successCount - 5} more files');
      }

      print('\n🎯 Use Cases for This Combined File:');
      print('  • 🤖 AI Analysis: Upload to ChatGPT/Claude for project review');
      print('  • 👥 Code Review: Share complete project context with team');
      print('  • 📚 Documentation: Reference entire codebase in one file');
      print('  • 💾 Backup: Complete project snapshot with processing details');
      print('  • 🔍 Search: Grep through entire project in single file');

      print('\n📁 Output File Details:');
      print('  • Filename: ${path.basename(combinedFile.path)}');
      print('  • Full Path: ${combinedFile.path}');
      print('  • Size on Disk: $fileSize bytes');
      print('=' * 80);

      // Verify the structure and content
      expect(content, contains('EXPORT SUMMARY'));
      expect(content, contains('SUCCESSFULLY COMBINED FILES:'));
      expect(content, contains('COMBINED CONTENT:'));
      expect(content, contains('main.dart'), reason: 'Should include main.dart');
      expect(content, contains('class'), reason: 'Should contain class definitions');

      // Performance validation
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(30000),
        reason: 'Should complete within 30 seconds',
      );

      print('\n🎉 Complete lib folder combination test PASSED!');
      print('✅ Your entire Flutter project is now combined in one file');
      print('✅ Summary header shows detailed processing information');
      print('✅ File saved in lib/ folder for easy access');
    });

    test('Verify file content integrity and structure', () async {
      // Create a smaller test to verify specific content is preserved
      final testFiles = allDartFiles.take(5).toList(); // Test with first 5 files

      final result = await dataSource.combineAndExportFiles(testFiles);
      final content = await result.successedReturnedFiles.first.readAsString();

      // Verify each test file's content is preserved
      for (final filePath in testFiles) {
        final originalContent = await io.File(filePath).readAsString();
        expect(
          content,
          contains(originalContent.trim()),
          reason: 'Should preserve content from ${path.basename(filePath)}',
        );
      }

      print('✅ File content integrity verified');
    });

    test('Analyze project structure and provide insights', () async {
      // Analyze the project structure
      final featureFiles = allDartFiles.where((f) => f.contains('/features/')).length;
      final coreFiles = allDartFiles.where((f) => f.contains('/core/')).length;
      final testFiles = allDartFiles.where((f) => f.contains('/test/')).length;
      final dataFiles = allDartFiles.where((f) => f.contains('/data/')).length;
      final domainFiles = allDartFiles.where((f) => f.contains('/domain/')).length;
      final presentationFiles = allDartFiles
          .where((f) => f.contains('/presentation/'))
          .length;

      print('\n📊 Project Architecture Analysis:');
      print('  • Total Files: ${allDartFiles.length}');
      print('  • Features Layer: $featureFiles files');
      print('  • Core Layer: $coreFiles files');
      print('  • Data Layer: $dataFiles files');
      print('  • Domain Layer: $domainFiles files');
      print('  • Presentation Layer: $presentationFiles files');
      print('  • Test Files: $testFiles files');

      // Calculate architecture ratio
      final totalArchFiles = dataFiles + domainFiles + presentationFiles;
      if (totalArchFiles > 0) {
        print('\n🏗️ Clean Architecture Compliance:');
        print('  • Data: ${(dataFiles / totalArchFiles * 100).toStringAsFixed(1)}%');
        print('  • Domain: ${(domainFiles / totalArchFiles * 100).toStringAsFixed(1)}%');
        print(
          '  • Presentation: ${(presentationFiles / totalArchFiles * 100).toStringAsFixed(1)}%',
        );
      }

      expect(
        allDartFiles.length,
        greaterThan(10),
        reason: 'Project should have a reasonable number of files',
      );
    });
  });
}

/// Helper function to recursively find all Dart files in a directory
Future<List<String>> _findAllDartFiles(String directoryPath) async {
  final dartFiles = <String>[];
  final directory = io.Directory(directoryPath);

  if (!directory.existsSync()) {
    return dartFiles;
  }

  await for (final entity in directory.list(recursive: true)) {
    if (entity is io.File && entity.path.endsWith('.dart')) {
      // Skip generated files and test files for cleaner combination
      final relativePath = path.relative(entity.path, from: directoryPath);
      if (!relativePath.contains('.g.dart') &&
          !relativePath.contains('.freezed.dart') &&
          !relativePath.startsWith('test/')) {
        dartFiles.add(entity.path);
      }
    }
  }

  return dartFiles;
}
