# Interview Prep Notes: Context for AI (Text Merger)

## 1. Project Overview & Elevator Pitch
- **Project Name:** Context for AI (Text Merger)
- **Goal:** To combine multiple text and code files into a single context file, optimized for Large Language Models (LLMs) like Claude or ChatGPT.
- **Key Problem Solved:** Manually copying and pasting files from different directories for AI context is tedious. This app streamlines the process by allowing users to select a workspace, pick specific files/folders, and merge their contents into an AI-friendly format, automatically handling file sizes, binary files, and token limits.

## 2. Architecture & Tech Stack
- **Framework:** Flutter (Cross-platform desktop app)
- **Architecture Pattern:** Clean Architecture (Feature-first approach: `data`, `domain`, `presentation` layers).
  - *Domain:* Contains `CodeCombinerUseCase` which acts as a facade over `CodeCombinerRepository`.
  - *Data:* Contains datasources like `FileSystemDataSource` and `LocalStorageDataSource`.
  - *Presentation:* Contains UI pages and Cubits for state management.
- **State Management:** BLoC / Cubit patterns (`WorkspaceCubit`, `FileExplorerCubit`, `SettingsCubit`, `ThemeCubit`).
- **Dependency Injection:** `get_it` for service locator pattern.
- **Routing:** `go_router`
- **Local Storage:** `shared_preferences` for storing app settings, recent workspaces, and filter settings (Note: `hive` is in `pubspec.yaml` but `shared_preferences` handles the core data persistence via JSON encoding).
- **UI/Design System:** Custom `material_design_system` package with dynamic theming.
- **Other Tools:** `dartz` (functional programming/Either), `freezed` & `json_serializable` (immutable data & JSON parsing), `toastification` (UI notifications).

## 3. Core Features & Implementation Details

### A. Workspace Management (`WorkspaceCubit` & `LocalStorageDataSource`)
- **Functionality:** Users can open directories as workspaces and maintain a list of recent and favorite workspaces.
- **Implementation:** 
  - `LocalStorageDataSource` persists a list of `RecentWorkspace` objects using `SharedPreferences` by JSON encoding/decoding.
  - Maintains a size limit of 15 recent workspaces.
  - Custom deduplication and sorting logic (Favorites first, then ordered by `lastAccessed` date).

### B. File Exploring and Selection (`FileExplorerCubit` & `FileSystemDataSource`)
- **Functionality:** Scans a selected directory, builds a file tree, and allows users to select/deselect specific files or folders.
- **Implementation:** 
  - Recursively scans directories without following symlinks to prevent infinite loops (`FileSystemDataSourceImpl._scanDirectoryRecursive`).
  - Implements strict validation: checks if paths exist, checks for null bytes, prevents path traversal (`..`), and checks read permissions.
  - Converts file trees into `FileNode` instances, assigning UUIDs to nodes, and keeping track of parent-child relationships.

### C. Code Combining / Export Logic (`FileSystemDataSourceImpl.combineAndExportFiles`)
- **Functionality:** Reads selected files, strips comments if requested, merges them into formatted output, and calculates token estimates.
- **Implementation:**
  - **Batch Processing:** Reads files in concurrent batches (`Future.wait` with batch size 10) for maximum performance without hitting OS file handle limits.
  - **File Size Checks:** Enforces a 5MB per-file limit (`readFileContent` checks size before reading).
  - **Binary Checking:** Automatically skips binary files (.png, .exe, .pdf, etc.) based on standard extensions.
  - **Comment Stripping:** Smart custom regex-like parser (`_stripCommentsFromContent`) that removes standard comments (`//` and `/* */`) but wisely preserves documentation comments (`///` and `/** */`). It also handles edge cases inside strings.
  - **Export Compilation:** Creates a unified file starting with an "EXPORT SUMMARY" (total files, successes, failures).
  - **Metadata:** Estimates tokens (`characters / 4`) and calculates size in MB. It also splits the final output into multiple chunks if the size exceeds user-defined limits (`AppSettings.fileSplitSizeInMB`).

### D. Settings and Theming (`ThemeCubit`, `SettingsCubit`)
- **Functionality:** Customizable token limits, export locations, and themes.
- **Implementation:** 
  - Custom `SystemTokenToColorSchemeConverter` parses brand seeds (Facebook-like color traits: `primary`, `neutral`, `error`, etc.) to generate dynamic Dark/Light themes across the app.

## 4. Possible Interview Questions & Answers

**Q: How do you handle reading hundreds of files efficiently without crashing the app?**
*A: I implemented batch processing in the `FileSystemDataSource`. Instead of reading all files at once, the app processes them in batches of 10 using `Future.wait()`. This ensures we don't block the UI thread and avoid hitting OS-level file descriptor limits while maintaining high concurrency.*

**Q: How does the comment stripper work? Does it break if a URL has `//` in it?**
*A: It's a custom character-by-character parser (state machine). It skips removing `//` if it determines that it's currently "inside" a string literal (by tracking quotes like `"` and `'` and escape sequences `\`). It also explicitly looks ahead to prevent removing doc comments (`///` or `/**`).*

**Q: Why use Clean Architecture for a relatively simple utility app?**
*A: Separation of concerns. By keeping file system operations in `FileSystemDataSource` and local storage in `LocalStorageDataSource`, the application rules (Use Cases) and UI (Cubits) are decoupled from Dart's `dart:io` or Flutter plugins. This makes the logic extremely testable via mocking and allows easy platform-specific tweaks if needed later.*

**Q: How do you manage the File Explorer tree state?**
*A: `FileSystemDataSource` scans the local directory recursively and maps every file and folder to a `FileNode` model with a UUID, storing relationships (parentId, childIds). The `FileExplorerCubit` receives this map and propagates `SelectionState` (checked, unchecked, indeterminate) dynamically down to children and up to parents whenever a user clicks a checkbox.*

**Q: How did you implement local storage, and why did you choose that approach?**
*A: I used `SharedPreferences` combined with `jsonEncode`/`jsonDecode` mapped to strongly-typed data classes (via `freezed`/`json_serializable`). E.g., recent workspaces are serialized and saved under the `recent_workspaces` key. It's lightweight, predictable, and fully synchronous after the initial load, which is sufficient since the data payload (max 15 workspaces, simple settings) is very small. (Though the project is preconfigured for Hive if we need to scale up to complex relational data).*
