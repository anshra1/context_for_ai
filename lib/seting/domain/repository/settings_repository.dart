import 'package:context_for_ai/core/typedefs/type.dart';
import 'package:context_for_ai/seting/model/app_setting.dart';

abstract class SettingsRepository {
  ResultFuture<AppSettings> loadSettings();
  ResultFuture<void> saveSettings(AppSettings settings);
  ResultFuture<void> resetToDefaults();
}