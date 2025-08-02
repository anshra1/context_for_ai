import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/tree_entry.dart';

part 'tree_entry_model.freezed.dart';
part 'tree_entry_model.g.dart';

@freezed
class TreeEntryModel with _$TreeEntryModel {
  const factory TreeEntryModel({
    required String name,
    required String path,
    required bool isDirectory,
    int? size,
    DateTime? lastModified,
    @Default(true) bool isReadable,
  }) = _TreeEntryModel;

  const TreeEntryModel._();

  factory TreeEntryModel.fromJson(Map<String, dynamic> json) =>
      _$TreeEntryModelFromJson(json);

  /// Convert from domain entity
  factory TreeEntryModel.fromEntity(TreeEntry entity) {
    return TreeEntryModel(
      name: entity.name,
      path: entity.path,
      isDirectory: entity.isDirectory,
      size: entity.size,
      lastModified: entity.lastModified,
      isReadable: entity.isReadable,
    );
  }

  /// Convert to domain entity
  TreeEntry toEntity() {
    return TreeEntry(
      name: name,
      path: path,
      isDirectory: isDirectory,
      size: size,
      lastModified: lastModified,
      isReadable: isReadable,
    );
  }

  /// Create from file system entity
  static TreeEntryModel fromFileSystemEntity({
    required String name,
    required String path,
    required bool isDirectory,
    int? size,
    DateTime? lastModified,
    bool isReadable = true,
  }) {
    return TreeEntryModel(
      name: name,
      path: path,
      isDirectory: isDirectory,
      size: size,
      lastModified: lastModified,
      isReadable: isReadable,
    );
  }
}