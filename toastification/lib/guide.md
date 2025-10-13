# Toastification Package - Complete AI Guide

## 📚 Package Overview

**Toastification** is a comprehensive Flutter toast notification system with extensive customization, multiple styles, and enterprise-ready architecture.

## 🚀 Quick Start Guide

### 1. Basic Setup

```dart
// Wrap your app with ToastificationWrapper
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MaterialApp(
        title: 'My App',
        home: HomePage(),
      ),
    );
  }
}
```

### 2. Showing Basic Toasts

```dart
// Success toast
toastification.show(
  context: context,
  title: Text('Success!'),
  description: Text('Your action was completed successfully.'),
  type: ToastificationType.success,
  style: ToastificationStyle.flat,
);

// Error toast
toastification.show(
  context: context,
  title: Text('Error'),
  description: Text('Something went wrong.'),
  type: ToastificationType.error,
  style: ToastificationStyle.fillColored,
);

// Info toast with auto-close
toastification.show(
  context: context,
  title: Text('Information'),
  description: Text('This will close automatically.'),
  type: ToastificationType.info,
  autoCloseDuration: Duration(seconds: 5),
);
```

## 🎨 Toast Styles & Types

### Available Styles
```dart
ToastificationStyle.flat          // Modern flat design
ToastificationStyle.fillColored   // Full colored background
ToastificationStyle.flatColored   // Colored flat design  
ToastificationStyle.minimal       // Minimal borders
ToastificationStyle.simple        // Text-only
```

### Available Types
```dart
ToastificationType.success    // Green - success actions
ToastificationType.error      // Red - error messages
ToastificationType.warning    // Orange - warnings
ToastificationType.info       // Blue - information
```

## ⚙️ Advanced Configuration

### Global Configuration
```dart
ToastificationWrapper(
  config: ToastificationConfig(
    alignment: Alignment.topCenter,
    itemWidth: 400,
    animationDuration: Duration(milliseconds: 400),
    margin: EdgeInsets.all(16),
    maxToastLimit: 5,
    blockBackgroundInteraction: false,
  ),
  child: MaterialApp(...),
)
```

### Per-Toast Configuration
```dart
toastification.show(
  context: context,
  title: Text('Custom Config'),
  type: ToastificationType.info,
  config: ToastificationConfig(
    itemWidth: 500,
    margin: EdgeInsets.symmetric(vertical: 20),
    alignment: Alignment.bottomCenter,
  ),
);
```

## 🔧 Custom Toasts

### Custom Widget Toasts
```dart
toastification.showCustom(
  context: context,
  alignment: Alignment.topRight,
  autoCloseDuration: Duration(seconds: 4),
  builder: (context, item) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.star, color: Colors.white),
          SizedBox(width: 12),
          Text('Custom Toast!', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  },
);
```

### Custom Animations
```dart
toastification.showCustom(
  context: context,
  animationBuilder: (context, animation, alignment, child) {
    return ScaleTransition(
      scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  },
  builder: (context, item) => MyCustomWidget(),
);
```

## 🎯 Event Handling

### Toast Callbacks
```dart
toastification.show(
  context: context,
  title: Text('Interactive Toast'),
  type: ToastificationType.success,
  callbacks: ToastificationCallbacks(
    onTap: (item) {
      print('Toast tapped!');
      // Handle tap
    },
    onCloseButtonTap: (item) {
      print('Close button tapped!');
      toastification.dismiss(item);
    },
    onAutoCompleteCompleted: (item) {
      print('Toast auto-closed!');
    },
    onDismissed: (item) {
      print('Toast dismissed by swipe!');
    },
  ),
);
```

## 🛠️ Toast Management

### Managing Individual Toasts
```dart
// Show toast and store reference
ToastificationItem toastItem = toastification.show(
  context: context,
  title: Text('Manageable Toast'),
  type: ToastificationType.info,
);

// Dismiss specific toast
toastification.dismiss(toastItem);

// Dismiss by ID
toastification.dismissById(toastItem.id);

// Find toast by ID
ToastificationItem? found = toastification.findToastificationItem(toastItem.id);
```

### Bulk Operations
```dart
// Dismiss all toasts
toastification.dismissAll();

// Dismiss all with animation delay
toastification.dismissAll(delayForAnimation: true);
```

## 🎨 Theming & Styling

### Custom Color Scheme
```dart
toastification.show(
  context: context,
  title: Text('Custom Colors'),
  description: Text('Fully customized appearance.'),
  primaryColor: Colors.purple,
  backgroundColor: Colors.purple.shade50,
  foregroundColor: Colors.purple.shade900,
  borderRadius: BorderRadius.circular(20),
  borderSide: BorderSide(color: Colors.purple, width: 2),
  boxShadow: [
    BoxShadow(
      color: Colors.purple.withOpacity(0.3),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ],
);
```

