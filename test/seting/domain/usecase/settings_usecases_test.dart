import 'package:context_for_ai/core/error/failure.dart';
import 'package:context_for_ai/features/setting/domain/repository/settings_repository.dart';
import 'package:context_for_ai/features/setting/domain/usecase/settings_usecases.dart';
import 'package:context_for_ai/features/setting/model/app_setting.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late MockSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockSettingsRepository();
  });

  group('LoadSettings', () {
    late LoadSettings usecase;

    setUp(() {
      usecase = LoadSettings(repository: mockRepository);
    });

    test('should return app settings from repository', () async {
      // Arrange
      const appSettings = AppSettings(
        excludedFileExtensions: ['.lock'],
        excludedNames: ['build/'],
        showHiddenFiles: false,
        maxTokenCount: 8000,
        stripComments: false,
        warnOnTokenExceed: true,
      );
      when(() => mockRepository.loadSettings())
          .thenAnswer((_) async => const Right(appSettings));

      // Act
      final result = await usecase();

      // Assert
      expect(result, isA<Right<Failure, AppSettings>>());
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (settings) => expect(settings, equals(appSettings)),
      );
      verify(() => mockRepository.loadSettings()).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const failure = StorageFailure(
        message: 'Storage error',
        title: 'Storage Error',
      );
      when(() => mockRepository.loadSettings())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase();

      // Assert
      expect(result, isA<Left<Failure, AppSettings>>());
      result.fold(
        (f) => expect(f, equals(failure)),
        (settings) => fail('Expected Left but got Right'),
      );
    });
  });

  group('SaveSettings', () {
    late SaveSettings usecase;

    setUp(() {
      usecase = SaveSettings(repository: mockRepository);
    });

    test('should call repository with correct settings', () async {
      // Arrange
      const appSettings = AppSettings(
        excludedFileExtensions: ['.lock', '.txt'],
        excludedNames: ['build/', 'node_modules/'],
        showHiddenFiles: true,
        maxTokenCount: 10000,
        stripComments: true,
        warnOnTokenExceed: false,
      );
      final params = SaveSettingsParams(settings: appSettings);
      when(() => mockRepository.saveSettings(appSettings))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase(params);

      // Assert
      expect(result, isA<Right<Failure, void>>());
      verify(() => mockRepository.saveSettings(appSettings)).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const appSettings = AppSettings(
        excludedFileExtensions: [],
        excludedNames: [],
        showHiddenFiles: false,
        maxTokenCount: null,
        stripComments: false,
        warnOnTokenExceed: true,
      );
      final params = SaveSettingsParams(settings: appSettings);
      const failure = StorageFailure(
        message: 'Failed to save settings',
        title: 'Storage Error',
      );
      when(() => mockRepository.saveSettings(appSettings))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(params);

      // Assert
      expect(result, isA<Left<Failure, void>>());
      result.fold(
        (f) => expect(f, equals(failure)),
        (_) => fail('Expected Left but got Right'),
      );
    });
  });

  group('ResetSettings', () {
    late ResetSettings usecase;

    setUp(() {
      usecase = ResetSettings(repository: mockRepository);
    });

    test('should call repository resetToDefaults', () async {
      // Arrange
      when(() => mockRepository.resetToDefaults())
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase();

      // Assert
      expect(result, isA<Right<Failure, void>>());
      verify(() => mockRepository.resetToDefaults()).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const failure = StorageFailure(
        message: 'Failed to reset settings',
        title: 'Storage Error',
      );
      when(() => mockRepository.resetToDefaults())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase();

      // Assert
      expect(result, isA<Left<Failure, void>>());
      result.fold(
        (f) => expect(f, equals(failure)),
        (_) => fail('Expected Left but got Right'),
      );
    });
  });

  group('UseCase Parameters', () {
    test('SaveSettingsParams should store settings correctly', () {
      // Arrange & Act
      const appSettings = AppSettings(
        excludedFileExtensions: ['.dart'],
        excludedNames: ['test/'],
        showHiddenFiles: true,
        maxTokenCount: 5000,
        stripComments: false,
        warnOnTokenExceed: true,
      );
      final params = SaveSettingsParams(settings: appSettings);

      // Assert
      expect(params.settings, equals(appSettings));
    });
  });
}