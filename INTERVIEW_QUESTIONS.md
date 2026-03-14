# Hiring Manager Interview Questions — Context for AI

---

## 1. Project Overview & Motivation

**Q1: Walk me through this project. What does it do and why did you build it?**
> It's a cross-platform Flutter desktop app that merges multiple code/text files into a single context file for LLMs. I built it because manually copying files for AI context is repetitive—this automates workspace selection, file picking, comment stripping, token estimation, and smart file splitting.

**Q2: Who is the target user? What's the typical use case?**
> Developers who use LLMs like Claude or ChatGPT for code review, debugging, or documentation. Instead of manually copy-pasting 20+ files, they open a workspace, check the files they need, and export a single merged document.

**Q3: What makes this project different from just using `cat` or a shell script?**
> It provides a GUI file tree with selective picking, auto-skips binary files, strips non-doc comments while preserving `///` doc comments, estimates token counts, splits output into chunks if too large, and maintains recent/favorite workspaces—none of which a simple `cat` command handles.

---

## 2. Architecture & Design Decisions

**Q4: Why did you choose Clean Architecture for this project?**
> Separation of concerns. File I/O logic lives in `FileSystemDataSource`, persistence in `LocalStorageDataSource`, business rules in `CodeCombinerUseCase`, and UI in Cubits/Pages. This makes each layer independently testable and swappable—e.g., I can swap SharedPreferences for Hive without touching business logic.

**Q5: Explain the data flow from when a user clicks "Open Directory" to seeing the file tree.**
> 1. UI calls `WorkspaceCubit.openWorkspace(path)`
> 2. Cubit calls `CodeCombinerUseCase.openDirectoryTree(path)`
> 3. UseCase delegates to `CodeCombinerRepository`
> 4. Repository calls `FileSystemDataSource.scanDirectory(path)`
> 5. DataSource recursively walks the directory, creates `FileNode` objects with UUIDs, parent-child relationships
> 6. Returns `Map<String, FileNode>` back up the chain
> 7. Cubit emits new state → UI rebuilds the tree

**Q6: Why feature-first folder structure instead of layer-first?**
> Feature-first scales better. If I add a "Template Manager" feature tomorrow, I create `/features/template_manager/` with its own `data`, `domain`, `presentation` folders—completely isolated. Layer-first (all repositories in one folder) creates coupling and large, hard-to-navigate directories.

**Q7: Why `get_it` for DI instead of Provider or Riverpod?**
> `get_it` is a pure Dart service locator—it works outside the widget tree. I can resolve dependencies in data sources, use cases, and even `main.dart` without needing a `BuildContext`. Provider/Riverpod are widget-tree-bound, which limits where you can inject.

---

## 3. State Management (BLoC/Cubit)

**Q8: Why Cubit over full BLoC with events?**
> Cubits are simpler—direct method calls instead of event classes. For this app, the interactions are straightforward (open workspace, toggle selection, export). Full BLoC events would add boilerplate without benefit. I'd use BLoC if I needed event transformations like `debounce` or `throttle`.

**Q9: How do you handle the file tree's selection state? If I check a parent folder, what happens to children?**
> Each `FileNode` has a `SelectionState` enum: `checked`, `unchecked`, `indeterminate`. When a parent is checked, the `FileExplorerCubit` propagates `checked` down to all children recursively. When a child is unchecked, it walks up the parent chain—if all siblings are unchecked, parent becomes `unchecked`; if some are checked, parent becomes `indeterminate`.

**Q10: How do you prevent unnecessary UI rebuilds in the file tree?**
> `BlocBuilder` with `buildWhen` — I only rebuild when the specific piece of state changes. For example, `ThemeCubit` uses `buildWhen: (prev, curr) => prev.themeMode != curr.themeMode`. The file tree nodes use the flat `Map<String, FileNode>` structure so only changed nodes trigger rebuilds, not the entire tree.

---

## 4. Data Layer & Storage

**Q11: How do you persist recent workspaces? Walk me through the serialization.**
> `LocalStorageDataSource` stores a JSON-encoded list of `RecentWorkspace` objects in `SharedPreferences` under the key `recent_workspaces`. Each workspace is serialized via `freezed`'s auto-generated `toJson()`. On load, I `jsonDecode` → `List<dynamic>` → `map` each to `RecentWorkspace.fromJson()`. Sorted with favorites first, then by `lastAccessed` descending.

**Q12: Why SharedPreferences over Hive for storage?**
> The data is small—max 15 workspaces, a few settings objects. SharedPreferences is simpler, has no initialization ceremony, and is sufficient for flat key-value data. Hive is in the pubspec as a future option if we need indexed queries or larger datasets.

**Q13: How do you handle corrupted storage data?**
> I catch `FormatException` separately from general `Exception` in every load method. If JSON is corrupted, I throw a typed `StorageException` with `title: 'Storage Data Corruption'` and a user-friendly message. The UI can then show a toast and fall back to defaults via `AppSettings.defaultsWithDocumentsPath()`.

---

## 5. File System Operations

**Q14: How does the recursive directory scan work? What about performance?**
> `_scanDirectoryRecursive` uses `directory.list(followLinks: false)` to avoid symlink infinite loops. Each entity gets a UUID, is wrapped in a `FileNode`, and stored in a flat `Map<String, FileNode>` with parent-child ID references. If a file or directory is inaccessible, it's skipped silently—one bad file doesn't crash the entire scan.

