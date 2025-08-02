import 'package:context_for_ai/core/constants/hive_constants.dart';
import 'package:context_for_ai/core/error/exception.dart';
import 'package:context_for_ai/features/setting/model/app_setting.dart';
import 'package:context_for_ai/features/setting/model/app_settings_hive.dart';
import 'package:hive/hive.dart';

abstract class SettingsDataSource {
  Future<AppSettings> loadSettings();
  Future<void> saveSettings(AppSettings settings);
  Future<void> resetToDefaults();
}

class SettingsDataSourceImpl implements SettingsDataSource {
  // Value constructor for easy testing
  const SettingsDataSourceImpl({
    required Box<AppSettingsHive> box,
  }) : _box = box;

  final Box<AppSettingsHive> _box;

  @override
  Future<AppSettings> loadSettings() async {
    final box = _box;
    if (!box.isOpen) {
      throw const StorageException(
        originalError: 'Hive box is not open',
        methodName: 'loadSettings',
        userMessage: 'Failed to load settings',
        title: 'Storage Error',
        isRecoverable: false,
      ); // Define this exception
    }

    try {
      final settingsEntry = box.get(HiveKeys.settingsKey);
      if (settingsEntry != null) {
        try {
          return settingsEntry.toModel(); // If using adapter
        } catch (e) {
          // Let conversion errors (like FormatException) propagate unchanged
          rethrow;
        }
        // If using JSON: return AppSettings.fromJson(settingsEntry as Map<String, dynamic>);
      } else {
        // If no settings found, return defaults and potentially save them
        final defaultSettings = AppSettings.defaultSettings();
        await saveSettings(defaultSettings);
        return defaultSettings;
      }
    } on Exception catch (e, stack) {
      // Only wrap Hive-specific errors
      throw StorageException(
        originalError: e.toString(),
        methodName: 'loadSettings',
        userMessage: 'Failed to load settings',
        title: 'Storage Error',
        stackTrace: stack.toString(),
        isRecoverable: false,
      );
    }
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    final box = _box;
    if (!box.isOpen) {
      throw const StorageException(
        userMessage: 'App settings storage is not available',
        methodName: 'saveSettings',
        originalError: 'Hive box is not open',
        title: 'Storage Error',
        isRecoverable: false,
      );
    }

    try {
      final settingsHive = AppSettingsHive.fromModel(settings); // If using adapter
      // If using JSON: final settingsJson = settings.toJson();
      await box.put(HiveKeys.settingsKey, settingsHive); // or settingsJson
    } catch (e, stack) {
      throw StorageException(
        originalError: e.toString(),
        methodName: 'saveSettings',
        userMessage: 'Failed to save settings',
        title: 'Storage Error',
        stackTrace: stack.toString(),
        isRecoverable: false,
      );
    }
  }

  @override
  Future<void> resetToDefaults() async {
    final defaultSettings = AppSettings.defaultSettings();
    await saveSettings(defaultSettings);
  }
}

// Factory for easier construction and testing
class SettingsDataSourceFactory {
  static SettingsDataSource create() {
    final box = Hive.box<AppSettingsHive>(HiveBoxNames.appSettings);
    return SettingsDataSourceImpl(box: box);
  }

  static SettingsDataSource createForTesting({
    required Box<AppSettingsHive> box,
  }) {
    return SettingsDataSourceImpl(box: box);
  }
}
