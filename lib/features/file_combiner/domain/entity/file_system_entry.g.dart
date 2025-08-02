// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_system_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FileSystemEntryImpl _$$FileSystemEntryImplFromJson(
        Map<String, dynamic> json) =>
    _$FileSystemEntryImpl(
      name: json['name'] as String,
      path: json['path'] as String,
      isDirectory: json['isDirectory'] as bool,
      size: (json['size'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$FileSystemEntryImplToJson(
        _$FileSystemEntryImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'path': instance.path,
      'isDirectory': instance.isDirectory,
      'size': instance.size,
    };
