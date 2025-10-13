# Gemini Code Assistant Context

## Project Overview

This project is a Flutter package named `toastification`. It provides a way to show toast notifications in a Flutter application.

The package is well-structured and follows the standard Flutter package layout. The main logic is located in the `lib` directory, with the core functionality in `lib/toast_src/core`. The package uses a `ToastificationManager` to manage and display notifications, and it supports different alignments and custom animations.

The project uses the following main technologies:
- Flutter
- Dart

## Building and Running

### Dependencies

The project's dependencies are listed in the `pubspec.yaml` file. To install them, run:

```bash
flutter pub get
```

### Running the example

The `example` directory contains a sample application that demonstrates the usage of the `toastification` package. To run the example, navigate to the `example` directory and run:

```bash
flutter run
```

### Running tests

The project has a suite of tests in the `test` directory. To run the tests, use the following command:

```bash
flutter test
```

## Development Conventions

### Code Style

The project follows the official Flutter style guide. The `analysis_options.yaml` file includes `package:flutter_lints/flutter.yaml`, which enforces a set of recommended lints.

### Testing

The project has a comprehensive test suite that covers the core functionality of the package. Tests are located in the `test` directory and are written using the `flutter_test` and `mockito` packages.

### Contribution Guidelines

The `CONTRIBUTING.md` file provides guidelines for contributing to the project. The main steps are:
1. Fork the repository.
2. Create a new branch.
3. Make your changes.
4. Push your changes to your fork.
5. Open a pull request.


* Pre-built Styles: A set of ready-to-use styles for different 
     notification types (e.g., info, success, warning, error).
   * Custom Styling: The ability to customize the colors, fonts, 
     borders, shadows, and icons of the notifications.
   * Theming: A global theming system to ensure a consistent look and 
     feel for all notifications in your app.
   * Positioning: The ability to position notifications in different 
     corners of the screen (e.g., top-right, bottom-left).
   * Stacking: The ability to control how notifications are stacked 
     when multiple notifications are shown at the same time (e.g., 
     from top to bottom, or from bottom to top).
   * Animations: A set of beautiful and customizable animations for 
     showing and hiding the notifications

     Progress Bars: The ability to show a progress bar in the 
     notification, for example, to show the progress of a file 
     download or a long-running task. - But based on time for notification

     Hover Effects: The ability to show or hide elements (like a close 
     button) when the user hovers over the notification.

      Management and Behavior

   * Auto-Close: The ability to automatically close the notification 
     after a specified duration.
   * Pause on Hover: The ability to pause the auto-close timer when 
     the user hovers over the notification.
   * Manual Close: The ability to close the notification manually by 
     clicking a close button or by swiping.
   * Queueing: A queueing system to handle multiple notifications that 
     are triggered at the same time, so they don't overlap.
   * Updating Notifications: The ability to update the content of an 
     existing notification (e.g., to update the progress of a 
     download).
   * Lifecycle Callbacks: Callbacks for different lifecycle events, 
     such as onShown, onClosed, and onAction, to allow for more 
     advanced integrations.

       Developer Experience

   * Simple and Intuitive API: A clean and easy-to-use API for showing 
     and managing notifications.
   * Excellent Documentation: Clear and comprehensive documentation 
     with plenty of examples.
   * Hot Reload Support: Full support for Flutter's hot reload feature 
     to make development faster.
   * Testability: The ability to easily test the notifications in a 
     widget testing environment.