### Progress Indicators
```dart
toastification.show(
  context: context,
  title: Text('With Progress Bar'),
  type: ToastificationType.info,
  showProgressBar: true,
  progressBarTheme: ProgressIndicatorThemeData(
    color: Colors.blue,
    linearMinHeight: 4,
  ),
  autoCloseDuration: Duration(seconds: 5),
);
```

## 📱 Responsive Behavior

### Mobile-Specific Configuration
```dart
toastification.show(
  context: context,
  title: Text('Mobile Optimized'),
  description: Text('Optimized for mobile devices.'),
  config: ToastificationConfig(
    itemWidth: MediaQuery.of(context).size.width * 0.9,
    margin: EdgeInsets.fromLTRB(16, MediaQuery.of(context).viewPadding.top + 16, 16, 16),
  ),
  dismissDirection: DismissDirection.horizontal,
  dragToClose: true,
);
```

## 🔄 State Management Integration

### With Provider/Riverpod
```dart
// In your state management
class ToastService {
  void showSuccess(String message) {
    toastification.show(
      context: context,
      title: Text('Success'),
      description: Text(message),
      type: ToastificationType.success,
    );
  }
  
  void showError(String message) {
    toastification.show(
      context: context,
      title: Text('Error'),
      description: Text(message),
      type: ToastificationType.error,
      autoCloseDuration: Duration(seconds: 5),
    );
  }
}
```

## 🎪 Advanced Features

### Blur Effects
```dart
toastification.show(
  context: context,
  title: Text('Frosted Glass Effect'),
  type: ToastificationType.info,
  applyBlurEffect: true,
  backgroundColor: Colors.white.withOpacity(0.8),
);
```

### Close Button Customization
```dart
toastification.show(
  context: context,
  title: Text('Close Button Options'),
  type: ToastificationType.warning,
  closeButton: ToastCloseButton(
    showType: CloseButtonShowType.onHover, // always, onHover, none
    buttonBuilder: (context, onClose) {
      return IconButton(
        icon: Icon(Icons.cancel),
        onPressed: onClose,
        color: Colors.orange,
      );
    },
  ),
);
```

### Hover Interactions
```dart
toastification.show(
  context: context,
  title: Text('Hover Effects'),
  type: ToastificationType.info,
  pauseOnHover: true, // Pause auto-close on hover
  closeOnClick: true, // Close when clicked
);
```

## 🐛 Debugging & Testing

### Testing Setup
```dart
testWidgets('Toastification test', (WidgetTester tester) async {
  await tester.pumpWidget(ToastificationWrapper(
    child: MaterialApp(home: TestPage()),
  ));
  
  // Trigger toast
  await tester.tap(find.text('Show Toast'));
  await tester.pumpAndSettle();
  
  // Verify toast appears
  expect(find.text('Test Toast'), findsOneWidget);
});
```

### Common Issues & Solutions

**Issue**: Toast not showing
```dart
// ❌ Missing ToastificationWrapper
MaterialApp(home: MyPage())

// ✅ Correct setup  
ToastificationWrapper(child: MaterialApp(home: MyPage()))
```

**Issue**: Context errors
```dart
// ❌ Using wrong context
toastification.show(context: navigatorContext, ...)

// ✅ Use BuildContext from widget tree
toastification.show(context: context, ...)

// ✅ Or use without context (requires ToastificationWrapper)
toastification.show(title: Text('No context needed'), ...)
```

## 📋 Best Practices

### 1. Consistent Styling
```dart
class AppToasts {
  static void showSuccess(BuildContext context, String message) {
    toastification.show(
      context: context,
      title: Text('Success'),
      description: Text(message),
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      autoCloseDuration: Duration(seconds: 3),
    );
  }
  
  static void showError(BuildContext context, String message) {
    toastification.show(
      context: context,
      title: Text('Error'),
      description: Text(message),
      type: ToastificationType.error,
      style: ToastificationStyle.fillColored,
      autoCloseDuration: Duration(seconds: 5),
    );
  }
}
```

### 2. Accessibility
```dart
toastification.show(
  context: context,
  title: Text('Accessible Toast'),
  description: Text('Consider screen readers and contrast ratios.'),
  primaryColor: Colors.blue,
  // Ensure sufficient color contrast
  backgroundColor: Colors.blue.shade50,
  foregroundColor: Colors.blue.shade900,
);
```

### 3. Performance
```dart
// Limit toast quantity
ToastificationConfig(
  maxToastLimit: 3, // Prevent memory issues
)

// Use appropriate animation durations
animationDuration: Duration(milliseconds: 300), // Smooth but performant
```

