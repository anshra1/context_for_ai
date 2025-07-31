// ignore_for_file: unused_element

import 'package:context_for_ai/core/services/hive_setup_service.dart';
import 'package:context_for_ai/core/theme/cubit/theme_cubit.dart';
import 'package:get_it/get_it.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  await _core();
  await _hive();
}

Future<void> _core() async {
  sl.registerLazySingleton<ThemeCubit>(ThemeCubit.new);
}

Future<void> _hive() async {
  sl.registerLazySingleton(HiveSetupService.new);

  // Initialize Hive
  await sl<HiveSetupService>().init();
}
