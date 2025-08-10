import 'file_node.dart';
import 'filter_settings.dart';

class FileTreeState {
  final Map<String, FileNode> allNodes;
  final String? rootId;
  final Set<String> selectedFileIds;
  final int tokenCount;
  final bool isLoading;
  final FilterSettings filterSettings;
  final String? errorMessage;
  
  FileTreeState({
    required this.allNodes,
    this.rootId,
    required this.selectedFileIds,
    required this.tokenCount,
    required this.isLoading,
    required this.filterSettings,
    this.errorMessage,
  });
  
  FileTreeState copyWith({
    Map<String, FileNode>? allNodes,
    String? rootId,
    Set<String>? selectedFileIds,
    int? tokenCount,
    bool? isLoading,
    FilterSettings? filterSettings,
    String? errorMessage,
  }) {
    return FileTreeState(
      allNodes: allNodes ?? this.allNodes,
      rootId: rootId ?? this.rootId,
      selectedFileIds: selectedFileIds ?? this.selectedFileIds,
      tokenCount: tokenCount ?? this.tokenCount,
      isLoading: isLoading ?? this.isLoading,
      filterSettings: filterSettings ?? this.filterSettings,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}