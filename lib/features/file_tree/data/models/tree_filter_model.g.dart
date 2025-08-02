// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tree_filter_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TreeFilterModelImpl _$$TreeFilterModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TreeFilterModelImpl(
      allowedExtensions: (json['allowedExtensions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      excludedFolders: (json['excludedFolders'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ['.git', 'node_modules', '.DS_Store'],
      excludedExtensions: (json['excludedExtensions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      showHiddenFiles: json['showHiddenFiles'] as bool? ?? false,
      searchQuery: json['searchQuery'] as String? ?? '',
    );

Map<String, dynamic> _$$TreeFilterModelImplToJson(
        _$TreeFilterModelImpl instance) =>
    <String, dynamic>{
      'allowedExtensions': instance.allowedExtensions,
      'excludedFolders': instance.excludedFolders,
      'excludedExtensions': instance.excludedExtensions,
      'showHiddenFiles': instance.showHiddenFiles,
      'searchQuery': instance.searchQuery,
    };
