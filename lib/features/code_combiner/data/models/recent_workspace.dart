// Last Edited: 2025-08-12 00:00:00
// Edit History:
//      - 2025-08-12 00:00:00: Removed name field and added displayName getter
//        - Purpose: Simplify API by auto-extracting folder name from path
//      - 2025-08-11 14:39:00: Applied 80-character line limit to edit
//        comments - Purpose: Improve readability and maintain consistent
//        formatting
//      - 2025-08-11 14:36:00: Converted to Freezed model with JSON
//        serialization - Purpose: Eliminate boilerplate code and add
//        type-safe serialization

import 'package:freezed_annotation/freezed_annotation.dart';

part 'recent_workspace.freezed.dart';
part 'recent_workspace.g.dart';

@freezed
class RecentWorkspace with _$RecentWorkspace {
  const factory RecentWorkspace({
    required String path,
    required DateTime lastAccessed,
    required bool isFavorite,
  }) = _RecentWorkspace;

  factory RecentWorkspace.fromJson(Map<String, dynamic> json) =>
      _$RecentWorkspaceFromJson(json);

  const RecentWorkspace._();
}
