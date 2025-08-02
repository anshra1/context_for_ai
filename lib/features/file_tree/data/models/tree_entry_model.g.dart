// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tree_entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TreeEntryModelImpl _$$TreeEntryModelImplFromJson(Map<String, dynamic> json) =>
    _$TreeEntryModelImpl(
      name: json['name'] as String,
      path: json['path'] as String,
      isDirectory: json['isDirectory'] as bool,
      size: (json['size'] as num?)?.toInt(),
      lastModified: json['lastModified'] == null
          ? null
          : DateTime.parse(json['lastModified'] as String),
      isReadable: json['isReadable'] as bool? ?? true,
    );

Map<String, dynamic> _$$TreeEntryModelImplToJson(
        _$TreeEntryModelImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'path': instance.path,
      'isDirectory': instance.isDirectory,
      'size': instance.size,
      'lastModified': instance.lastModified?.toIso8601String(),
      'isReadable': instance.isReadable,
    };
