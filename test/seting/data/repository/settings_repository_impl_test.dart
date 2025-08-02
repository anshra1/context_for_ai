import 'package:context_for_ai/core/error/exception.dart';
import 'package:context_for_ai/core/error/failure.dart';
import 'package:context_for_ai/features/setting/data/datasource/setting_datasource.dart';
import 'package:context_for_ai/features/setting/data/repository/settings_repository_impl.dart';
import 'package:context_for_ai/features/setting/model/app_setting.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSettingsDataSource extends Mock implements SettingsDataSource {}

void main() {
  late SettingsRepositoryImpl repository;
  late MockSettingsDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockSettingsDataSource();
    repository = SettingsRepositoryImpl(mockDataSource);
  });

  group('SettingsRepositoryImpl', () {
    group('loadSettings', () {
      test('should return Right with app settings on success', () async {
        // Arrange
        const appSettings = AppSettings(
          excludedFileExtensions: ['.lock', '.iml'],
          excludedNames: ['build/', '.dart_tool/'],
          showHiddenFiles: false,
          maxTokenCount: 8000,
          stripComments: false,
          warnOnTokenExceed: true,
        );
        when(() => mockDataSource.loadSettings())
            .thenAnswer((_) async => appSettings);

        // Act
        final result = await repository.loadSettings();

        // Assert
        expect(result, isA<Right<Failure, AppSettings>>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (settings) => expect(settings, equals(appSettings)),
        );
      });

      test('should return Left with StorageFailure on StorageException', () async {
        // Arrange
        when(() => mockDataSource.loadSettings()).thenThrow(
          const StorageException(
            userMessage: 'Failed to load settings',
            methodName: 'loadSettings',
            originalError: 'Hive box is not open',
            title: 'Storage Error',
          ),
        );

        // Act
        final result = await repository.loadSettings();

        // Assert
        expect(result, isA<Left<Failure, AppSettings>>());
        result.fold(
          (failure) => expect(failure, isA<StorageFailure>()),
          (settings) => fail('Expected Left but got Right'),
        );
      });

      test('should return Left with UnknownFailure on unexpected Exception', () async {
        // Arrange
        when(() => mockDataSource.loadSettings()).thenThrow(
          Exception('Unexpected error'),
        );

        // Act
        final result = await repository.loadSettings();

        // Assert
        expect(result, isA<Left<Failure, AppSettings>>());
        result.fold(
          (failure) => expect(failure, isA<UnknownFailure>()),
          (settings) => fail('Expected Left but got Right'),
        );
      });
    });

    group('saveSettings', () {
      test('should return Right on success', () async {
        // Arrange
        const appSettings = AppSettings(
          excludedFileExtensions: ['.txt'],
          excludedNames: ['temp/'],
          showHiddenFiles: true,
          maxTokenCount: 10000,
          stripComments: true,
          warnOnTokenExceed: false,
        );
        when(() => mockDataSource.saveSettings(appSettings))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.saveSettings(appSettings);

        // Assert
        expect(result, isA<Right<Failure, void>>());
        verify(() => mockDataSource.saveSettings(appSettings)).called(1);
      });

      test('should return Left with StorageFailure on StorageException', () async {
        // Arrange
        const appSettings = AppSettings(
          excludedFileExtensions: [],
          excludedNames: [],
          showHiddenFiles: false,
          maxTokenCount: null,
          stripComments: false,
          warnOnTokenExceed: true,
        );
        when(() => mockDataSource.saveSettings(appSettings)).thenThrow(
          const StorageException(
            userMessage: 'Failed to save settings',
            methodName: 'saveSettings',
            originalError: 'Hive box is not open',
            title: 'Storage Error',
          ),
        );

        // Act
        final result = await repository.saveSettings(appSettings);

        // Assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) => expect(failure, isA<StorageFailure>()),
          (_) => fail('Expected Left but got Right'),
        );
      });

      test('should return Left with UnknownFailure on unexpected Exception', () async {
        // Arrange
        const appSettings = AppSettings(
          excludedFileExtensions: ['.log'],
          excludedNames: ['cache/'],
          showHiddenFiles: false,
          maxTokenCount: 5000,
          stripComments: false,
          warnOnTokenExceed: true,
        );
        when(() => mockDataSource.saveSettings(appSettings)).thenThrow(
          Exception('Serialization error'),
        );

        // Act
        final result = await repository.saveSettings(appSettings);

        // Assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) => expect(failure, isA<UnknownFailure>()),
          (_) => fail('Expected Left but got Right'),
        );
      });
    });

    group('resetToDefaults', () {
      test('should return Right on success', () async {
        // Arrange
        when(() => mockDataSource.resetToDefaults())
            .thenAnswer((_) async {});

        // Act
        final result = await repository.resetToDefaults();

        // Assert
        expect(result, isA<Right<Failure, void>>());
        verify(() => mockDataSource.resetToDefaults()).called(1);
      });

      test('should return Left with StorageFailure on StorageException', () async {
        // Arrange
        when(() => mockDataSource.resetToDefaults()).thenThrow(
          const StorageException(
            userMessage: 'Failed to reset settings',
            methodName: 'resetToDefaults',
            originalError: 'Unable to save default settings',
            title: 'Storage Error',
          ),
        );

        // Act
        final result = await repository.resetToDefaults();

        // Assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) => expect(failure, isA<StorageFailure>()),
          (_) => fail('Expected Left but got Right'),
        );
      });

      test('should return Left with UnknownFailure on unexpected Exception', () async {
        // Arrange
        when(() => mockDataSource.resetToDefaults()).thenThrow(
          Exception('Database connection lost'),
        );

        // Act
        final result = await repository.resetToDefaults();

        // Assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) => expect(failure, isA<UnknownFailure>()),
          (_) => fail('Expected Left but got Right'),
        );
      });
    });
  });
}