## 🎯 AI Response Templates

### When user asks to show a toast:
```dart
// Success notification
toastification.show(
  context: context,
  title: Text('Operation Successful'),
  description: Text('Your changes have been saved successfully.'),
  type: ToastificationType.success,
  style: ToastificationStyle.flat,
  autoCloseDuration: Duration(seconds: 3),
);

// Error notification  
toastification.show(
  context: context,
  title: Text('Error Occurred'),
  description: Text('Please check your input and try again.'),
  type: ToastificationType.error,
  style: ToastificationStyle.fillColored,
  autoCloseDuration: Duration(seconds: 5),
);
```

### When user needs custom styling:
```dart
toastification.show(
  context: context,
  title: Text('Custom Style'),
  description: Text('Fully customized toast appearance.'),
  primaryColor: Colors.deepPurple,
  backgroundColor: Colors.deepPurple.shade50,
  foregroundColor: Colors.deepPurple.shade900,
  borderRadius: BorderRadius.circular(16),
  padding: EdgeInsets.all(20),
  boxShadow: [
    BoxShadow(
      color: Colors.deepPurple.withOpacity(0.2),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ],
);
```

# Desktop Notifications Guide (Detailed)

This guide provides a comprehensive overview of the desktop notification feature in the `toastification` package.

## Introduction

The desktop notification feature allows you to show beautiful, modern, and consistent in-app notifications that are specifically designed for desktop applications. These notifications are displayed within your app's window and can be positioned in different corners of the screen.

**Note**: The new desktop notifications feature a standardized, modern design and are not customizable with colors, borders, or text styles.

## Getting Started

To show a basic desktop notification, you can use the `showDesktopNotification` method on the `toastification` instance.

```dart
// Show a basic desktop notification
toastification.showDesktopNotification(
  title: 'New Message',
  description: 'You have a new message from John Doe.',
  type: ToastificationType.info,
);
```

This will show a notification in the top-right corner of the screen with the specified title and description. The notification will automatically close after 5 seconds.

## Customization

### Notification Types

The style of the notification is determined by the `ToastificationType` enum. This will apply a pre-built style with specific colors and icons.

```dart
// Show a success notification
toastification.showDesktopNotification(
  title: 'Success',
  description: 'Your changes have been saved.',
  type: ToastificationType.success,
);

// Show an error notification
toastification.showDesktopNotification(
  title: 'Error',
  description: 'Something went wrong.',
  type: ToastificationType.error,
);
```

The available types are:

*   `info`: For informational messages (blue).
*   `success`: For success messages (green).
*   `warning`: For warning messages (orange).
*   `error`: For error messages (red).

### Sizing and Layout

The sizing of desktop notifications is controlled in two places:

*   **Width**: The *maximum width* of the notification is determined by the `itemWidth` property within the `ToastificationConfig`. This can be set globally or passed directly to the `showDesktopNotification` method. This defines the "box" that the notification lives in.

*   **Height**: The height of the notification is **dynamic**. It is determined automatically by the content (the amount of text in the title and description) within the `DesktopToastWidget`.

### Behavior

You can control the behavior of the notifications with the following properties:

*   `autoCloseDuration`: The duration after which the notification will automatically close. Set to `null` to disable auto-close.
*   `pauseOnHover`: Whether to pause the auto-close timer when the user hovers over the notification. Defaults to `true`.
*   `showProgressBar`: Whether to show a progress bar that indicates the remaining time before the notification closes. Defaults to `true`.
*   `showCloseButtonOnHover`: Whether to show the close button only when the user hovers over the notification. Defaults to `true`.

```dart
toastification.showDesktopNotification(
  title: 'Behavior Customization',
  description: 'This notification has custom behavior.',
  type: ToastificationType.info,
  autoCloseDuration: const Duration(seconds: 10),
  pauseOnHover: false,
  showProgressBar: false,
);
```

### Lifecycle Callbacks

You can use the `ToastificationCallbacks` to listen for events in the notification's lifecycle:

```dart
toastification.showDesktopNotification(
  title: 'Lifecycle Callbacks',
  description: 'This notification has lifecycle callbacks.',
  type: ToastificationType.warning,
  callbacks: ToastificationCallbacks(
    onShown: (item) {
      print('Notification ${item.id} is now visible.');
    },
    onDismissed: (item) {
      print('Notification ${item.id} has been dismissed.');
    },
    onCloseButtonTap: (item) {
      print('User clicked the close button on notification ${item.id}.');
    },
  ),
);
```

## Future Development

This feature is still under development. In the future, we plan to add more advanced features like:

*   Action buttons
*   Notification updates
*   Custom animations