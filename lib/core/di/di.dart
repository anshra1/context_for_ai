// ignore_for_file: unused_element

import 'package:context_for_ai/core/services/hive_setup_service.dart';
import 'package:context_for_ai/core/theme/cubit/theme_cubit.dart';
// File Tree Feature Imports
import 'package:context_for_ai/features/file_tree/data/datasources/file_tree_data_source.dart';
import 'package:context_for_ai/features/file_tree/data/repositories/file_tree_repository_impl.dart';
import 'package:context_for_ai/features/file_tree/domain/repositories/file_tree_repository.dart';
import 'package:context_for_ai/features/file_tree/domain/services/tree_filter_service.dart';
import 'package:context_for_ai/features/file_tree/domain/services/tree_node_service.dart';
import 'package:context_for_ai/features/file_tree/domain/usecases/file_tree_usecases.dart';
import 'package:context_for_ai/features/file_tree/presentation/cubit/file_tree_cubit.dart';
import 'package:context_for_ai/features/setting/data/datasource/setting_datasource.dart';
import 'package:get_it/get_it.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  await _core();
  await _hive();
  await _fileTree();
}

Future<void> _core() async {
  sl.registerLazySingleton<ThemeCubit>(ThemeCubit.new);
}

Future<void> _hive() async {
  sl.registerLazySingleton(HiveSetupService.new);

  // Initialize Hive
  await sl<HiveSetupService>().init();
}

/// File Tree Feature Dependencies
Future<void> _fileTree() async {
  // Domain Services
  sl.registerLazySingleton<TreeFilterService>(() => const TreeFilterService());
  sl.registerLazySingleton<TreeNodeService>(() => const TreeNodeService());

  // Data Sources
  sl.registerLazySingleton<FileTreeDataSource>(
    () => FileTreeDataSourceImpl(
      settingsDataSource: sl<SettingsDataSource>(),
      filterService: sl<TreeFilterService>(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<FileTreeRepository>(
    () => FileTreeRepositoryImpl(dataSource: sl<FileTreeDataSource>()),
  );

  // Use Cases
  sl.registerLazySingleton(
    () => LoadFolderContents(repository: sl<FileTreeRepository>()),
  );
  sl.registerLazySingleton(
    () => LoadFilteredFolderContents(repository: sl<FileTreeRepository>()),
  );
  sl.registerLazySingleton(() => ApplyTreeFilter(repository: sl<FileTreeRepository>()));
  sl.registerLazySingleton(
    () => CalculateTokenCount(repository: sl<FileTreeRepository>()),
  );
  sl.registerLazySingleton(() => ValidatePath(repository: sl<FileTreeRepository>()));
  sl.registerLazySingleton(() => GetGlobalFilter(repository: sl<FileTreeRepository>()));
  sl.registerLazySingleton(
    () => CheckFileReadability(repository: sl<FileTreeRepository>()),
  );
  sl.registerLazySingleton(() => CalculateSelectionState());

  // Cubits (Factory - new instance each time)
  sl.registerFactory(
    () => FileTreeCubit(
      loadFolderContents: sl<LoadFolderContents>(),
      applyTreeFilter: sl<ApplyTreeFilter>(),
      calculateTokenCount: sl<CalculateTokenCount>(),
      validatePath: sl<ValidatePath>(),
      getGlobalFilter: sl<GetGlobalFilter>(),
      checkFileReadability: sl<CheckFileReadability>(),
      calculateSelectionState: sl<CalculateSelectionState>(),
    ),
  );
}
