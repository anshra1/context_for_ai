# Context for AI (Text Merger)

Context for AI is a cross-platform desktop application built with Flutter that simplifies the process of providing codebase context to Large Language Models (LLMs) like Claude or ChatGPT. 

## 🚀 The Problem It Solves
Manually copying and pasting multiple files or directories for AI context is a tedious, repetitive task. This app streamlines the workflow by allowing developers to select workspaces, pick specific files or folders, and merge their contents into a single, AI-friendly format.

## ✨ Key Features
- **Workspace Management:** Easily open directories as workspaces. Keep track of recent and favorite workspaces (up to 15).
- **Advanced File Exploring:** Navigate your local directories with a built-in file tree. Select or deselect specific files and folders to include in your context.
- **Smart Code Combining:**
  - **Batch Processing:** High-performance file reading handles hundreds of files simultaneously using concurrent batches of 10.
  - **Auto-Filtering:** Automatically detects and skips binary files (e.g., `.png`, `.exe`, `.pdf`) and enforces a 5MB per-file size limit.
  - **Intelligent Comment Stripping:** Custom character-by-character parser removes unnecessary comments (`//` and `/* */`) while smartly preserving documentation blocks (`///` and `/** */`). Handles edge cases inside string literals.
- **Token Estimation & File Splitting:** Provides an estimated token count for LLMs and automatically splits the combined text into smaller chunks if it exceeds user-defined size limits.
- **Export Preview:** Detailed export summary including total files processed, successful/failed file counts, and created output file paths.
- **Customizable Settings:** Set token limits, default export locations, file split sizes, and toggle comment stripping.
- **Dynamic Theming:** Light and Dark themes powered by a custom Material Design token system.
- **Drag & Drop Support:** Drag and drop directories directly into the app.

## 🛠️ Architecture & Tech Stack

### Core
| Category | Technology |
|---|---|
| **Framework** | [Flutter](https://flutter.dev/) (Cross-platform Desktop) |
| **Language** | Dart (`>=3.8.1 <4.0.0`) |
| **Architecture** | Clean Architecture (`data` → `domain` → `presentation`) |

### State Management & DI
| Category | Technology |
|---|---|
| **State Management** | BLoC / Cubit (`flutter_bloc`) |
| **Dependency Injection** | `get_it` (Service Locator pattern) |
| **Routing** | `go_router` (Declarative, URL-based) |

### Data & Storage
| Category | Technology |
|---|---|
| **Local Storage** | `shared_preferences` (JSON-encoded typed models) |
| **Data Classes** | `freezed` & `json_serializable` (Immutable models with code generation) |
| **Functional Programming** | `dartz` (Either type for error handling) |

### UI & Design
| Category | Technology |
|---|---|
| **Design System** | Custom [`material_design_system`](https://github.com/anshra1/material_design_system) package |
| **Notifications** | Custom [`toastification`](https://github.com/anshra1/toastification) package |
| **File Picker** | `file_picker` |
| **Drag & Drop** | `super_drag_and_drop` |

## 🏗️ Project Structure

The project follows a **Feature-First Clean Architecture** approach:

```
lib/
├── core/                       # Shared infrastructure
│   ├── constants/              # App-wide constants
│   ├── di/                     # Dependency Injection (get_it) setup
│   ├── error/                  # Custom exceptions (FileSystem, Storage, Validation)
│   ├── pages/                  # Shared pages
│   ├── routes/                 # GoRouter configuration
│   ├── services/               # Global services
│   ├── theme/                  # ThemeCubit, ThemeState, dynamic theming
│   ├── typedefs/               # Shared type aliases (ResultFuture, etc.)
│   ├── usecase/                # Base UseCase abstractions
│   ├── utils/                  # Utility functions
│   └── widgets/                # Shared widgets
│
├── features/
│   └── code_combiner/          # Main feature module
│       ├── data/
│       │   ├── datasources/    # FileSystemDataSource, LocalStorageDataSource
│       │   ├── enum/           # NodeType, SelectionState
│       │   ├── models/         # FileNode, AppSettings, FilterSettings, etc.
│       │   └── repositories/   # Repository implementations
│       ├── domain/
│       │   ├── repositories/   # Abstract repository contracts
│       │   └── usecases/       # CodeCombinerUseCase
│       └── presentation/
│           ├── cubits/         # WorkspaceCubit, FileExplorerCubit
│           ├── pages/          # Workspace, File Explorer, Settings pages
│           └── widgets/        # Feature-specific widgets
│
├── main.dart                   # App entry point with error boundary
└── root_app.dart               # Root widget with MultiBlocProvider
```

## 📦 Getting Started

### Prerequisites
- Flutter SDK (`>=3.8.1 <4.0.0`)
- Dart SDK

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/anshra1/context_for_ai.git
   cd context_for_ai
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the code generator** (for Freezed and JSON Serializable):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app:**
   ```bash
   flutter run -d linux    # or macos / windows / chrome
   ```

## 🔧 How It Works

1. **Open a Workspace** — Select a project directory via file picker or drag-and-drop.
2. **Browse & Select Files** — Navigate the file tree and check the files/folders you want to include.
3. **Combine & Export** — The app reads all selected files, optionally strips comments, adds file path headers, generates a summary, estimates token count, and exports the merged content to your chosen location.
4. **Feed to AI** — Use the generated file as context for your LLM conversations.

## 🧪 Running Tests

```bash
flutter test
```

## 🤝 Contributing

Contributions are welcome! Feel free to submit a Pull Request.

## 📄 License

This project is open-source. Please check the LICENSE file for details.
