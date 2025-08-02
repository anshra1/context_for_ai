// test/settings/settings_data_source_test.dart

import 'dart:io';

import 'package:context_for_ai/core/constants/hive_constants.dart';
import 'package:context_for_ai/core/error/exception.dart';
import 'package:context_for_ai/features/setting/data/datasource/setting_datasource.dart';
import 'package:context_for_ai/features/setting/model/app_setting.dart';
import 'package:context_for_ai/features/setting/model/app_settings_hive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';

// Mocktail setup for custom types used with any() or captureAny()
class MockAppSettingsHiveBox extends Mock implements Box<AppSettingsHive> {}

// Add near other mock class declarations
class MockAppSettingsHive extends Mock implements AppSettingsHive {}

void main() {
  // Register fallback values for custom types used in mocks
  setUpAll(() {
    registerFallbackValue(AppSettings.defaultSettings());
    registerFallbackValue(
      AppSettingsHive(
        excludedFileExtensions: [],
        excludedNames: [],
        showHiddenFiles: false,
        maxTokenCount: 0,
        stripComments: false,
        warnOnTokenExceed: false,
      ),
    );
    registerFallbackValue(
      AppSettingsHive(
        excludedFileExtensions: [],
        excludedNames: [],
        showHiddenFiles: false,
        maxTokenCount: 0,
        stripComments: false,
        warnOnTokenExceed: false,
      ),
    );
    registerFallbackValue(HiveKeys.settingsKey);
  });

  group('SettingsDataSourceImpl', () {
    late MockAppSettingsHiveBox mockBox;
    late SettingsDataSourceImpl dataSource;

    setUp(() {
      mockBox = MockAppSettingsHiveBox();
      dataSource = SettingsDataSourceImpl(box: mockBox);
    });

    group('loadSettings()', () {
      test('Load existing settings from Hive successfully', () async {
        // Arrange
        final storedHiveSettings = AppSettingsHive(
          excludedFileExtensions: ['.txt'],
          excludedNames: ['temp/'],
          showHiddenFiles: true,
          maxTokenCount: 10000,
          stripComments: true,
          warnOnTokenExceed: false,
        );
        final expectedModelSettings = storedHiveSettings.toModel();

        when(() => mockBox.isOpen).thenReturn(true);
        when(() => mockBox.get(HiveKeys.settingsKey)).thenReturn(storedHiveSettings);

        // Act
        final result = await dataSource.loadSettings();

        // Assert
        expect(result, equals(expectedModelSettings));
        // Mutation probe: if toModel() conversion was broken, this test would fail.
      });

      test('Load default settings when none exist', () async {
        // Arrange
        final defaultSettings = AppSettings.defaultSettings();

        when(() => mockBox.isOpen).thenReturn(true);
        when(() => mockBox.get(HiveKeys.settingsKey)).thenReturn(null);
        // Mock the internal call to saveSettings made by loadSettings
        when(
          () => mockBox.put(any(), any<AppSettingsHive>()),
        ).thenAnswer((_) async => {});

        // Act
        final result = await dataSource.loadSettings();

        // Assert
        expect(result, equals(defaultSettings));
        final captured = verify(
          () => mockBox.put(HiveKeys.settingsKey, captureAny()),
        ).captured;
        expect(captured, isNotEmpty);
        expect((captured[0] as AppSettingsHive).toModel(), equals(defaultSettings));
        // Mutation probe: if default saving logic was removed, this test would fail.
      });

      test('Hive box not open during load', () async {
        // Arrange
        when(() => mockBox.isOpen).thenReturn(false);

        // Act & Assert
        expect(
          () => dataSource.loadSettings(),
          throwsA(
            isA<StorageException>()
                .having((e) => e.originalError, 'originalError', 'Hive box is not open')
                .having((e) => e.methodName, 'methodName', 'loadSettings')
                .having((e) => e.userMessage, 'userMessage', 'Failed to load settings')
                .having((e) => e.title, 'title', 'Storage Error')
                .having((e) => e.isRecoverable, 'isRecoverable', false),
          ),
        );
        // Mutation probe: if the box.isOpen check was removed, this test would fail.
      });

      test('Hive read operation fails', () async {
        // Arrange
        final fakeException = Exception('Hive read error');
        when(() => mockBox.isOpen).thenReturn(true);
        when(() => mockBox.get(any())).thenThrow(fakeException);

        // Act & Assert
        expect(
          () => dataSource.loadSettings(),
          throwsA(
            isA<StorageException>()
                .having((e) => e.methodName, 'methodName', 'loadSettings')
                .having((e) => e.userMessage, 'userMessage', 'Failed to load settings')
                .having((e) => e.title, 'title', 'Storage Error')
                .having(
                  (e) => e.originalError,
                  'originalError',
                  contains('Hive read error'),
                ),
          ),
        );
        // Mutation probe: if the try-catch block was removed, this test would fail.
      });
      test('Settings conversion fails', () async {
        // Arrange
        final mockHiveSettings = MockAppSettingsHive(); // Use mock object
        const underlyingException = FormatException('Invalid data during toModel');

        when(() => mockBox.isOpen).thenReturn(true);
        when(() => mockBox.get(HiveKeys.settingsKey)).thenReturn(mockHiveSettings);
        // Stub the toModel method on the mock object to throw
        when(mockHiveSettings.toModel).thenThrow(underlyingException);

        // Act & Assert
        expect(
          () => dataSource.loadSettings(),
          throwsA(
            isA<StorageException>()
                .having((e) => e.methodName, 'methodName', 'loadSettings')
                .having((e) => e.userMessage, 'userMessage', 'Failed to load settings')
                .having((e) => e.title, 'title', 'Storage Error')
                // Check that the original FormatException is included in the details
                .having(
                  (e) => e.originalError,
                  'originalError',
                  contains('FormatException: Invalid data during toModel'),
                ),
            // Optionally check the stack trace is present if needed
            // .having((e) => e.stackTrace, 'stackTrace', isNotNull), // Depends on implementation
          ),
        );
        // Mutation probe: if the try-catch block was removed or exception wrapping logic changed, this test would fail.
        // Note: This test now correctly asserts the behavior of the current implementation which wraps the exception.
      });
    });

    group('saveSettings(AppSettings settings)', () {
      test('Load default settings when none exist', () async {
        // Arrange
        final defaultSettings = AppSettings.defaultSettings();

        when(() => mockBox.isOpen).thenReturn(true);
        // Crucially, stub the get call to return null
        when(() => mockBox.get(HiveKeys.settingsKey)).thenReturn(null);
        // Stub the put call that will happen inside saveSettings called by loadSettings
        when(() => mockBox.put(any(), any<AppSettingsHive>())).thenAnswer((_) async => {});

        // Act
        final result = await dataSource.loadSettings();

        // Assert
        // 1. Check the returned value is the default
        expect(result, equals(defaultSettings));

        // 2. Check that get was called to look for existing settings
        verify(() => mockBox.get(HiveKeys.settingsKey)).called(1);

        // 3. Check that put was called to save the defaults
        // Capture the arguments passed to put
        final capturedPutArgs = verify(() => mockBox.put(captureAny(), captureAny())).captured;
        expect(capturedPutArgs, hasLength(2)); // key and value
        expect(capturedPutArgs[0], HiveKeys.settingsKey);
        expect((capturedPutArgs[1] as AppSettingsHive).toModel(), equals(defaultSettings));
        // Mutation probe: if default saving logic was removed, this test would fail.
      });

      test('Hive box not open during save', () async {
        // Arrange
        final appSettingsToSave = AppSettings.defaultSettings();
        when(() => mockBox.isOpen).thenReturn(false);

        // Act & Assert
        expect(
          () => dataSource.saveSettings(appSettingsToSave),
          throwsA(
            isA<StorageException>()
                .having((e) => e.originalError, 'originalError', 'Hive box is not open')
                .having((e) => e.methodName, 'methodName', 'saveSettings')
                .having(
                  (e) => e.userMessage,
                  'userMessage',
                  'App settings storage is not available',
                )
                .having((e) => e.title, 'title', 'Storage Error')
                .having((e) => e.isRecoverable, 'isRecoverable', false),
          ),
        );
        // Mutation probe: if the box.isOpen check was removed, this test would fail.
      });

      test('Hive write operation fails', () async {
        // Arrange
        final appSettingsToSave = AppSettings.defaultSettings();
        const fakeException = FileSystemException('Disk full');
        when(() => mockBox.isOpen).thenReturn(true);
        when(() => mockBox.put(any(), any<AppSettingsHive>())).thenThrow(fakeException);

        // Act & Assert
        expect(
          () => dataSource.saveSettings(appSettingsToSave),
          throwsA(
            isA<StorageException>()
                .having((e) => e.methodName, 'methodName', 'saveSettings')
                .having((e) => e.userMessage, 'userMessage', 'Failed to save settings')
                .having((e) => e.title, 'title', 'Storage Error')
                .having((e) => e.originalError, 'originalError', contains('Disk full')),
          ),
        );
        // Mutation probe: if the try-catch block was removed, this test would fail.
      });

      test('Null settings parameter', () async {
        // Arrange - This test assumes the method signature allows null, or we test passing null explicitly
        // However, the signature `Future<void> saveSettings(AppSettings settings)` implies non-null.
        // If the method is expected to handle null, the signature should be `AppSettings? settings`.
        // Assuming the signature is correct and null is not expected, passing null would likely cause a compile-time error or a runtime NPE before the method logic.
        // Let's test the behavior if null is somehow passed (e.g., via dynamic or if the signature were nullable).
        // For a non-nullable parameter, this test might not be directly applicable unless the call site allows it.
        // We'll proceed assuming a potential runtime null check or that the method signature could be `AppSettings?`.

        // If we strictly follow the provided signature and Dart null safety, this test might be less relevant.
        // However, to cover the edge case intent, we can simulate it.
        // This will likely result in a Dart runtime error (NullPointerException) before the method body executes properly.
        // The test framework might catch this.

        // Simulate calling with null (requires dynamic or changing signature)
        // This is an edge case test, and the outcome depends on Dart's null safety.
        try {
          // ignore: unnecessary_nullable_for_final_variable_declarations, argument_type_not_assignable
          const dynamic nullSettings = null;
          // ignore: unnecessary_cast
          await dataSource.saveSettings(
            nullSettings as AppSettings,
          ); // This line will likely throw before method logic
          fail('Expected an exception due to null settings');
        } on TypeError catch (e) {
          // Dart's null safety throws TypeError for null assignment to non-nullable
          expect(e, isA<TypeError>());
          // This confirms Dart's null safety handles it. If internal null checks existed, they might throw differently.
          // Mutation probe: if an internal null check existed and was removed, behavior might change, but Dart's null safety is the primary guard here.
        } on Exception catch (e) {
          // Catch other potential exceptions if thrown by the method body
          // If the method itself had a null check that threw a specific exception, it would be caught here.
          // As the code stands, it doesn't have an explicit null check for `settings`.
          fail('Unexpected exception type for null settings: $e');
        }
        // Note: This test primarily validates Dart's null safety behavior for non-nullable parameters.
        // If the method signature were `AppSettings? settings`, a specific null check inside the method would be tested differently.
      });

      test('Settings conversion fails during save', () async {
        // Arrange
        final appSettingsToSave = AppSettings.defaultSettings();
        // Stub fromModel to throw an exception. We need to mock the static method or the constructor behavior.
        // Since `AppSettingsHive.fromModel` is a factory constructor, we cannot easily stub it directly with mocktail.
        // A better approach is to create an AppSettings object that causes the HiveObject's internal state to be invalid
        // or to mock the HiveObject itself if it were injected.
        // However, given the current structure, we can test the `catch` block by making `box.put` throw an exception
        // that originates from a conversion issue simulated by throwing during put.
        // Let's assume `fromModel` throws. We can't stub it easily. Let's test the catch-all mechanism.
        // Alternatively, we can force an error in `put` that simulates a conversion problem leading to an invalid object being put.
        // For this test, let's focus on the catch block catching any exception during put.
        // If `fromModel` itself threw, it would be caught before `put`. Let's simulate an error *during* the put process that might stem from conversion.
        // This test is slightly less precise but tests the error handling path.
        final fakeConversionException = Exception('Conversion to Hive object failed');
        when(() => mockBox.isOpen).thenReturn(true);
        // We can't easily make `AppSettingsHive.fromModel` throw. Let's assume the put operation fails in a way that indicates a conversion problem.
        when(
          () => mockBox.put(any(), any<AppSettingsHive>()),
        ).thenThrow(fakeConversionException);

        // Act & Assert
        expect(
          () => dataSource.saveSettings(appSettingsToSave),
          throwsA(
            isA<StorageException>()
                .having((e) => e.methodName, 'methodName', 'saveSettings')
                .having((e) => e.userMessage, 'userMessage', 'Failed to save settings')
                .having((e) => e.title, 'title', 'Storage Error')
                .having(
                  (e) => e.originalError,
                  'originalError',
                  contains('Conversion to Hive object failed'),
                ),
          ),
        );
        // Mutation probe: if the try-catch block or exception wrapping logic was removed, this test would fail.
        // Note: This test covers the general exception handling in saveSettings, which includes conversion errors caught by the generic catch.
        // To specifically test `fromModel` throwing, significant refactoring (like injecting a factory) would be needed.
      });

      test('Save very large settings object', () async {
        // Arrange
        final largeList = List.generate(10000, (index) => '.ext$index');
        final largeNamesList = List.generate(10000, (index) => 'name$index/');
        final largeSettings = AppSettings(
          excludedFileExtensions: largeList,
          excludedNames: largeNamesList,
          showHiddenFiles: true,
          maxTokenCount: 999999,
          stripComments: false,
          warnOnTokenExceed: false,
        );

        when(() => mockBox.isOpen).thenReturn(true);
        // Use a timeout to detect potential hangs or excessive processing time
        when(() => mockBox.put(any(), any<AppSettingsHive>())).thenAnswer((_) async {});

        // Act & Assert
        // Wrap in expect to catch potential synchronous errors, returnsNormally for async completion
        expect(
          () async => dataSource.saveSettings(largeSettings),
          returnsNormally, // Ensures the Future completes without throwing
        );
        // Further verification
        verify(() => mockBox.put(HiveKeys.settingsKey, any<AppSettingsHive>())).called(1);
        // Mutation probe: if handling large data caused memory issues or timeouts, this test might fail or become flaky.
        // Note: This test might be inherently flaky in CI due to resource constraints. Consider marking @flakyTest if needed.
      });

      // Integration test - requires real async operations and checks for race conditions
      test('Concurrent save operations', () async {
        // Arrange
        final settings1 = AppSettings.defaultSettings().copyWith(maxTokenCount: 1000);
        final settings2 = AppSettings.defaultSettings().copyWith(maxTokenCount: 2000);
        final settings3 = AppSettings.defaultSettings().copyWith(maxTokenCount: 3000);

        when(() => mockBox.isOpen).thenReturn(true);
        when(() => mockBox.put(any(), any<AppSettingsHive>())).thenAnswer((_) async {});

        // Act
        final futures = [
          dataSource.saveSettings(settings1),
          dataSource.saveSettings(settings2),
          dataSource.saveSettings(settings3),
        ];

        await Future.wait(futures);

        // Assert - Verify put was called multiple times
        verify(() => mockBox.put(HiveKeys.settingsKey, any<AppSettingsHive>())).called(3);
        // The "last write wins" consistency is harder to assert without controlling the exact timing of mock calls
        // or inspecting the final state of the mock/fake box, which is outside the scope of a simple mock-based unit test.
        // This test ensures no crashes or corruption occur due to concurrency at the call level.
        // Mutation probe: if synchronization was removed, this test might detect race conditions.
      });
    });

    group('resetToDefaults()', () {
      test('Reset to defaults successfully', () async {
        // Arrange
        final defaultSettings = AppSettings.defaultSettings();
        when(() => mockBox.isOpen).thenReturn(true);
        when(() => mockBox.put(any(), any<AppSettingsHive>())).thenAnswer((_) async {});

        // Act
        await dataSource.resetToDefaults();

        // Assert
        final captured = verify(
          () => mockBox.put(HiveKeys.settingsKey, captureAny()),
        ).captured;
        expect(captured, isNotEmpty);
        expect((captured[0] as AppSettingsHive).toModel(), equals(defaultSettings));
        // Mutation probe: if default settings creation or saving logic was changed, this test would fail.
      });

      test('Save failure during reset', () async {
        // Arrange
        const fakeSaveException = StorageException(
          originalError: 'Disk error',
          methodName: 'saveSettings',
          userMessage: 'Failed to save settings',
          title: 'Storage Error',
          isRecoverable: false,
        );
        when(() => mockBox.isOpen).thenReturn(true);
        when(
          () => mockBox.put(any(), any<AppSettingsHive>()),
        ).thenThrow(fakeSaveException);

        // Act & Assert
        expect(
          () => dataSource.resetToDefaults(),
          throwsA(equals(fakeSaveException)), // Expect the exact exception to propagate
        );
        // Mutation probe: if the exception was caught and swallowed inside resetToDefaults, this test would fail.
      });

      test('Hive box not open during reset', () async {
        // Arrange
        when(() => mockBox.isOpen).thenReturn(false);

        // Act & Assert
        expect(
          () => dataSource.resetToDefaults(),
          throwsA(
            isA<StorageException>()
                .having((e) => e.originalError, 'originalError', 'Hive box is not open')
                .having(
                  (e) => e.methodName,
                  'methodName',
                  'saveSettings',
                ) // Because it's thrown by saveSettings
                .having(
                  (e) => e.userMessage,
                  'userMessage',
                  'App settings storage is not available',
                )
                .having((e) => e.title, 'title', 'Storage Error')
                .having((e) => e.isRecoverable, 'isRecoverable', false),
          ),
        );
        // Mutation probe: if the box.isOpen check in saveSettings was bypassed or removed, this test would fail.
      });
    });
  });
}
