// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_setting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppSettingsImpl _$$AppSettingsImplFromJson(Map<String, dynamic> json) =>
    _$AppSettingsImpl(
      excludedFileExtensions: (json['excludedFileExtensions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      excludedNames: (json['excludedNames'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      showHiddenFiles: json['showHiddenFiles'] as bool,
      maxTokenCount: (json['maxTokenCount'] as num?)?.toInt(),
      stripComments: json['stripComments'] as bool,
      warnOnTokenExceed: json['warnOnTokenExceed'] as bool,
    );

Map<String, dynamic> _$$AppSettingsImplToJson(_$AppSettingsImpl instance) =>
    <String, dynamic>{
      'excludedFileExtensions': instance.excludedFileExtensions,
      'excludedNames': instance.excludedNames,
      'showHiddenFiles': instance.showHiddenFiles,
      'maxTokenCount': instance.maxTokenCount,
      'stripComments': instance.stripComments,
      'warnOnTokenExceed': instance.warnOnTokenExceed,
    };
