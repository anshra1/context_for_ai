// lib/file_combiner/data/model/workspace_entry_hive.dart
import 'package:context_for_ai/features/file_combiner/domain/entity/workspace_entry.dart';
import 'package:hive/hive.dart';

part 'workspace_entry_hive.g.dart';

@HiveType(typeId: 0)
class WorkspaceEntryHive extends HiveObject {
  WorkspaceEntryHive({
    required this.uuid,
    required this.path,
    required this.isFavorite,
    required this.lastAccessedAt,
  });

  // Convert from domain entity to Hive object
  factory WorkspaceEntryHive.fromEntity(WorkspaceEntry entry) {
    return WorkspaceEntryHive(
      uuid: entry.uuid,
      path: entry.path,
      isFavorite: entry.isFavorite,
      lastAccessedAt: entry.lastAccessedAt,
    );
  }
  @HiveField(0)
  final String uuid;

  @HiveField(1)
  final String path;

  @HiveField(2)
  final bool isFavorite;

  @HiveField(3)
  final DateTime lastAccessedAt;

  // Convert from Hive object to domain entity
  WorkspaceEntry toEntity() {
    return WorkspaceEntry(
      uuid: uuid,
      path: path,
      isFavorite: isFavorite,
      lastAccessedAt: lastAccessedAt,
    );
  }
}
