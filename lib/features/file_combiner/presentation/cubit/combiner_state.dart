import 'package:context_for_ai/features/file_combiner/data/datasource/combiner_data_source.dart';
import 'package:context_for_ai/features/file_combiner/domain/entity/file_system_entry.dart';
import 'package:context_for_ai/features/file_combiner/domain/entity/workspace_entry.dart';
import 'package:equatable/equatable.dart';

sealed class CombinerState extends Equatable {
  const CombinerState();

  @override
  List<Object?> get props => [];
}

class CombinerInitial extends CombinerState {
  const CombinerInitial();
}

// Workspace History States
class WorkspaceHistoryLoading extends CombinerState {
  const WorkspaceHistoryLoading();
}

class WorkspaceHistoryLoaded extends CombinerState {
  const WorkspaceHistoryLoaded({
    required this.workspaces,
  });

  final List<WorkspaceEntry> workspaces;

  @override
  List<Object?> get props => [workspaces];
}


// Folder Contents States
class FolderContentsLoading extends CombinerState {
  const FolderContentsLoading({
    required this.folderPath,
  });

  final String folderPath;

  @override
  List<Object?> get props => [folderPath];
}

class FolderContentsLoaded extends CombinerState {
  const FolderContentsLoaded({
    required this.folderPath,
    required this.entries,
    required this.selectedFiles,
    this.allowedExtensions,
  });

  final String folderPath;
  final List<FileSystemEntry> entries;
  final List<String> selectedFiles;
  final List<String>? allowedExtensions;

  @override
  List<Object?> get props => [folderPath, entries, selectedFiles, allowedExtensions];

  FolderContentsLoaded copyWith({
    String? folderPath,
    List<FileSystemEntry>? entries,
    List<String>? selectedFiles,
    List<String>? allowedExtensions,
  }) {
    return FolderContentsLoaded(
      folderPath: folderPath ?? this.folderPath,
      entries: entries ?? this.entries,
      selectedFiles: selectedFiles ?? this.selectedFiles,
      allowedExtensions: allowedExtensions ?? this.allowedExtensions,
    );
  }
}

class FolderContentsError extends CombinerState {
  const FolderContentsError({
    required this.folderPath,
    required this.message,
    required this.isRecoverable,
  });

  final String folderPath;
  final String message;
  final bool isRecoverable;

  @override
  List<Object?> get props => [folderPath, message, isRecoverable];
}

// File Combination States
class FileCombinationInProgress extends CombinerState {
  const FileCombinationInProgress({
    required this.filePaths,
    this.progress,
  });

  final List<String> filePaths;
  final double? progress;

  @override
  List<Object?> get props => [filePaths, progress];
}

class FileCombinationCompleted extends CombinerState {
  const FileCombinationCompleted({
    required this.result,
  });

  final CombineFilesResult result;

  @override
  List<Object?> get props => [result];
}

class FileCombinationError extends CombinerState {
  const FileCombinationError({
    required this.filePaths,
    required this.message,
    required this.isRecoverable,
  });

  final List<String> filePaths;
  final String message;
  final bool isRecoverable;

  @override
  List<Object?> get props => [filePaths, message, isRecoverable];
}

// Workspace Management States
class WorkspaceActionInProgress extends CombinerState {
  const WorkspaceActionInProgress({
    required this.workspacePath,
    required this.action,
  });

  final String workspacePath;
  final WorkspaceAction action;

  @override
  List<Object?> get props => [workspacePath, action];
}

class WorkspaceActionCompleted extends CombinerState {
  const WorkspaceActionCompleted({
    required this.workspacePath,
    required this.action,
    required this.updatedWorkspaces,
  });

  final String workspacePath;
  final WorkspaceAction action;
  final List<WorkspaceEntry> updatedWorkspaces;

  @override
  List<Object?> get props => [workspacePath, action, updatedWorkspaces];
}

class WorkspaceActionError extends CombinerState {
  const WorkspaceActionError({
    required this.workspacePath,
    required this.action,
    required this.message,
    required this.isRecoverable,
  });

  final String workspacePath;
  final WorkspaceAction action;
  final String message;
  final bool isRecoverable;

  @override
  List<Object?> get props => [workspacePath, action, message, isRecoverable];
}

enum WorkspaceAction {
  save,
  remove,
  markFavorite,
}
