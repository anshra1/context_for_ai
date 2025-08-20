import 'package:context_for_ai/core/typedefs/type.dart';
import 'package:context_for_ai/core/usecase/usecase.dart';
import 'package:context_for_ai/features/code_combiner/data/models/app_settings.dart';
import 'package:context_for_ai/features/code_combiner/data/models/filter_settings.dart';
import 'package:context_for_ai/features/code_combiner/data/models/recent_workspace.dart';
import 'package:context_for_ai/features/code_combiner/domain/repositories/local_storage_repository.dart';

class AddRecentWorkspace extends FutureUseCaseWithParams<List<RecentWorkspace>, String> {
  AddRecentWorkspace({required this.localStorageRepository});

  final LocalStorageRepository localStorageRepository;

  @override
  ResultFuture<List<RecentWorkspace>> call(String workspacePath) {
    return localStorageRepository.addRecentWorkspace(workspacePath);
  }
}

class RemoveRecentWorkspace extends FutureUseCaseWithParams<List<RecentWorkspace>, String> {
  RemoveRecentWorkspace({required this.localStorageRepository});

  final LocalStorageRepository localStorageRepository;

  @override
  ResultFuture<List<RecentWorkspace>> call(String workspacePath) {
    return localStorageRepository.removeRecentWorkspace(workspacePath);
  }
}

class LoadRecentWorkspaces extends FutureUseCaseWithoutParams<List<RecentWorkspace>> {
  LoadRecentWorkspaces({required this.localStorageRepository});

  final LocalStorageRepository localStorageRepository;

  @override
  ResultFuture<List<RecentWorkspace>> call() {
    return localStorageRepository.loadRecentWorkspaces();
  }
}

class ClearRecentWorkspaces extends FutureUseCaseWithoutParams<List<RecentWorkspace>> {
  ClearRecentWorkspaces({required this.localStorageRepository});

  final LocalStorageRepository localStorageRepository;

  @override
  ResultFuture<List<RecentWorkspace>> call() {
    return localStorageRepository.clearRecentWorkspaces();
  }
}

class SaveFilterSettings extends FutureUseCaseWithParams<bool, FilterSettings> {
  SaveFilterSettings({required this.localStorageRepository});

  final LocalStorageRepository localStorageRepository;

  @override
  ResultFuture<bool> call(FilterSettings settings) {
    return localStorageRepository.saveFilterSettings(settings);
  }
}

class LoadFilterSettings extends FutureUseCaseWithoutParams<FilterSettings> {
  LoadFilterSettings({required this.localStorageRepository});

  final LocalStorageRepository localStorageRepository;

  @override
  ResultFuture<FilterSettings> call() {
    return localStorageRepository.loadFilterSettings();
  }
}

class SaveAppSettings extends FutureUseCaseWithParams<void, AppSettings> {
  SaveAppSettings({required this.localStorageRepository});

  final LocalStorageRepository localStorageRepository;

  @override
  ResultFuture<void> call(AppSettings settings) {
    return localStorageRepository.saveAppSettings(settings);
  }
}

class LoadAppSettings extends FutureUseCaseWithoutParams<AppSettings> {
  LoadAppSettings({required this.localStorageRepository});

  final LocalStorageRepository localStorageRepository;

  @override
  ResultFuture<AppSettings> call() {
    return localStorageRepository.loadAppSettings();
  }
}