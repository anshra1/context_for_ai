// // lib/core/services/hive_setup_service.dart
// import 'package:context_for_ai/core/constants/hive_constants.dart';
// import 'package:context_for_ai/features/file_combiner/domain/hive_model/workspace_entry_hive.dart';
// import 'package:context_for_ai/features/setting/model/app_settings_hive.dart';
// import 'package:flutter/foundation.dart';
// import 'package:hive_flutter/hive_flutter.dart';

// class HiveSetupService {
//   Future<void> init() async {
//     try {
//       // Initialize Hive with Flutter
//       await Hive.initFlutter();
// // 
//       // Register all adapters
//       _registerAdapters();

//       // Open all required boxes
//       await _openBoxes();
//     } catch (e, stack) {
//       // Log the error - you might want to use your logger here
//       if (kDebugMode) {
//         print('Hive initialization failed: $e\n$stack');
//       }
//       rethrow;
//     }
//   }

//   void _registerAdapters() {
//     Hive..registerAdapter(WorkspaceEntryHiveAdapter())
//     ..registerAdapter(AppSettingsHiveAdapter());
//   }

//   Future<void> _openBoxes() async {
//     await Hive.openBox<WorkspaceEntryHive>(HiveBoxNames.workspaceHistory);
//     await Hive.openBox<AppSettingsHive>(HiveBoxNames.appSettings);
//   }

//   // Optional: Close all boxes when app shuts down
//   Future<void> closeBoxes() async {
//     await Hive.close();
//   }
// }
