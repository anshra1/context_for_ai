import 'package:context_for_ai/core/error/error_mapper.dart';
import 'package:context_for_ai/core/typedefs/type.dart';
import 'package:context_for_ai/seting/data/datasource/setting_datasource.dart';
import 'package:context_for_ai/seting/domain/repository/settings_repository.dart';
import 'package:context_for_ai/seting/model/app_setting.dart';
import 'package:dartz/dartz.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this.dataSource);

  final SettingsDataSource dataSource;

  @override
  ResultFuture<AppSettings> loadSettings() async {
    try {
      final result = await dataSource.loadSettings();
      return Right(result);
    } on Exception catch (e) {
      return Left(ErrorMapper.mapErrorToFailure(e));
    }
  }

  @override
  ResultFuture<void> saveSettings(AppSettings settings) async {
    try {
      final result = await dataSource.saveSettings(settings);
      return Right(result);
    } on Exception catch (e) {
      return Left(ErrorMapper.mapErrorToFailure(e));
    }
  }

  @override
  ResultFuture<void> resetToDefaults() async {
    try {
      final result = await dataSource.resetToDefaults();
      return Right(result);
    } on Exception catch (e) {
      return Left(ErrorMapper.mapErrorToFailure(e));
    }
  }
}