**Q15: How do you handle the "combine and export" for 500+ files?**
> Batch processing with `Future.wait()` in groups of 10. For each file: check existence → check permissions → skip if binary → check size (≤5MB) → read content → optionally strip comments. Failed files are tracked separately. The combined output includes an "EXPORT SUMMARY" header with success/failure counts.

**Q16: Explain the comment stripping logic. How do you avoid breaking code?**
> It's a character-by-character state machine parser:
> - Tracks whether we're inside a string literal (handles `"`, `'`, and escape sequences `\"`)
> - Tracks multi-line comment state (`/* */`)
> - Looks ahead to distinguish `//` (remove) from `///` (keep) and `/*` (remove) from `/**` (keep)
> - This means `//` inside a string like `"https://example.com"` is preserved, and doc comments for API documentation are kept intact.

**Q17: What security validations do you perform on file paths?**
> - Empty path check
> - Null byte injection check (`\x00`)
> - Path must be absolute (`path.isAbsolute`)
> - Path traversal prevention (rejects `..`)
> - Directory existence and accessibility checks
> - Path normalization via `path.normalize()`

---

## 6. Error Handling

**Q18: How is error handling structured in this project?**
> Custom exception hierarchy: `FileSystemException`, `StorageException`, `ValidationException`. Each carries `methodName`, `originalError`, `userMessage` (for UI), `title`, and optional `stackTrace`/`debugDetails`. The repository layer catches these and wraps them in `dartz`'s `Either<Failure, Success>` type—so the Cubit never deals with try-catch, just `fold()`.

**Q19: What happens if the app crashes during startup?**
> `main()` has a top-level try-catch. If `init()` (DI setup) or anything else fails, it catches the error and runs a fallback `MaterialApp` that displays the error message on screen. There's also `FlutterError.onError` for catching framework-level errors.

---

## 7. Models & Code Generation

**Q20: Why use Freezed instead of hand-writing data classes?**
> Freezed auto-generates `==`, `hashCode`, `toString()`, `copyWith()`, and JSON serialization. For a model like `AppSettings` with 5+ fields, writing all that by hand is error-prone and tedious. It also makes classes truly immutable and integrates with `json_serializable` for type-safe serialization.

**Q21: What's the `ResultFuture` typedef?**
> It's `typedef ResultFuture<T> = Future<Either<Failure, T>>` from `dartz`. Every use case and repository method returns this—the caller uses `.fold()` to handle success or failure without exceptions bubbling up. It makes error handling explicit and functional.

---

## 8. Theming

**Q22: How does your dynamic theming system work?**
> I have a custom `material_design_system` package. I define `ReferenceTokens` (brand seed colors like primary, secondary, neutral, error, success). A `StandardDarkThemeGenerator` or `StandardLightThemeGenerator` converts these seeds into `SystemTokens`. Those tokens are then converted to Flutter's `ColorScheme` via `SystemTokenToColorSchemeConverter`. The `ThemeCubit` manages the current `ThemeMode` (light/dark/system) and rebuilds the entire MaterialApp when it changes.

---

## 9. Testing & Quality

**Q23: How would you test the file system operations without touching real files?**
> The `FileSystemDataSource` is an abstract class. In tests, I'd create a mock implementation (using `mocktail`) that returns predefined `Map<String, FileNode>` data. For integration tests, I'd create a temporary directory with known files using `dart:io`'s `Directory.systemTemp`.

**Q24: How would you test the comment stripping logic?**
> Unit tests with specific input strings covering: single-line `//` comments, multi-line `/* */`, doc comments `///` and `/** */`, comments inside strings, nested quotes, and edge cases like empty files or files with only comments.

---

## 10. Scalability & Future Improvements

**Q25: What would you change if this app needed to handle 10,000+ file projects?**
> - Lazy loading: only scan the top-level directory initially, expand subdirectories on demand
> - Virtualized list rendering (only render visible tree nodes)
> - Isolate-based file reading to keep the UI thread free
> - Stream-based scanning instead of collecting all entities in memory first

**Q26: If you had to add a "search files" feature, how would you implement it?**
> A `SearchCubit` that takes the flat `Map<String, FileNode>` and filters by filename using a debounced text input. For content search, I'd use Dart Isolates to search file contents in parallel, streaming results back to the main isolate as they're found.

**Q27: How would you add cloud sync (e.g., save workspaces to Firebase)?**
> Add a `RemoteStorageDataSource` implementing the same abstract `LocalStorageDataSource` interface. The repository would coordinate between local and remote sources. Use Firebase Firestore for workspace metadata and Firebase Storage for exported files. The Cubit layer wouldn't change at all—that's the power of Clean Architecture.

---

## 11. Behavioral / Soft Questions

**Q28: What was the most challenging part of building this?**
> The comment stripping parser. It needs to handle multiple states simultaneously (inside string, inside multi-line comment, doc vs regular comment) and look ahead without breaking code. Getting the edge cases right—like escaped quotes inside strings containing URL patterns—required careful testing.

**Q29: What would you do differently if you started over?**
> - Use Riverpod instead of get_it for compile-time safety
> - Add Isolate-based file scanning from the start for large projects
> - Implement a proper logging framework beyond `debugPrint`
> - Add CI/CD pipeline with automated testing (the codemagic.yaml exists but could be more robust)

**Q30: How did you ensure code quality?**
> - `very_good_analysis` for strict linting rules
> - `freezed` for immutable, type-safe models
> - Custom typed exceptions instead of generic catches
> - Abstract classes for all data sources enabling mock-based testing
> - Consistent error handling pattern (Either type) across all layers
