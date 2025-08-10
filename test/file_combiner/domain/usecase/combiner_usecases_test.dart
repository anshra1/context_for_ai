import 'dart:io';

import 'package:context_for_ai/core/error/failure.dart';
import 'package:context_for_ai/features/file_combiner/data/datasource/combiner_data_source.dart';
import 'package:context_for_ai/features/file_combiner/domain/entity/file_system_entry.dart';
import 'package:context_for_ai/features/file_combiner/domain/entity/workspace_entry.dart';
import 'package:context_for_ai/features/file_combiner/domain/repository/combiner_repository.dart';
import 'package:context_for_ai/features/file_combiner/domain/usecase/combiner_usecases.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCombinerRepository extends Mock implements CombinerRepository {}

void main() {
  late MockCombinerRepository mockRepository;

  setUp(() {
    mockRepository = MockCombinerRepository();
  });

  group('LoadWorkspaceHistory', () {
    late LoadWorkspaceHistory usecase;

    setUp(() {
      usecase = LoadWorkspaceHistory(repository: mockRepository);
    });

    test('should return workspace entries from repository', () async {
      // Arrange
      final workspaceEntries = [
        WorkspaceEntry(
          uuid: 'uuid1',
          path: '/path1',
          isFavorite: false,
          lastAccessedAt: DateTime(2023, 1, 1),
        ),
      ];
      when(() => mockRepository.loadFolderHistory())
          .thenAnswer((_) async => Right(workspaceEntries));

      // Act
      final result = await usecase();

      // Assert
      expect(result, isA<Right<Failure, List<WorkspaceEntry>>>());
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (entries) => expect(entries, equals(workspaceEntries)),
      );
      verify(() => mockRepository.loadFolderHistory()).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const failure = StorageFailure(
        message: 'Storage error',
        title: 'Storage Error',
      );
      when(() => mockRepository.loadFolderHistory())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase();

      // Assert
      expect(result, isA<Left<Failure, List<WorkspaceEntry>>>());
      result.fold(
        (f) => expect(f, equals(failure)),
        (entries) => fail('Expected Left but got Right'),
      );
    });
  });

  group('SaveWorkspace', () {
    late SaveWorkspace usecase;

    setUp(() {
      usecase = SaveWorkspace(repository: mockRepository);
    });

    test('should call repository with correct path', () async {
      // Arrange
      const path = '/test/path';
      final params = SaveWorkspaceParams(path: path);
      when(() => mockRepository.saveToRecentWorkspaces(path))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase(params);

      // Assert
      expect(result, isA<Right<Failure, void>>());
      verify(() => mockRepository.saveToRecentWorkspaces(path)).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const path = '';
      final params = SaveWorkspaceParams(path: path);
      const failure = ValidationFailure(
        message: 'Path cannot be empty',
        title: 'Validation Error',
      );
      when(() => mockRepository.saveToRecentWorkspaces(path))
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

  group('RemoveWorkspace', () {
    late RemoveWorkspace usecase;

    setUp(() {
      usecase = RemoveWorkspace(repository: mockRepository);
    });

    test('should call repository with correct path', () async {
      // Arrange
      const path = '/test/path';
      final params = RemoveWorkspaceParams(path: path);
      when(() => mockRepository.removeFromRecent(path))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase(params);

      // Assert
      expect(result, isA<Right<Failure, void>>());
      verify(() => mockRepository.removeFromRecent(path)).called(1);
    });
  });

  group('ToggleFavorite', () {
    late ToggleFavorite usecase;

    setUp(() {
      usecase = ToggleFavorite(repository: mockRepository);
    });

    test('should call repository with correct path', () async {
      // Arrange
      const path = '/test/path';
      final params = ToggleFavoriteParams(path: path);
      when(() => mockRepository.markAsFavorite(path))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase(params);

      // Assert
      expect(result, isA<Right<Failure, void>>());
      verify(() => mockRepository.markAsFavorite(path)).called(1);
    });
  });

  group('BrowseFolderContents', () {
    late BrowseFolderContents usecase;

    setUp(() {
      usecase = BrowseFolderContents(repository: mockRepository);
    });

    test('should call repository with correct parameters', () async {
      // Arrange
      const folderPath = '/test/folder';
      const allowedExtensions = ['.dart', '.js'];
      final params = BrowseFolderContentsParams(
        folderPath: folderPath,
        allowedExtensions: allowedExtensions,
      );
      const fileEntries = [
        FileSystemEntry(
          name: 'test.dart',
          path: '/test/folder/test.dart',
          isDirectory: false,
          size: 1024,
        ),
      ];
      when(() => mockRepository.fetchFolderContents(
        folderPath,
        allowedExtensions: allowedExtensions,
      )).thenAnswer((_) async => const Right(fileEntries));

      // Act
      final result = await usecase(params);

      // Assert
      expect(result, isA<Right<Failure, List<FileSystemEntry>>>());
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (entries) => expect(entries, equals(fileEntries)),
      );
      verify(() => mockRepository.fetchFolderContents(
        folderPath,
        allowedExtensions: allowedExtensions,
      )).called(1);
    });

    test('should call repository without allowedExtensions when null', () async {
      // Arrange
      const folderPath = '/test/folder';
      final params = BrowseFolderContentsParams(
        folderPath: folderPath,
      );
      const fileEntries = <FileSystemEntry>[];
      when(() => mockRepository.fetchFolderContents(
        folderPath,
        allowedExtensions: null,
      )).thenAnswer((_) async => const Right(fileEntries));

      // Act
      final result = await usecase(params);

      // Assert
      expect(result, isA<Right<Failure, List<FileSystemEntry>>>());
      verify(() => mockRepository.fetchFolderContents(
        folderPath,
        allowedExtensions: null,
      )).called(1);
    });
  });

  group('CombineFiles', () {
    late CombineFiles usecase;

    setUp(() {
      usecase = CombineFiles(repository: mockRepository);
    });

    test('should call repository with correct file paths', () async {
      // Arrange
      final filePaths = ['/path1.dart', '/path2.dart'];
      final params = CombineFilesParams(filePaths: ['/path1.dart', '/path2.dart']);
      final combineResult = CombineFilesResult(
        files: [File('/docs/ai_context/combined.txt')],
        totalFiles: 1,
        totalTokens: 150,
        saveLocation: '/docs/ai_context',
      );
      when(() => mockRepository.combineFiles(filePaths))
          .thenAnswer((_) async => Right(combineResult));

      // Act
      final result = await usecase(params);

      // Assert
      expect(result, isA<Right<Failure, CombineFilesResult>>());
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (combinedResult) {
          expect(combinedResult.totalFiles, equals(1));
          expect(combinedResult.totalTokens, equals(150));
          expect(combinedResult.saveLocation, equals('/docs/ai_context'));
        },
      );
      verify(() => mockRepository.combineFiles(filePaths)).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      final filePaths = <String>[];
      final params = CombineFilesParams(filePaths: <String>[]);
      const failure = ValidationFailure(
        message: 'No files provided',
        title: 'Validation Error',
      );
      when(() => mockRepository.combineFiles(filePaths))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(params);

      // Assert
      expect(result, isA<Left<Failure, CombineFilesResult>>());
      result.fold(
        (f) => expect(f, equals(failure)),
        (combineResult) => fail('Expected Left but got Right'),
      );
    });
  });

  group('UseCase Parameters', () {
    test('SaveWorkspaceParams should store path correctly', () {
      // Arrange & Act
      const path = '/test/path';
      final params = SaveWorkspaceParams(path: path);

      // Assert
      expect(params.path, equals(path));
    });

    test('RemoveWorkspaceParams should store path correctly', () {
      // Arrange & Act
      const path = '/test/path';
      final params = RemoveWorkspaceParams(path: path);

      // Assert
      expect(params.path, equals(path));
    });

    test('ToggleFavoriteParams should store path correctly', () {
      // Arrange & Act
      const path = '/test/path';
      final params = ToggleFavoriteParams(path: path);

      // Assert
      expect(params.path, equals(path));
    });

    test('BrowseFolderContentsParams should store parameters correctly', () {
      // Arrange & Act
      const folderPath = '/test/folder';
      const allowedExtensions = ['.dart', '.js'];
      final params = BrowseFolderContentsParams(
        folderPath: folderPath,
        allowedExtensions: allowedExtensions,
      );

      // Assert
      expect(params.folderPath, equals(folderPath));
      expect(params.allowedExtensions, equals(allowedExtensions));
    });

    test('CombineFilesParams should store file paths correctly', () {
      // Arrange & Act
      final filePaths = ['/path1.dart', '/path2.dart'];
      final params = CombineFilesParams(filePaths: ['/path1.dart', '/path2.dart']);

      // Assert
      expect(params.filePaths, equals(filePaths));
    });
  });
}