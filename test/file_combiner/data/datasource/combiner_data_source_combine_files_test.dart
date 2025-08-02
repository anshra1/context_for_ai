import 'dart:io' as io;

import 'package:context_for_ai/core/error/exception.dart';
import 'package:context_for_ai/features/file_combiner/data/datasource/combiner_data_source.dart';
import 'package:context_for_ai/features/file_combiner/domain/hive_model/workspace_entry_hive.dart';
import 'package:context_for_ai/features/setting/data/datasource/setting_datasource.dart';
import 'package:context_for_ai/features/setting/model/app_setting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as path;

class MockBox extends Mock implements Box<WorkspaceEntryHive> {}
class MockSettingsDataSource extends Mock implements SettingsDataSource {}

void main() {
  setUpAll(() {
    // Register fallback values for custom types
    registerFallbackValue(WorkspaceEntryHive(
      uuid: 'fallback-uuid',
      path: '/fallback/path',
      isFavorite: false,
      lastAccessedAt: DateTime.now(),
    ));
    registerFallbackValue(AppSettings.defaultSettings());
  });

  late CombinerDataSourceImpl dataSource;
  late MockBox mockBox;
  late MockSettingsDataSource mockSettingsDataSource;
  late io.Directory tempDir;

  setUp(() async {
    mockBox = MockBox();
    mockSettingsDataSource = MockSettingsDataSource();
    dataSource = CombinerDataSourceImpl(
      workspaceBox: mockBox,
      settingsDataSource: mockSettingsDataSource,
    );

    // Create temporary directory for testing
    tempDir = await io.Directory.systemTemp.createTemp('combiner_test_');
  });

  tearDown(() async {
    // Always cleanup temporary directory
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('combineFiles', () {
    group('validation', () {
      test('should throw ValidationException for empty file paths list', () async {
        // Arrange
        final emptyPaths = <String>[];

        // Act & Assert
        expect(
          () => dataSource.combineFiles(emptyPaths),
          throwsA(
            isA<ValidationException>()
                .having((e) => e.userMessage, 'userMessage', 'No files provided to combine')
                .having((e) => e.methodName, 'methodName', 'combineFiles')
                .having((e) => e.isRecoverable, 'isRecoverable', false),
          ),
        );
      });
    });

    group('success cases', () {
      test('should combine single file without stripping comments', () async {
        // Arrange
        final testFile = io.File('${tempDir.path}/test.dart');
        await testFile.create();
        await testFile.writeAsString('''
// This is a comment
class TestClass {
  // Another comment
  void method() {
    print('Hello World');
  }
}
''');

        final settings = AppSettings.defaultSettings().copyWith(
          stripComments: false,
          maxTokenCount: 1000,
        );

        when(() => mockSettingsDataSource.loadSettings())
            .thenAnswer((_) async => settings);

        // Act
        final result = await dataSource.combineFiles([testFile.path]);

        // Assert
        expect(result, isA<CombineFilesResult>());
        expect(result.totalFiles, equals(1));
        expect(result.files, hasLength(1));
        expect(result.saveLocation, contains('ai_context'));

        // Verify file content includes header and comments
        final combinedContent = await result.files.first.readAsString();
        expect(combinedContent, contains('COMBINED FILES SUMMARY'));
        expect(combinedContent, contains('Total files: 1'));
        expect(combinedContent, contains('// This is a comment'));
        expect(combinedContent, contains('// Another comment'));
        expect(combinedContent, contains('class TestClass'));

        verify(() => mockSettingsDataSource.loadSettings()).called(1);
      });

      test('should combine single file with comment stripping', () async {
        // Arrange
        final testFile = io.File('${tempDir.path}/test.dart');
        await testFile.create();
        await testFile.writeAsString('''
// This is a comment
class TestClass {
  // Another comment
  void method() {
    print('Hello World');
  }
}
''');

        final settings = AppSettings.defaultSettings().copyWith(
          stripComments: true,
          maxTokenCount: 1000,
        );

        when(() => mockSettingsDataSource.loadSettings())
            .thenAnswer((_) async => settings);

        // Act
        final result = await dataSource.combineFiles([testFile.path]);

        // Assert
        expect(result, isA<CombineFilesResult>());
        expect(result.totalFiles, equals(1));

        // Verify file content has comments stripped but preserves non-comment lines
        final combinedContent = await result.files.first.readAsString();
        expect(combinedContent, contains('COMBINED FILES SUMMARY'));
        expect(combinedContent, contains('Total files: 1'));
        expect(combinedContent, isNot(contains('// This is a comment')));
        expect(combinedContent, isNot(contains('// Another comment')));
        expect(combinedContent, contains('class TestClass'));
        expect(combinedContent, contains("print('Hello World');"));

        verify(() => mockSettingsDataSource.loadSettings()).called(1);
      });

      test('should combine multiple files with correct header', () async {
        // Arrange
        final file1 = io.File('${tempDir.path}/file1.dart');
        final file2 = io.File('${tempDir.path}/file2.dart');
        await file1.create();
        await file2.create();
        await file1.writeAsString('class File1 {}');
        await file2.writeAsString('class File2 {}');

        final settings = AppSettings.defaultSettings().copyWith(
          stripComments: false,
          maxTokenCount: 1000,
        );

        when(() => mockSettingsDataSource.loadSettings())
            .thenAnswer((_) async => settings);

        // Act
        final result = await dataSource.combineFiles([file1.path, file2.path]);

        // Assert
        expect(result, isA<CombineFilesResult>());
        expect(result.totalFiles, equals(1));
        expect(result.totalTokens, greaterThan(0));

        // Verify header contains correct file count and list
        final combinedContent = await result.files.first.readAsString();
        expect(combinedContent, contains('Total files: 2'));
        expect(combinedContent, contains('1. ${file1.path}'));
        expect(combinedContent, contains('2. ${file2.path}'));
        expect(combinedContent, contains('class File1'));
        expect(combinedContent, contains('class File2'));

        verify(() => mockSettingsDataSource.loadSettings()).called(1);
      });

      test('should split files when token count exceeds limit', () async {
        // Arrange
        final file1 = io.File('${tempDir.path}/large_file.dart');
        await file1.create();
        
        // Create content with many tokens to exceed limit
        final largeContent = List.generate(100, (i) => 'class TestClass$i { void method$i() {} }').join('\n');
        await file1.writeAsString(largeContent);

        final settings = AppSettings.defaultSettings().copyWith(
          stripComments: false,
          maxTokenCount: 50, // Set low limit to force splitting
        );

        when(() => mockSettingsDataSource.loadSettings())
            .thenAnswer((_) async => settings);

        // Act
        final result = await dataSource.combineFiles([file1.path]);

        // Assert
        expect(result, isA<CombineFilesResult>());
        expect(result.totalFiles, equals(2)); // Should be split into 2 files
        expect(result.files, hasLength(2)); // Should have 2 actual files
        expect(result.totalTokens, greaterThan(50)); // Should exceed limit

        // Verify both files exist and contain content
        final file1Content = await result.files[0].readAsString();
        final file2Content = await result.files[1].readAsString();
        
        expect(file1Content, isNotEmpty);
        expect(file2Content, isNotEmpty);
        expect(file1Content, contains('COMBINED FILES SUMMARY'));
        expect(file2Content, isNot(contains('COMBINED FILES SUMMARY'))); // Only first file has header

        // Verify filenames indicate splitting
        expect(result.files[0].path, contains('_part1.txt'));
        expect(result.files[1].path, contains('_part2.txt'));

        verify(() => mockSettingsDataSource.loadSettings()).called(1);
      });

      test('should save files in Documents/ai_context directory', () async {
        // Arrange
        final testFile = io.File('${tempDir.path}/test.dart');
        await testFile.create();
        await testFile.writeAsString('class Test {}');

        final settings = AppSettings.defaultSettings().copyWith(
          stripComments: false,
          maxTokenCount: 1000,
        );

        when(() => mockSettingsDataSource.loadSettings())
            .thenAnswer((_) async => settings);

        // Act
        final result = await dataSource.combineFiles([testFile.path]);

        // Assert
        expect(result.saveLocation, contains('ai_context'));
        expect(result.files.first.path, contains('ai_context'));
        
        // Verify the ai_context directory was created
        final aiContextDir = io.Directory(result.saveLocation);
        expect(await aiContextDir.exists(), isTrue);

        verify(() => mockSettingsDataSource.loadSettings()).called(1);
      });
    });

    group('error handling', () {
      test('should handle non-existent files gracefully', () async {
        // Arrange
        final nonExistentFile = '${tempDir.path}/nonexistent.dart';
        
        final settings = AppSettings.defaultSettings().copyWith(
          stripComments: false,
          maxTokenCount: 1000,
        );

        when(() => mockSettingsDataSource.loadSettings())
            .thenAnswer((_) async => settings);

        // Act
        final result = await dataSource.combineFiles([nonExistentFile]);

        // Assert
        expect(result, isA<CombineFilesResult>());
        expect(result.totalFiles, equals(1));

        // Verify error message is included in content
        final combinedContent = await result.files.first.readAsString();
        expect(combinedContent, contains('File not found: $nonExistentFile'));

        verify(() => mockSettingsDataSource.loadSettings()).called(1);
      });

      test('should handle file read errors gracefully', () async {
        // Arrange
        final testFile = io.File('${tempDir.path}/test.dart');
        await testFile.create();
        await testFile.writeAsString('test content');
        
        // Make file unreadable by deleting it after creation but before reading
        final filePath = testFile.path;
        await testFile.delete();

        final settings = AppSettings.defaultSettings().copyWith(
          stripComments: false,
          maxTokenCount: 1000,
        );

        when(() => mockSettingsDataSource.loadSettings())
            .thenAnswer((_) async => settings);

        // Act
        final result = await dataSource.combineFiles([filePath]);

        // Assert
        expect(result, isA<CombineFilesResult>());
        expect(result.totalFiles, equals(1));

        // Verify error handling message is included
        final combinedContent = await result.files.first.readAsString();
        expect(combinedContent, contains('File not found: $filePath'));

        verify(() => mockSettingsDataSource.loadSettings()).called(1);
      });

      test('should throw StorageException when settings loading fails', () async {
        // Arrange
        final testFile = io.File('${tempDir.path}/test.dart');
        await testFile.create();
        await testFile.writeAsString('test content');

        const settingsException = StorageException(
          userMessage: 'Settings not available',
          methodName: 'loadSettings',
          originalError: 'Storage error',
          title: 'Storage Error',
        );

        when(() => mockSettingsDataSource.loadSettings())
            .thenThrow(settingsException);

        // Act & Assert
        expect(
          () => dataSource.combineFiles([testFile.path]),
          throwsA(
            isA<StorageException>()
                .having((e) => e.userMessage, 'userMessage', 'Failed to combine files')
                .having((e) => e.methodName, 'methodName', 'combineFiles')
                .having((e) => e.title, 'title', 'File Combination Error'),
          ),
        );

        verify(() => mockSettingsDataSource.loadSettings()).called(1);
      });
    });

    group('edge cases', () {
      test('should handle empty files', () async {
        // Arrange
        final emptyFile = io.File('${tempDir.path}/empty.dart');
        await emptyFile.create();
        // File is created but empty

        final settings = AppSettings.defaultSettings().copyWith(
          stripComments: false,
          maxTokenCount: 1000,
        );

        when(() => mockSettingsDataSource.loadSettings())
            .thenAnswer((_) async => settings);

        // Act
        final result = await dataSource.combineFiles([emptyFile.path]);

        // Assert
        expect(result, isA<CombineFilesResult>());
        expect(result.totalFiles, equals(1));
        expect(result.totalTokens, equals(0)); // Empty file should have 0 tokens

        // Verify header is still present
        final combinedContent = await result.files.first.readAsString();
        expect(combinedContent, contains('COMBINED FILES SUMMARY'));
        expect(combinedContent, contains('Total files: 1'));

        verify(() => mockSettingsDataSource.loadSettings()).called(1);
      });

      test('should handle files with only comments when stripping comments', () async {
        // Arrange
        final commentOnlyFile = io.File('${tempDir.path}/comments.dart');
        await commentOnlyFile.create();
        await commentOnlyFile.writeAsString('''
// First comment
// Second comment
// Third comment
''');

        final settings = AppSettings.defaultSettings().copyWith(
          stripComments: true,
          maxTokenCount: 1000,
        );

        when(() => mockSettingsDataSource.loadSettings())
            .thenAnswer((_) async => settings);

        // Act
        final result = await dataSource.combineFiles([commentOnlyFile.path]);

        // Assert
        expect(result, isA<CombineFilesResult>());
        expect(result.totalFiles, equals(1));

        // Verify all comments are stripped, leaving minimal content
        final combinedContent = await result.files.first.readAsString();
        expect(combinedContent, contains('COMBINED FILES SUMMARY'));
        expect(combinedContent, isNot(contains('// First comment')));
        expect(combinedContent, isNot(contains('// Second comment')));
        expect(combinedContent, isNot(contains('// Third comment')));

        verify(() => mockSettingsDataSource.loadSettings()).called(1);
      });

      test('should handle null maxTokenCount setting', () async {
        // Arrange
        final testFile = io.File('${tempDir.path}/test.dart');
        await testFile.create();
        await testFile.writeAsString('class Test { void method() {} }');

        final settings = AppSettings.defaultSettings().copyWith(
          stripComments: false,
          maxTokenCount: null, // Null token count should not cause splitting
        );

        when(() => mockSettingsDataSource.loadSettings())
            .thenAnswer((_) async => settings);

        // Act
        final result = await dataSource.combineFiles([testFile.path]);

        // Assert
        expect(result, isA<CombineFilesResult>());
        expect(result.totalFiles, equals(1)); // Should not split when maxTokenCount is null
        expect(result.totalTokens, greaterThan(0));

        verify(() => mockSettingsDataSource.loadSettings()).called(1);
      });
    });

    group('business logic', () {
      test('should count tokens correctly', () async {
        // Arrange
        final testFile = io.File('${tempDir.path}/test.dart');
        await testFile.create();
        // Create content with known word count for testing
        await testFile.writeAsString('one two three four five'); // 5 words/tokens

        final settings = AppSettings.defaultSettings().copyWith(
          stripComments: false,
          maxTokenCount: 1000,
        );

        when(() => mockSettingsDataSource.loadSettings())
            .thenAnswer((_) async => settings);

        // Act
        final result = await dataSource.combineFiles([testFile.path]);

        // Assert
        expect(result, isA<CombineFilesResult>());
        expect(result.totalTokens, equals(5)); // Should count 5 tokens/words

        verify(() => mockSettingsDataSource.loadSettings()).called(1);
      });

      test('should preserve file order in header and content', () async {
        // Arrange
        final file1 = io.File('${tempDir.path}/first.dart');
        final file2 = io.File('${tempDir.path}/second.dart');
        final file3 = io.File('${tempDir.path}/third.dart');
        
        await file1.create();
        await file2.create();
        await file3.create();
        
        await file1.writeAsString('// FIRST FILE CONTENT');
        await file2.writeAsString('// SECOND FILE CONTENT');
        await file3.writeAsString('// THIRD FILE CONTENT');

        final settings = AppSettings.defaultSettings().copyWith(
          stripComments: false,
          maxTokenCount: 1000,
        );

        when(() => mockSettingsDataSource.loadSettings())
            .thenAnswer((_) async => settings);

        // Act
        final result = await dataSource.combineFiles([file1.path, file2.path, file3.path]);

        // Assert
        expect(result, isA<CombineFilesResult>());
        
        final combinedContent = await result.files.first.readAsString();
        
        // Verify order in header
        expect(combinedContent, contains('1. ${file1.path}'));
        expect(combinedContent, contains('2. ${file2.path}'));
        expect(combinedContent, contains('3. ${file3.path}'));
        
        // Verify order in content
        final firstIndex = combinedContent.indexOf('FIRST FILE CONTENT');
        final secondIndex = combinedContent.indexOf('SECOND FILE CONTENT');
        final thirdIndex = combinedContent.indexOf('THIRD FILE CONTENT');
        
        expect(firstIndex, lessThan(secondIndex));
        expect(secondIndex, lessThan(thirdIndex));

        verify(() => mockSettingsDataSource.loadSettings()).called(1);
      });
    });
  });
}