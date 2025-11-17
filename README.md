Text Merger - Flutter Code Combiner Utility

Text Merger is a cross-platform desktop and web utility built with Flutter. It's designed to help developers and researchers easily combine the content of multiple files from a project directory into a single, merged text file.

This tool is particularly useful for creating large context files for AI models (like Claude, GPT-4, etc.) by letting you select precisely which files to include or exclude from your project.

Features

Open Project Workspace: Open any directory from your file system to view it as a workspace.

File Tree Explorer: Navigate your project's complete file and folder structure in an expandable tree view.

Selective Combining: Check or uncheck individual files or entire folders to include them in the final merged file.

Smart Filtering: Automatically ignores common unnecessary files and folders (e.g., .git, build, .DS_Store). (Feature inferred from filter models).

Recent Workspaces: Quickly access your recently opened project folders from the workspace home page.

Settings Management: Customize app behavior, such as theme (Dark/Light mode).

Cross-Platform: Built to run on Web, Windows, macOS, and Linux from a single codebase.

Tech Stack & Architecture

This project is built with a modern Flutter stack, emphasizing scalability and maintainability.

Core Technology

Framework: Flutter

Language: Dart

State Management

flutter_bloc / Cubit: For predictable and decoupled state management.

Navigation

go_router: For a declarative, URL-based routing solution.

Local Storage

Hive: Used for fast, on-device storage of app settings and recent workspace paths.

Dependency Injection

get_it & injectable: For service location and managing dependencies.

File System & UI

file_picker: For opening the native directory picker.

desktop_drop: For drag-and-drop support to open workspaces.

flutter_syntax_view: For rendering the combined code with syntax highlighting.

share_plus: For sharing the generated text file.

Models & Code Generation

freezed: For robust data models and state classes.

build_runner: For running code generation.

Project Architecture

The app follows a Feature-First structure inspired by Clean Architecture.

lib/
├── core/
│   ├── di/                 # Dependency injection setup
│   ├── error/              # Failure and exception handling
│   ├── routes/             # App navigation (GoRouter)
│   ├── services/           # Global services (e.g., loading)
│   ├── theme/              # Theme cubit and theme data
│   └── ...
│
├── features/
│   └── code_combiner/      # Main feature
│       ├── data/
│       │   ├── datasources/  # File system & local storage logic
│       │   ├── models/       # Data models (Freezed)
│       │   └── repositories/ # Implementation of domain repositories
│       │
│       ├── domain/
│       │   ├── repositories/ # Abstract repository contracts
│       │   └── usecases/     # Core business logic (e.g., combine_files)
│       │
│       └── presentation/
│           ├── cubits/       # State management for pages
│           ├── pages/        # Workspace, File Explorer, Settings pages
│           └── widgets/      # Reusable widgets for this feature
│
├── main.dart               # App entry point
└── root_app.dart           # Root MaterialApp.router setup


Getting Started

To run this project locally, follow these steps:

Clone the repository:

git clone [https://github.com/your-username/text_merger.git](https://github.com/your-username/text_merger.git)
cd text_merger


Install dependencies:

flutter pub get


Run Code Generation:
This project uses build_runner for dependency injection and data models. Run the following command to generate the necessary files:

flutter pub run build_runner build --delete-conflicting-outputs


Run the app:
Select your target device (e.g., desktop, chrome) and run:

flutter run


How to Use

Launch the application.

On the Workspace page, either click "Open Directory" or drag and drop a project folder onto the window.

You will be navigated to the File Explorer page.

Browse your project tree. Check the files or folders you want to include in the final combined text.

Use the filter inputs (if implemented) to include/exclude files by extension (e.g., .dart, .md).

Click the "Combine" or "Generate" button.

The app will process the files and show you a preview of the merged text, which you can then copy or save.
