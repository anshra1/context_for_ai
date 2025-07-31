import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_setting.freezed.dart';
part 'app_setting.g.dart';

@freezed
class AppSettings with _$AppSettings {
  const factory AppSettings({
    required List<String> excludedFileExtensions,
    required List<String> excludedNames,
    required bool showHiddenFiles,
    required int? maxTokenCount,
    required bool stripComments,
    required bool warnOnTokenExceed,
  }) = _AppSettings;

  factory AppSettings.defaultSettings() {
    return const AppSettings(
      excludedFileExtensions: ['.lock', '.iml', '.png', '.jpg', '.jpeg', '.gif', '.ico', '.apk', '.aab', '.ipa', '.exe', '.dll', '.so', '.dylib'],
      excludedNames: ['build/', '.dart_tool/', 'node_modules/', '.git/', '.idea/'],
      showHiddenFiles: false,
      maxTokenCount: 8000,
      stripComments: false,
      warnOnTokenExceed: true,
    );
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) => _$AppSettingsFromJson(json);
}