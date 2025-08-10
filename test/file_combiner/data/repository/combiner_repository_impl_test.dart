import 'dart:io';

import 'package:context_for_ai/core/error/exception.dart';
import 'package:context_for_ai/core/error/failure.dart';
import 'package:context_for_ai/features/file_combiner/data/datasource/combiner_data_source.dart';
import 'package:context_for_ai/features/file_combiner/data/repository/combiner_repository_impl.dart';
import 'package:context_for_ai/features/file_combiner/domain/entity/file_system_entry.dart';
import 'package:context_for_ai/features/file_combiner/domain/entity/workspace_entry.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCombinerDataSource extends Mock implements CombinerDataSource {}

void main() {
  late CombinerRepositoryImpl repository;
  late MockCombinerDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockCombinerDataSource();
    repository = CombinerRepositoryImpl(mockDataSource);
  });

  group('CombinerRepositoryImpl', () {
    group('loadFolderHistory', () {
      test('should return Right with workspace entries on success', () async {
        // Arrange
        final workspaceEntries = [
          WorkspaceEntry(
            uuid: 'uuid1',
            path: '/path1',
            isFavorite: false,
            lastAccessedAt: DateTime(2023, 1, 1),
          ),
        ];
        when(() => mockDataSource.loadFolderHistory())
            .thenAnswer((_) async => workspaceEntries);

        // Act
        final result = await repository.loadFolderHistory();

        // Assert
        expect(result, isA<Right<Failure, List<WorkspaceEntry>>>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (entries) => expect(entries, equals(workspaceEntries)),
        );
      });

      test('should return Left with StorageFailure on exception', () async {
        // Arrange
        when(() => mockDataSource.loadFolderHistory()).thenThrow(
          const StorageException(
            userMessage: 'Storage error',
            methodName: 'loadFolderHistory',
            originalError: 'Hive box not open',
            title: 'Storage Error',
          ),
        );

        // Act
        final result = await repository.loadFolderHistory();

        // Assert
        expect(result, isA<Left<Failure, List<WorkspaceEntry>>>());
        result.fold(
          (failure) => expect(failure, isA<StorageFailure>()),
          (entries) => fail('Expected Left but got Right'),
        );
      });
    });

    group('saveToRecentWorkspaces', () {
      test('should return Right on success', () async {
        // Arrange
        const path = '/test/path';
        when(() => mockDataSource.saveToRecentWorkspaces(path))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.saveToRecentWorkspaces(path);

        // Assert
        expect(result, isA<Right<Failure, void>>());
        verify(() => mockDataSource.saveToRecentWorkspaces(path)).called(1);
      });

      test('should return Left with ValidationFailure on ValidationException', () async {
        // Arrange
        const path = '';
        when(() => mockDataSource.saveToRecentWorkspaces(path)).thenThrow(
          const ValidationException(
            userMessage: 'Path cannot be empty',
            methodName: 'saveToRecentWorkspaces',
            originalError: 'Empty path',
            title: 'Validation Error',
          ),
        );

        // Act
        final result = await repository.saveToRecentWorkspaces(path);

        // Assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Expected Left but got Right'),
        );
      });
    });

    group('removeFromRecent', () {
      test('should return Right on success', () async {
        // Arrange
        const path = '/test/path';
        when(() => mockDataSource.removeFromRecent(path))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.removeFromRecent(path);

        // Assert
        expect(result, isA<Right<Failure, void>>());
        verify(() => mockDataSource.removeFromRecent(path)).called(1);
      });
    });

    group('markAsFavorite', () {
      test('should return Right on success', () async {
        // Arrange
        const path = '/test/path';
        when(() => mockDataSource.markAsFavorite(path))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.markAsFavorite(path);

        // Assert
        expect(result, isA<Right<Failure, void>>());
        verify(() => mockDataSource.markAsFavorite(path)).called(1);
      });
    });

    group('fetchFolderContents', () {
      test('should return Right with file system entries on success', () async {
        // Arrange
        const folderPath = '/test/folder';
        const fileEntries = [
          FileSystemEntry(
            name: 'test.dart',
            path: '/test/folder/test.dart',
            isDirectory: false,
            size: 1024,
          ),
        ];
        when(() => mockDataSource.fetchFolderContents(
          folderPath,
          allowedExtensions: null,
        )).thenAnswer((_) async => fileEntries);

        // Act
        final result = await repository.fetchFolderContents(folderPath);

        // Assert
        expect(result, isA<Right<Failure, List<FileSystemEntry>>>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (entries) => expect(entries, equals(fileEntries)),
        );
      });

      test('should return Left with StorageFailure on exception', () async {
        // Arrange
        const folderPath = '/nonexistent/folder';
        when(() => mockDataSource.fetchFolderContents(
          folderPath,
          allowedExtensions: null,
        )).thenThrow(
          const StorageException(
            userMessage: 'Folder not found',
            methodName: 'fetchFolderContents',
            originalError: 'Directory does not exist',
            title: 'Storage Error',
          ),
        );

        // Act
        final result = await repository.fetchFolderContents(folderPath);

        // Assert
        expect(result, isA<Left<Failure, List<FileSystemEntry>>>());
        result.fold(
          (failure) => expect(failure, isA<StorageFailure>()),
          (entries) => fail('Expected Left but got Right'),
        );
      });
    });

    group('combineFiles', () {
      test('should return Right with CombineFilesResult on success', () async {
        // Arrange
        final filePaths = ['/path1.dart', '/path2.dart'];
        final combineResult = CombineFilesResult(
          files: [File('/docs/ai_context/combined.txt')],
          totalFiles: 1,
          totalTokens: 200,
          saveLocation: '/docs/ai_context',
        );
        when(() => mockDataSource.combineFiles(filePaths))
            .thenAnswer((_) async => combineResult);

        // Act
        final result = await repository.combineFiles(filePaths);

        // Assert
        expect(result, isA<Right<Failure, CombineFilesResult>>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (combineFilesResult) {
            expect(combineFilesResult.totalFiles, equals(1));
            expect(combineFilesResult.totalTokens, equals(200));
            expect(combineFilesResult.saveLocation, equals('/docs/ai_context'));
          },
        );
      });

      test('should return Left with ValidationFailure on empty file list', () async {
        // Arrange
        final filePaths = <String>[];
        when(() => mockDataSource.combineFiles(filePaths)).thenThrow(
          const ValidationException(
            userMessage: 'No files provided',
            methodName: 'combineFiles',
            originalError: 'Empty file list',
            title: 'Validation Error',
          ),
        );

        // Act
        final result = await repository.combineFiles(filePaths);

        // Assert
        expect(result, isA<Left<Failure, CombineFilesResult>>());
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (combineResult) => fail('Expected Left but got Right'),
        );
      });
    });
  });
}