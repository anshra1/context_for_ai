import 'package:context_for_ai/core/error/failure.dart';
import 'package:context_for_ai/features/code_combiner/data/models/recent_workspace.dart';
import 'package:context_for_ai/features/code_combiner/domain/repositories/code_combiner_repository.dart';
import 'package:equatable/equatable.dart';

sealed class WorkspaceState extends Equatable {
  const WorkspaceState();
}

class WorkspaceInitial extends WorkspaceState {
  const WorkspaceInitial();

  @override
  List<Object> get props => [];
}

class WorkspaceLoading extends WorkspaceState {
  const WorkspaceLoading();

  @override
  List<Object> get props => [];
}

class WorkspaceError extends WorkspaceState {
  const WorkspaceError(this.failure);

  final Failure failure;

  @override
  List<Object> get props => [failure];
}

class SuccessState extends WorkspaceState {
  const SuccessState(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}

class WorkspaceLoaded extends WorkspaceState {
  const WorkspaceLoaded(this.workspaces);

  final List<RecentWorkspace> workspaces;

  @override
  List<Object> get props => [workspaces];
}

class WorkspaceOpened extends WorkspaceState {
  const WorkspaceOpened(this.workspaceData);

  final WorkspaceData workspaceData;

  @override
  List<Object> get props => [workspaceData];
}
