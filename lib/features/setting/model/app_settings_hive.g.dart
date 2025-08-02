// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsHiveAdapter extends TypeAdapter<AppSettingsHive> {
  @override
  final int typeId = 1;

  @override
  AppSettingsHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettingsHive(
      excludedFileExtensions: (fields[0] as List).cast<String>(),
      excludedNames: (fields[1] as List).cast<String>(),
      showHiddenFiles: fields[2] as bool,
      maxTokenCount: fields[3] as int?,
      stripComments: fields[4] as bool,
      warnOnTokenExceed: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettingsHive obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.excludedFileExtensions)
      ..writeByte(1)
      ..write(obj.excludedNames)
      ..writeByte(2)
      ..write(obj.showHiddenFiles)
      ..writeByte(3)
      ..write(obj.maxTokenCount)
      ..writeByte(4)
      ..write(obj.stripComments)
      ..writeByte(5)
      ..write(obj.warnOnTokenExceed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
