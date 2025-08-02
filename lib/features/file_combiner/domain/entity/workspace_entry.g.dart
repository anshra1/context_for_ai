// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkspaceEntryImpl _$$WorkspaceEntryImplFromJson(Map<String, dynamic> json) =>
    _$WorkspaceEntryImpl(
      uuid: json['uuid'] as String,
      path: json['path'] as String,
      isFavorite: json['isFavorite'] as bool,
      lastAccessedAt: DateTime.parse(json['lastAccessedAt'] as String),
    );

Map<String, dynamic> _$$WorkspaceEntryImplToJson(
        _$WorkspaceEntryImpl instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'path': instance.path,
      'isFavorite': instance.isFavorite,
      'lastAccessedAt': instance.lastAccessedAt.toIso8601String(),
    };
