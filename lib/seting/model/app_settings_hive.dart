// lib/core/models/app_settings_hive.dart

import 'package:context_for_ai/seting/model/app_setting.dart';
import 'package:hive/hive.dart';

part 'app_settings_hive.g.dart';

@HiveType(typeId: 1) // Assign a unique typeId
class AppSettingsHive extends HiveObject {
  AppSettingsHive({
    required this.excludedFileExtensions,
    required this.excludedNames,
    required this.showHiddenFiles,
    required this.maxTokenCount,
    required this.stripComments,
    required this.warnOnTokenExceed,
  });

  factory AppSettingsHive.fromModel(AppSettings settings) {
    return AppSettingsHive(
      excludedFileExtensions: settings.excludedFileExtensions,
      excludedNames: settings.excludedNames,
      showHiddenFiles: settings.showHiddenFiles,
      maxTokenCount: settings.maxTokenCount,
      stripComments: settings.stripComments,
      warnOnTokenExceed: settings.warnOnTokenExceed,
    );
  }
  @HiveField(0)
  List<String> excludedFileExtensions;

  @HiveField(1)
  List<String> excludedNames;

  @HiveField(2)
  bool showHiddenFiles;

  @HiveField(3)
  int? maxTokenCount;

  @HiveField(4)
  bool stripComments;

  @HiveField(5)
  bool warnOnTokenExceed;

  AppSettings toModel() {
    return AppSettings(
      excludedFileExtensions: excludedFileExtensions,
      excludedNames: excludedNames,
      showHiddenFiles: showHiddenFiles,
      maxTokenCount: maxTokenCount,
      stripComments: stripComments,
      warnOnTokenExceed: warnOnTokenExceed,
     
    );
  }
}
