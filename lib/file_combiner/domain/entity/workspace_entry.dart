import 'package:freezed_annotation/freezed_annotation.dart';

part 'workspace_entry.freezed.dart';
part 'workspace_entry.g.dart';

@freezed
class WorkspaceEntry with _$WorkspaceEntry {
  const factory WorkspaceEntry({
    required String uuid,
    required String path, // Full absolute directory path
    required bool isFavorite, // Starred or not
    required DateTime lastAccessedAt,
  }) = _WorkspaceEntry;

  factory WorkspaceEntry.fromJson(Map<String, dynamic> json) => _$WorkspaceEntryFromJson(json);
}