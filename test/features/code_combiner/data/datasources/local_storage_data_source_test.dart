import 'dart:convert';
import 'dart:io';

import 'package:context_for_ai/core/error/exception.dart';
import 'package:context_for_ai/features/code_combiner/data/datasources/local_storage_data_source.dart';
import 'package:context_for_ai/features/code_combiner/data/models/app_settings.dart';
import 'package:context_for_ai/features/code_combiner/data/models/filter_settings.dart';
import 'package:context_for_ai/features/code_combiner/data/models/recent_workspace.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      RecentWorkspace(
        path: '/test/path',
       
        lastAccessed: DateTime.now(),
        isFavorite: false,
      ),
    );
    registerFallbackValue(FilterSettings.defaults());
    registerFallbackValue(AppSettings.defaults());
  });

  group('LocalStorageDataSourceImpl', () {
    late MockSharedPreferences mockPrefs;
    late LocalStorageDataSourceImpl dataSource;

    setUp(() {
      mockPrefs = MockSharedPreferences();
      dataSource = LocalStorageDataSourceImpl(mockPrefs);
    });

    group('initialize()', () {
      test('should handle initialization state correctly', () async {
        // Arrange
        when(() => mockPrefs.setBool(any<String>(), any<bool>()))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.initialize();

        // Assert
        verify(() => mockPrefs.setBool('initialized', true)).called(1);
      });

      test('should throw InitializationException when setBool fails', () async {
        // Arrange
        when(() => mockPrefs.setBool(any<String>(), any<bool>()))
            .thenThrow(Exception('Storage write failed'));

        // Act & Assert
        expect(
          () => dataSource.initialize(),
          throwsA(
            isA<StorageException>()
                .having((e) => e.methodName, 'methodName', '_setInitializationFlag')
                .having((e) => e.originalError, 'originalError', contains('Storage write failed'))
                .having((e) => e.title, 'title', 'Storage Write Error'),
          ),
        );
      });
    });

    group('saveRecentWorkspaces()', () {
      setUp(() async {
        when(() => mockPrefs.setBool(any<String>(), any<bool>()))
            .thenAnswer((_) async => true);
        when(() => mockPrefs.getBool('initialized')).thenReturn(true);
        await dataSource.initialize();
      });

      test('should handle workspace name length validation', () async {
        // This test will FAIL - the current implementation doesn't validate name length
        // Arrange
        final workspaceWithLongName = [
          RecentWorkspace(
            path: '/test/path',
            name: 'A' * 500, // Extremely long name - should be rejected
            lastAccessed: DateTime.now(),
            isFavorite: false,
          ),
        ];

        // Act & Assert - This will FAIL because the implementation doesn't check name length
        expect(
          () => dataSource.saveRecentWorkspaces(workspaceWithLongName),
          throwsA(
            isA<ValidationException>()
                .having((e) => e.debugDetails, 'debugDetails', contains('name too long')),
          ),
        );
      });

      test('should validate workspace path format strictly', () async {
        // This test will FAIL - the current implementation doesn't validate path format
        // Arrange
        final workspacesWithInvalidPaths = [
          RecentWorkspace(
            path: '   ', // Only whitespace - should be rejected
            name: 'Test',
            lastAccessed: DateTime.now(),
            isFavorite: false,
          ),
          RecentWorkspace(
            path: 'relative/path', // Relative path - should be rejected, only absolute paths allowed
            name: 'Test2',
            lastAccessed: DateTime.now(),
            isFavorite: false,
          ),
        ];

        // Act & Assert - This will FAIL because the implementation doesn't validate path format
        expect(
          () => dataSource.saveRecentWorkspaces(workspacesWithInvalidPaths),
          throwsA(
            isA<ValidationException>()
                .having((e) => e.debugDetails, 'debugDetails', contains('invalid path format')),
          ),
        );
      });

      test('should reject workspaces with future timestamps', () async {
        // This test will FAIL - the current implementation doesn't validate timestamps
        // Arrange
        final futureDate = DateTime.now().add(const Duration(days: 1));
        final workspaceWithFutureDate = [
          RecentWorkspace(
            path: '/test/path',
            name: 'Future Workspace',
            lastAccessed: futureDate, // Future date - should be rejected
            isFavorite: false,
          ),
        ];

        // Act & Assert - This will FAIL because the implementation doesn't check timestamps
        expect(
          () => dataSource.saveRecentWorkspaces(workspaceWithFutureDate),
          throwsA(
            isA<ValidationException>()
                .having((e) => e.debugDetails, 'debugDetails', contains('future timestamp')),
          ),
        );
      });

      test('should enforce unique workspace paths', () async {
        // This test will FAIL - the current implementation allows duplicate paths
        // Arrange
        final duplicateWorkspaces = [
          RecentWorkspace(
            path: '/test/path',
            name: 'Workspace 1',
            lastAccessed: DateTime.now(),
            isFavorite: false,
          ),
          RecentWorkspace(
            path: '/test/path', // Duplicate path - should be rejected
            name: 'Workspace 2',
            lastAccessed: DateTime.now(),
            isFavorite: true,
          ),
        ];

        // Act & Assert - This will FAIL because the implementation doesn't check for duplicates
        expect(
          () => dataSource.saveRecentWorkspaces(duplicateWorkspaces),
          throwsA(
            isA<ValidationException>()
                .having((e) => e.debugDetails, 'debugDetails', contains('duplicate paths')),
          ),
        );
      });

      test('should limit workspace list size to exactly 20 items', () async {
        // This test will FAIL - current implementation allows 50, but we want to enforce 20
        // Arrange
        final tooManyWorkspaces = List.generate(
          21, // Over the new limit of 20
          (index) => RecentWorkspace(
            path: '/test/path$index',
            name: 'Workspace $index',
            lastAccessed: DateTime.now(),
            isFavorite: false,
          ),
        );

        // Act & Assert - This will FAIL because current limit is 50, not 20
        expect(
          () => dataSource.saveRecentWorkspaces(tooManyWorkspaces),
          throwsA(
            isA<ValidationException>()
                .having((e) => e.debugDetails, 'debugDetails', contains('maximum 20 workspaces')),
          ),
        );
      });

      test('should validate workspace name contains only safe characters', () async {
        // This test will FAIL - the current implementation doesn't validate character safety
        // Arrange
        final unsafeWorkspaces = [
          RecentWorkspace(
            path: '/test/path',
            name: 'Test\x00Name', // Null byte - should be rejected
            lastAccessed: DateTime.now(),
            isFavorite: false,
          ),
          RecentWorkspace(
            path: '/test/path2',
            name: 'Test<script>alert("xss")</script>', // Script injection - should be rejected
            lastAccessed: DateTime.now(),
            isFavorite: false,
          ),
        ];

        // Act & Assert - This will FAIL because the implementation doesn't sanitize names
        expect(
          () => dataSource.saveRecentWorkspaces(unsafeWorkspaces),
          throwsA(
            isA<ValidationException>()
                .having((e) => e.debugDetails, 'debugDetails', contains('unsafe characters')),
          ),
        );
      });

      test('should handle SharedPreferences write failures with retry logic', () async {
        // This test will FAIL - the current implementation doesn't have retry logic
        // Arrange
        final workspaces = [
          RecentWorkspace(
            path: '/test/path',
            name: 'Test',
            lastAccessed: DateTime.now(),
            isFavorite: false,
          ),
        ];
        
        var callCount = 0;
        when(() => mockPrefs.setString(any<String>(), any<String>()))
            .thenAnswer((_) async {
          callCount++;
          if (callCount < 3) {
            throw Exception('Temporary storage failure');
          }
          return true;
        });

        // Act & Assert - This will FAIL because the implementation doesn't retry
        await expectLater(
          dataSource.saveRecentWorkspaces(workspaces),
          completes,
        );

        // Should have retried 3 times
        verify(() => mockPrefs.setString('recent_workspaces', any<String>())).called(3);
      });
    });

    group('loadRecentWorkspaces()', () {
      setUp(() async {
        when(() => mockPrefs.setBool(any<String>(), any<bool>()))
            .thenAnswer((_) async => true);
        when(() => mockPrefs.getBool('initialized')).thenReturn(true);
        await dataSource.initialize();
      });

      test('should sanitize loaded workspace data', () async {
        // This test will FAIL - the current implementation doesn't sanitize loaded data
        // Arrange
        final maliciousWorkspaces = [
          {
            'path': '/test/path',
            'name': '<script>alert("xss")</script>',
            'lastAccessed': DateTime.now().toIso8601String(),
            'isFavorite': false,
          }
        ];
        final jsonString = jsonEncode(maliciousWorkspaces);
        
        when(() => mockPrefs.getString('recent_workspaces')).thenReturn(jsonString);

        // Act
        final result = await dataSource.loadRecentWorkspaces();

        // Assert - This will FAIL because the implementation doesn't sanitize
        expect(result.first.name, equals('alert("xss")'));  // Should be sanitized
        expect(result.first.name, isNot(contains('<script>')));
      });

      test('should validate loaded workspace timestamps', () async {
        // This test will FAIL - the current implementation doesn't validate loaded timestamps
        // Arrange
        final futureWorkspaces = [
          {
            'path': '/test/path',
            'name': 'Future Workspace',
            'lastAccessed': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
            'isFavorite': false,
          }
        ];
        final jsonString = jsonEncode(futureWorkspaces);
        
        when(() => mockPrefs.getString('recent_workspaces')).thenReturn(jsonString);

        // Act & Assert - This will FAIL because implementation doesn't validate timestamps
        expect(
          () => dataSource.loadRecentWorkspaces(),
          throwsA(
            isA<StorageException>()
                .having((e) => e.debugDetails, 'debugDetails', contains('invalid timestamp')),
          ),
        );
      });

      test('should auto-repair corrupted workspace data', () async {
        // This test will FAIL - the current implementation doesn't auto-repair data
        // Arrange
        final partiallyCorrupted = [
          {
            'path': '/valid/path',
            'name': 'Valid Workspace',
            'lastAccessed': DateTime.now().toIso8601String(),
            'isFavorite': true,
          },
          {
            'path': null, // Corrupted entry
            'name': 'Corrupted Workspace',
            'lastAccessed': 'invalid-date',
            'isFavorite': 'not-boolean',
          },
          {
            'path': '/another/valid/path',
            'name': 'Another Valid',
            'lastAccessed': DateTime.now().toIso8601String(),
            'isFavorite': false,
          }
        ];
        final jsonString = jsonEncode(partiallyCorrupted);
        
        when(() => mockPrefs.getString('recent_workspaces')).thenReturn(jsonString);

        // Act
        final result = await dataSource.loadRecentWorkspaces();

        // Assert - This will FAIL because implementation doesn't filter corrupted entries
        expect(result, hasLength(2)); // Should only return valid entries
        expect(result.every((w) => w.path.isNotEmpty), isTrue);
      });
    });

    group('saveFilterSettings()', () {
      setUp(() async {
        when(() => mockPrefs.setBool(any<String>(), any<bool>()))
            .thenAnswer((_) async => true);
        when(() => mockPrefs.getBool('initialized')).thenReturn(true);
        await dataSource.initialize();
      });

      test('should enforce minimum extension length of 3 characters', () async {
        // This test will FAIL - current implementation only checks for 2 characters
        // Arrange
        const invalidSettings = FilterSettings(
          blockedExtensions: {'.a', '.bb'}, // Too short - should be rejected
          blockedFilePaths: {},
          blockedFileNames: {},
          blockedFolderNames: {},
          maxFileSizeInMB: 10,
          includeHiddenFiles: false,
          allowedExtensions: {},
          enablePositiveFiltering: false,
        );

        // Act & Assert - This will FAIL because current validation allows 2+ characters
        final result = await dataSource.saveFilterSettings(invalidSettings);
        expect(result, false);
      });

      test('should validate extension format strictly (no numbers, special chars)', () async {
        // This test will FAIL - current implementation doesn't validate extension content
        // Arrange
        const invalidSettings = FilterSettings(
          blockedExtensions: {'.123', '.ex@', '.t*t'}, // Invalid formats
          blockedFilePaths: {},
          blockedFileNames: {},
          blockedFolderNames: {},
          maxFileSizeInMB: 10,
          includeHiddenFiles: false,
          allowedExtensions: {},
          enablePositiveFiltering: false,
        );

        // Act & Assert - This will FAIL because implementation doesn't validate content
        final result = await dataSource.saveFilterSettings(invalidSettings);
        expect(result, false);
      });

      test('should enforce maximum path depth validation', () async {
        // This test will FAIL - current implementation doesn't validate path depth
        // Arrange
        final deepPath = '/' + List.generate(50, (i) => 'level$i').join('/');
        final invalidSettings = FilterSettings(
          blockedExtensions: const {},
          blockedFilePaths: {deepPath}, // Too deep - should be rejected
          blockedFileNames: const {},
          blockedFolderNames: const {},
          maxFileSizeInMB: 10,
          includeHiddenFiles: false,
          allowedExtensions: const {},
          enablePositiveFiltering: false,
        );

        // Act & Assert - This will FAIL because implementation doesn't check path depth
        final result = await dataSource.saveFilterSettings(invalidSettings);
        expect(result, false);
      });

      test('should prevent conflicting extension rules', () async {
        // This test will FAIL - current implementation doesn't check conflicts
        // Arrange
        const conflictingSettings = FilterSettings(
          blockedExtensions: {'.txt', '.json'},
          blockedFilePaths: {},
          blockedFileNames: {},
          blockedFolderNames: {},
          maxFileSizeInMB: 10,
          includeHiddenFiles: false,
          allowedExtensions: {'.txt', '.json'}, // Same as blocked - conflict!
          enablePositiveFiltering: true,
        );

        // Act & Assert - This will FAIL because implementation doesn't detect conflicts
        final result = await dataSource.saveFilterSettings(conflictingSettings);
        expect(result, false);
      });

      test('should limit total filter complexity score', () async {
        // This test will FAIL - current implementation doesn't calculate complexity
        // Arrange
        final heavySettings = FilterSettings(
          blockedExtensions: Set.from(List.generate(80, (i) => '.ext$i')),
          blockedFilePaths: Set.from(List.generate(80, (i) => '/path$i')),
          blockedFileNames: Set.from(List.generate(80, (i) => 'file$i.txt')),
          blockedFolderNames: Set.from(List.generate(80, (i) => 'folder$i')),
          maxFileSizeInMB: 10,
          includeHiddenFiles: false,
          allowedExtensions: const {},
          enablePositiveFiltering: false,
        );

        // Act & Assert - This will FAIL because implementation doesn't calculate complexity
        final result = await dataSource.saveFilterSettings(heavySettings);
        expect(result, false); // Should be rejected for being too complex
      });
    });

    group('loadFilterSettings()', () {
      setUp(() async {
        when(() => mockPrefs.setBool(any<String>(), any<bool>()))
            .thenAnswer((_) async => true);
        when(() => mockPrefs.getBool('initialized')).thenReturn(true);
        await dataSource.initialize();
      });

      test('should migrate legacy filter format', () async {
        // This test will FAIL - current implementation doesn't handle legacy migration
        // Arrange
        final legacySettings = {
          'extensions': ['.txt', '.log'], // Legacy format
          'folders': ['node_modules', '.git'], // Legacy format
          'maxSize': 10,
        };
        final jsonString = jsonEncode(legacySettings);
        
        when(() => mockPrefs.getString('filter_settings')).thenReturn(jsonString);

        // Act
        final result = await dataSource.loadFilterSettings();

        // Assert - This will FAIL because implementation doesn't handle legacy migration
        expect(result.blockedExtensions, contains('.txt'));
        expect(result.blockedFolderNames, contains('node_modules'));
        expect(result.maxFileSizeInMB, equals(10));
      });

      test('should validate loaded settings against security rules', () async {
        // This test will FAIL - current implementation doesn't validate loaded settings
        // Arrange
        const maliciousSettings = {
          'blockedExtensions': ['.exe', '../../../etc/passwd'],
          'blockedFilePaths': ['/system32', '../../../../'],
          'blockedFileNames': ['<script>alert(1)</script>'],
          'blockedFolderNames': ['normal', '\x00hidden'],
          'maxFileSizeInMB': -1,
          'includeHiddenFiles': false,
          'allowedExtensions': [],
          'enablePositiveFiltering': false,
        };
        final jsonString = jsonEncode(maliciousSettings);
        
        when(() => mockPrefs.getString('filter_settings')).thenReturn(jsonString);

        // Act
        final result = await dataSource.loadFilterSettings();

        // Assert - This will FAIL because implementation doesn't sanitize loaded data
        expect(result.blockedExtensions, everyElement(startsWith('.')));
        expect(result.blockedFilePaths, everyElement(isNot(contains('../'))));
        expect(result.maxFileSizeInMB, greaterThanOrEqualTo(0));
      });
    });

    group('saveAppSettings()', () {
      setUp(() async {
        when(() => mockPrefs.setBool(any<String>(), any<bool>()))
            .thenAnswer((_) async => true);
        when(() => mockPrefs.getBool('initialized')).thenReturn(true);
        await dataSource.initialize();
      });

      test('should validate export location accessibility', () async {
        // This test will FAIL - current implementation doesn't validate accessibility
        // Arrange
        const settingsWithInaccessiblePath = AppSettings(
          fileSplitSizeInMB: 5,
          maxTokenWarningLimit: 50000,
          warnOnTokenExceed: true,
          stripCommentsFromCode: false,
          defaultExportLocation: '/root/secret', // Typically inaccessible
        );

        // Act & Assert - This will FAIL because implementation doesn't test accessibility
        expect(
          () => dataSource.saveAppSettings(settingsWithInaccessiblePath),
          throwsA(
            isA<ValidationException>()
                .having((e) => e.debugDetails, 'debugDetails', contains('inaccessible path')),
          ),
        );
      });

      test('should enforce token limit based on available memory', () async {
        // This test will FAIL - current implementation uses fixed limits
        // Arrange
        const memoryIntensiveSettings = AppSettings(
          fileSplitSizeInMB: 5,
          maxTokenWarningLimit: 10000000, // 10M tokens - should check available memory
          warnOnTokenExceed: true,
          stripCommentsFromCode: false,
        );

        // Act & Assert - This will FAIL because implementation doesn't check memory
        expect(
          () => dataSource.saveAppSettings(memoryIntensiveSettings),
          throwsA(
            isA<ValidationException>()
                .having((e) => e.debugDetails, 'debugDetails', contains('insufficient memory')),
          ),
        );
      });

      test('should validate export location write permissions', () async {
        // This test will FAIL - current implementation doesn't test write permissions
        // Arrange
        const settings = AppSettings(
          fileSplitSizeInMB: 5,
          maxTokenWarningLimit: 50000,
          warnOnTokenExceed: true,
          stripCommentsFromCode: false,
          defaultExportLocation: '/System/Library', // Read-only on macOS
        );

        when(() => mockPrefs.setString(any<String>(), any<String>()))
            .thenAnswer((_) async => true);

        // Act & Assert - This will FAIL because implementation doesn't test write permissions
        expect(
          () => dataSource.saveAppSettings(settings),
          throwsA(
            isA<ValidationException>()
                .having((e) => e.debugDetails, 'debugDetails', contains('write permission')),
          ),
        );
      });

      test('should create audit log entry for sensitive changes', () async {
        // This test will FAIL - current implementation doesn't create audit logs
        // Arrange
        const sensitiveSettings = AppSettings(
          fileSplitSizeInMB: 100, // Max allowed - should be audited
          maxTokenWarningLimit: 1000000, // Max allowed - should be audited
          warnOnTokenExceed: false, // Disabling warnings - should be audited
          stripCommentsFromCode: true, // Changing code processing - should be audited
        );

        when(() => mockPrefs.setString(any<String>(), any<String>()))
            .thenAnswer((_) async => true);
        when(() => mockPrefs.setString('audit_log', any<String>()))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.saveAppSettings(sensitiveSettings);

        // Assert - This will FAIL because implementation doesn't create audit logs
        verify(() => mockPrefs.setString('audit_log', any<String>())).called(1);
      });
    });

    group('loadAppSettings()', () {
      setUp(() async {
        when(() => mockPrefs.setBool(any<String>(), any<bool>()))
            .thenAnswer((_) async => true);
        when(() => mockPrefs.getBool('initialized')).thenReturn(true);
        await dataSource.initialize();
      });

      test('should enforce runtime limits based on current system state', () async {
        // This test will FAIL - current implementation returns static settings
        // Arrange
        const storedSettings = AppSettings(
          fileSplitSizeInMB: 50,
          maxTokenWarningLimit: 500000,
          warnOnTokenExceed: true,
          stripCommentsFromCode: false,
        );
        final jsonString = jsonEncode(storedSettings.toJson());
        
        when(() => mockPrefs.getString('app_settings')).thenReturn(jsonString);

        // Act
        final result = await dataSource.loadAppSettings();

        // Assert - This will FAIL because implementation doesn't adjust for system limits
        // Assuming low memory system - should reduce limits
        expect(result.fileSplitSizeInMB, lessThanOrEqualTo(10));
        expect(result.maxTokenWarningLimit, lessThanOrEqualTo(100000));
      });

      test('should apply security patches to loaded settings', () async {
        // This test will FAIL - current implementation doesn't apply security patches
        // Arrange
        final vulnerableSettings = {
          'fileSplitSizeInMB': 999999, // Unreasonable value
          'maxTokenWarningLimit': -1, // Invalid negative value
          'warnOnTokenExceed': 'true', // String instead of boolean
          'stripCommentsFromCode': null, // Null value
          'defaultExportLocation': '../../../etc/passwd', // Path traversal attempt
        };
        final jsonString = jsonEncode(vulnerableSettings);
        
        when(() => mockPrefs.getString('app_settings')).thenReturn(jsonString);

        // Act
        final result = await dataSource.loadAppSettings();

        // Assert - This will FAIL because implementation doesn't apply security patches
        expect(result.fileSplitSizeInMB, lessThanOrEqualTo(100));
        expect(result.maxTokenWarningLimit, greaterThanOrEqualTo(1000));
        expect(result.warnOnTokenExceed, isA<bool>());
        expect(result.stripCommentsFromCode, isA<bool>());
        expect(result.defaultExportLocation, anyOf(isNull, isNot(contains('../'))));
      });
    });

    group('Advanced Error Scenarios', () {
      test('should handle concurrent modification attempts', () async {
        // This test will FAIL - current implementation doesn't handle concurrency
        // Arrange
        when(() => mockPrefs.setBool(any<String>(), any<bool>()))
            .thenAnswer((_) async => true);
        when(() => mockPrefs.getBool('initialized')).thenReturn(true);
        await dataSource.initialize();

        final settings1 = AppSettings.defaults().copyWith(fileSplitSizeInMB: 10);
        final settings2 = AppSettings.defaults().copyWith(fileSplitSizeInMB: 20);

        when(() => mockPrefs.setString('app_settings', any<String>()))
            .thenAnswer((_) async => true);

        // Act - Concurrent saves
        final futures = [
          dataSource.saveAppSettings(settings1),
          dataSource.saveAppSettings(settings2),
        ];

        // Assert - This will FAIL because implementation doesn't handle concurrency
        await expectLater(Future.wait(futures), completes);
        
        // Should have some form of conflict resolution or locking
        verify(() => mockPrefs.setString('app_settings', any<String>())).called(2);
      });

      test('should implement circuit breaker for repeated failures', () async {
        // This test will FAIL - current implementation doesn't implement circuit breaker
        // Arrange
        when(() => mockPrefs.setBool(any<String>(), any<bool>()))
            .thenAnswer((_) async => true);
        when(() => mockPrefs.getBool('initialized')).thenReturn(true);
        await dataSource.initialize();

        final settings = AppSettings.defaults();
        when(() => mockPrefs.setString('app_settings', any<String>()))
            .thenThrow(Exception('Persistent storage failure'));

        // Act - Multiple consecutive failures
        for (int i = 0; i < 5; i++) {
          try {
            await dataSource.saveAppSettings(settings);
          } catch (_) {
            // Expected to fail
          }
        }

        // Act - Next attempt should be circuit-broken
        expect(
          () => dataSource.saveAppSettings(settings),
          throwsA(
            isA<StorageException>()
                .having((e) => e.debugDetails, 'debugDetails', contains('circuit breaker')),
          ),
        );
      });
    });
  });
}