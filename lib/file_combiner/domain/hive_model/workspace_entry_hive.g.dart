// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_entry_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkspaceEntryHiveAdapter extends TypeAdapter<WorkspaceEntryHive> {
  @override
  final int typeId = 0;

  @override
  WorkspaceEntryHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkspaceEntryHive(
      uuid: fields[0] as String,
      path: fields[1] as String,
      isFavorite: fields[2] as bool,
      lastAccessedAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WorkspaceEntryHive obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.path)
      ..writeByte(2)
      ..write(obj.isFavorite)
      ..writeByte(3)
      ..write(obj.lastAccessedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkspaceEntryHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
