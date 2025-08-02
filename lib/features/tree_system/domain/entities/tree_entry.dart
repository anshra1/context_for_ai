import 'package:freezed_annotation/freezed_annotation.dart';

part 'tree_entry.freezed.dart';

@freezed
class TreeEntry with _$TreeEntry {
  const factory TreeEntry({
    required String name,
    required String path,
    required bool isDirectory,
    int? size,
    @Default(true) bool isReadable,
  }) = _TreeEntry;
}