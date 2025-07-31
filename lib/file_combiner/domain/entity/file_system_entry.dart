import 'package:freezed_annotation/freezed_annotation.dart';

part 'file_system_entry.freezed.dart';
part 'file_system_entry.g.dart';

// i need to give tha exception code

@freezed
class FileSystemEntry with _$FileSystemEntry {
  const factory FileSystemEntry({
    required String name,
    required String path,
    required bool isDirectory,
    int? size, // Optional size
  }) = _FileSystemEntry;

  factory FileSystemEntry.fromJson(Map<String, dynamic> json) => _$FileSystemEntryFromJson(json);
}