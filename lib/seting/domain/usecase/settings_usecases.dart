import 'package:context_for_ai/core/typedefs/type.dart';
import 'package:context_for_ai/core/usecase/usecase.dart';
import 'package:context_for_ai/seting/domain/repository/settings_repository.dart';
import 'package:context_for_ai/seting/model/app_setting.dart';

class LoadSettings extends FutureUseCaseWithoutParams<AppSettings> {
  LoadSettings({required this.repository});

  final SettingsRepository repository;

  @override
  ResultFuture<AppSettings> call() {
    return repository.loadSettings();
  }
}

class SaveSettings extends FutureUseCaseWithParams<void, SaveSettingsParams> {
  SaveSettings({required this.repository});

  final SettingsRepository repository;

  @override
  ResultFuture<void> call(SaveSettingsParams params) {
    return repository.saveSettings(params.settings);
  }
}

class SaveSettingsParams {
  SaveSettingsParams({required this.settings});
  final AppSettings settings;
}

class ResetSettings extends FutureUseCaseWithoutParams<void> {
  ResetSettings({required this.repository});

  final SettingsRepository repository;

  @override
  ResultFuture<void> call() {
    return repository.resetToDefaults();
  }
}