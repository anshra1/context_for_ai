import 'package:context_for_ai/core/theme/cubit/theme_cubit.dart';
import 'package:context_for_ai/features/code_combiner/data/datasources/file_system_data_source.dart';
import 'package:context_for_ai/features/code_combiner/data/datasources/local_storage_data_source.dart';
import 'package:context_for_ai/features/code_combiner/data/repositories/code_combiner_repository_impl.dart';
import 'package:context_for_ai/features/code_combiner/domain/repositories/code_combiner_repository.dart';
import 'package:context_for_ai/features/code_combiner/domain/usecases/code_combiner_usecase.dart';
import 'package:context_for_ai/features/code_combiner/presentation/cubits/file_explorer_cubit.dart';
import 'package:context_for_ai/features/code_combiner/presentation/cubits/workspace_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  await _core();
  await _codeCombiner();
}

Future<void> _core() async {
  // Theme cubit
  sl
    ..registerLazySingleton<ThemeCubit>(ThemeCubit.new)
    // SharedPreferences as async singleton
    ..registerSingletonAsync<SharedPreferences>(SharedPreferences.getInstance);
  await sl.isReady<SharedPreferences>();
}

Future<void> _codeCombiner() async {
  // Data sources
  sl
    ..registerLazySingleton<FileSystemDataSource>(FileSystemDataSourceImpl.new)
    ..registerLazySingleton<LocalStorageDataSource>(
      () => LocalStorageDataSourceImpl(sl<SharedPreferences>()),
    )
    // Repository
    ..registerLazySingleton<CodeCombinerRepository>(
      () => CodeCombinerRepositoryImpl(
        fileSystemDataSource: sl<FileSystemDataSource>(),
        localStorageDataSource: sl<LocalStorageDataSource>(),
      ),
    )
    // Use case
    ..registerLazySingleton<CodeCombinerUseCase>(
      () => CodeCombinerUseCase(repository: sl<CodeCombinerRepository>()),
    )
    // Cubits
    ..registerFactory<WorkspaceCubit>(
      () => WorkspaceCubit(codeCombinerUseCase: sl<CodeCombinerUseCase>()),
    )
    ..registerFactory<FileExplorerCubit>(
      () => FileExplorerCubit(useCase: sl<CodeCombinerUseCase>()),
    );
}
