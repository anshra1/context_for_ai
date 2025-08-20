import 'dart:convert';
import 'dart:io' as io;

import 'package:context_for_ai/features/code_combiner/data/datasources/file_system_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

/// Test for comment stripping functionality
/// Verifies that the stripCommentsFromCode setting works correctly
void main() {
  group('Comment Stripping Test', () {
    late FileSystemDataSourceImpl dataSource;
    late io.Directory testDirectory;
    late io.Directory exportDirectory;

    setUpAll(() async {
      testDirectory = await io.Directory.systemTemp.createTemp('comment_test_');
      exportDirectory = await io.Directory.systemTemp.createTemp('comment_output_');

      // Create a test file with various types of comments
      final testFile = io.File(path.join(testDirectory.path, 'test_comments.dart'));
      await testFile.writeAsString('''
/// This is a documentation comment - should be preserved
class TestClass {
  // This single-line comment should be removed
  String field1 = "value"; // Inline comment to remove
  
  /** This is a documentation block - should be preserved */
  void method1() {
    /* This multi-line comment 
       should be removed */
    print("Hello World");
  }
  
  /// Another doc comment to preserve
  void method2() {
    var x = "// not a comment inside string";
    var y = '/* also not a comment */';
    // Regular comment to remove
    return;
  }
  
  /*
   * Multi-line comment spanning
   * multiple lines - should be removed
   */
  void method3() {
    print("Code after multi-line comment");
  }
  
  /// Final documentation comment
  void method4() {
    print("Final method");
  }
}
''');
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
    });

    test('should strip comments when stripCommentsFromCode is true', () async {
      // Arrange - Enable comment stripping
      SharedPreferences.setMockInitialValues({
        'app_settings': jsonEncode({
          'fileSplitSizeInMB': 10,
          'maxTokenWarningLimit': 50000,
          'warnOnTokenExceed': true,
          'stripCommentsFromCode': true, // Enable stripping
          'defaultExportLocation': exportDirectory.path,
        }),
      });

      final testFile = path.join(testDirectory.path, 'test_comments.dart');

      // Act
      final result = await dataSource.combineAndExportFiles([testFile]);

      // Assert
      final content = await result.successedReturnedFiles.first.readAsString();
      
      print('📄 Content with comments STRIPPED:');
      print('=' * 60);
      print(content.split('COMBINED CONTENT:')[1]);
      print('=' * 60);

      // Should preserve documentation comments
      expect(content, contains('/// This is a documentation comment - should be preserved'));
      expect(content, contains('/** This is a documentation block - should be preserved */'));
      expect(content, contains('/// Another doc comment to preserve'));
      expect(content, contains('/// Final documentation comment'));

      // Should remove regular comments
      expect(content, isNot(contains('// This single-line comment should be removed')));
      expect(content, isNot(contains('// Inline comment to remove')));
      expect(content, isNot(contains('// Regular comment to remove')));
      expect(content, isNot(contains('/* This multi-line comment')));
      expect(content, isNot(contains('should be removed */')));
      expect(content, isNot(contains('* Multi-line comment spanning')));

      // Should preserve strings that look like comments
      expect(content, contains('"// not a comment inside string"'));
      expect(content, contains("'/* also not a comment */'"));

      // Should preserve actual code
      expect(content, contains('class TestClass'));
      expect(content, contains('print("Hello World")'));
      expect(content, contains('String field1 = "value"'));

      print('✅ Comment stripping test PASSED');
      print('✅ Documentation comments preserved');
      print('✅ Regular comments removed');
      print('✅ String literals preserved');
    });

    test('should preserve all comments when stripCommentsFromCode is false', () async {
      // Arrange - Disable comment stripping
      SharedPreferences.setMockInitialValues({
        'app_settings': jsonEncode({
          'fileSplitSizeInMB': 10,
          'maxTokenWarningLimit': 50000,
          'warnOnTokenExceed': true,
          'stripCommentsFromCode': false, // Disable stripping
          'defaultExportLocation': exportDirectory.path,
        }),
      });

      final testFile = path.join(testDirectory.path, 'test_comments.dart');

      // Act
      final result = await dataSource.combineAndExportFiles([testFile]);

      // Assert
      final content = await result.successedReturnedFiles.first.readAsString();
      
      print('📄 Content with comments PRESERVED:');
      print('=' * 60);
      print(content.split('COMBINED CONTENT:')[1]);
      print('=' * 60);

      // Should preserve ALL comments
      expect(content, contains('/// This is a documentation comment - should be preserved'));
      expect(content, contains('// This single-line comment should be removed'));
      expect(content, contains('// Inline comment to remove'));
      expect(content, contains('/** This is a documentation block - should be preserved */'));
      expect(content, contains('/* This multi-line comment'));
      expect(content, contains('should be removed */'));
      expect(content, contains('// Regular comment to remove'));

      print('✅ Comment preservation test PASSED');
      print('✅ All comments preserved when setting is false');
    });

    test('should handle complex comment scenarios correctly', () async {
      // Arrange - Create complex test file
      final complexFile = io.File(path.join(testDirectory.path, 'complex_comments.dart'));
      await complexFile.writeAsString('''
/// Class documentation
class ComplexTest {
  // Comment before field
  String url = "https://example.com"; // Inline comment
  
  /// Method docs
  void testMethod() {
    // Comment 1
    var regex = RegExp(r"//.*"); // Pattern with comment chars
    /* Multi-line
       comment here */
    print("Test /* not comment */ string");
    
    /// Inner documentation
    if (true) {
      // Nested comment
      return;
    }
  }
}
''');

      SharedPreferences.setMockInitialValues({
        'app_settings': jsonEncode({
          'fileSplitSizeInMB': 10,
          'maxTokenWarningLimit': 50000,
          'warnOnTokenExceed': true,
          'stripCommentsFromCode': true,
          'defaultExportLocation': exportDirectory.path,
        }),
      });

      // Act
      final result = await dataSource.combineAndExportFiles([complexFile.path]);

      // Assert
      final content = await result.successedReturnedFiles.first.readAsString();

      print('📄 Complex comment handling:');
      print('=' * 60);
      print(content.split('COMBINED CONTENT:')[1]);
      print('=' * 60);

      // Preserve documentation
      expect(content, contains('/// Class documentation'));
      expect(content, contains('/// Method docs'));
      expect(content, contains('/// Inner documentation'));

      // Remove regular comments
      expect(content, isNot(contains('// Comment before field')));
      expect(content, isNot(contains('// Inline comment')));
      expect(content, isNot(contains('// Comment 1')));
      expect(content, isNot(contains('/* Multi-line')));
      expect(content, isNot(contains('// Nested comment')));

      // Preserve strings and regex patterns
      expect(content, contains('"https://example.com"'));
      expect(content, contains('RegExp(r"//.*")'));
      expect(content, contains('"Test /* not comment */ string"'));

      print('✅ Complex comment handling PASSED');
    });

    test('should show token reduction when comments are stripped', () async {
      // Test with comments enabled
      SharedPreferences.setMockInitialValues({
        'app_settings': jsonEncode({
          'fileSplitSizeInMB': 10,
          'maxTokenWarningLimit': 50000,
          'warnOnTokenExceed': true,
          'stripCommentsFromCode': false,
          'defaultExportLocation': exportDirectory.path,
        }),
      });

      final testFile = path.join(testDirectory.path, 'test_comments.dart');
      final resultWithComments = await dataSource.combineAndExportFiles([testFile]);

      // Test with comments disabled
      SharedPreferences.setMockInitialValues({
        'app_settings': jsonEncode({
          'fileSplitSizeInMB': 10,
          'maxTokenWarningLimit': 50000,
          'warnOnTokenExceed': true,
          'stripCommentsFromCode': true,
          'defaultExportLocation': exportDirectory.path,
        }),
      });

      final resultWithoutComments = await dataSource.combineAndExportFiles([testFile]);

      print('\n📊 Token Reduction Analysis:');
      print('  • With comments: ${resultWithComments.estimatedTokenCount} tokens');
      print('  • Without comments: ${resultWithoutComments.estimatedTokenCount} tokens');
      print('  • Reduction: ${resultWithComments.estimatedTokenCount - resultWithoutComments.estimatedTokenCount} tokens');
      print('  • Percentage saved: ${((resultWithComments.estimatedTokenCount - resultWithoutComments.estimatedTokenCount) / resultWithComments.estimatedTokenCount * 100).toStringAsFixed(1)}%');

      // Should have fewer tokens when comments are stripped
      expect(resultWithoutComments.estimatedTokenCount, 
          lessThan(resultWithComments.estimatedTokenCount));

      print('✅ Token reduction verification PASSED');
    });
  });
}