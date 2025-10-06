import 'package:equatable/equatable.dart';
import 'package:context_for_ai/features/code_combiner/data/models/file_node.dart';

/// Production-grade sealed states for FileExplorer following decision-driven design
sealed class FileExplorerState extends Equatable {
  const FileExplorerState();
}

/// Initial state - not yet started
class FileExplorerInitial extends FileExplorerState {
  const FileExplorerInitial();

  @override
  List<Object> get props => [];
}

/// Loading state - scanning directory or processing
class FileExplorerLoading extends FileExplorerState {
  const FileExplorerLoading();

  @override
  List<Object> get props => [];
}

/// Loaded state - tree ready for interaction
class FileExplorerLoaded extends FileExplorerState {
  const FileExplorerLoaded(this.filteredNodes);

  final Map<String, FileNode> filteredNodes;

  @override
  List<Object> get props => [filteredNodes];
}

/// Filter updating state - showing current tree with loading indicator
class FileExplorerFilterUpdating extends FileExplorerState {
  const FileExplorerFilterUpdating(this.filteredNodes);

  final Map<String, FileNode> filteredNodes;

  @override
  List<Object> get props => [filteredNodes];
}

/// Filter update success - showing feedback with new tree
class FileExplorerFilterUpdateSuccess extends FileExplorerState {
  const FileExplorerFilterUpdateSuccess(this.filteredNodes, this.removedSelectionsCount);

  final Map<String, FileNode> filteredNodes;
  final int removedSelectionsCount;

  @override
  List<Object> get props => [filteredNodes, removedSelectionsCount];
}

/// Error state - show notification/toast
class FileExplorerError extends FileExplorerState {
  const FileExplorerError(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}