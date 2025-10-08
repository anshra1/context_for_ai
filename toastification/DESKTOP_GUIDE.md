# Desktop Notifications Guide (Detailed)

This guide provides a comprehensive overview of the desktop notification feature in the `toastification` package.

## Introduction

The desktop notification feature allows you to show beautiful and customizable in-app notifications that are specifically designed for desktop applications. These notifications are displayed within your app's window and can be positioned in different corners of the screen.

## Getting Started

To show a basic desktop notification, you can use the `showDesktopNotification` method on the `toastification` instance.

```dart
// Show a basic desktop notification
toastification.showDesktopNotification(
  title: 'New Message',
  description: 'You have a new message from John Doe.',
);
```

This will show a notification in the top-right corner of the screen with the specified title and description. The notification will automatically close after 5 seconds.

## Customization

You can customize every aspect of the desktop notifications, from the colors and fonts to the behavior and animations.

### Pre-built Styles

The easiest way to style your notifications is to use the `DesktopToastStyle` enum. This will apply a pre-built style to the notification.

```dart
// Show a success notification
toastification.showDesktopNotification(
  style: DesktopToastStyle.success,
  title: 'Success',
  description: 'Your changes have been saved.',
);
```

The available styles are:

*   `info`: For informational messages.
*   `success`: For success messages.
*   `warning`: For warning messages.
*   `error`: For error messages.

### Custom Styling

You can override the default styling of the notifications by passing styling properties to the `showDesktopNotification` method.

```dart
toastification.showDesktopNotification(
  title: 'Custom Style',
  description: 'This is a custom-styled notification.',
  backgroundColor: Colors.purple.shade200,
  borderColor: Colors.purple.shade400,
  borderWidth: 2,
  borderRadius: BorderRadius.circular(16),
  titleTextStyle: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
  descriptionTextStyle: const TextStyle(color: Colors.purple),
);
```

### Theming

If you want to apply a consistent style to all your desktop notifications, you can provide a global theme using the `ToastificationConfig` and `DesktopConfig` classes. You can wrap your `MaterialApp` with a `ToastificationConfigProvider` to provide a global configuration.

```dart
ToastificationConfigProvider(
  config: ToastificationConfig(
    desktopConfig: DesktopConfig(
      // Pre-built styles colors
      infoColor: Colors.blue.shade400,
      successColor: Colors.green.shade400,
      warningColor: Colors.orange.shade400,
      errorColor: Colors.red.shade400,

      // Custom styling
      backgroundColor: Colors.grey.shade800,
      titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18),
      descriptionTextStyle: const TextStyle(color: Colors.white, fontSize: 16),
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  child: MaterialApp(
    // ...
  ),
)
```

### Behavior

You can control the behavior of the notifications with the following properties:

*   `autoCloseDuration`: The duration after which the notification will automatically close. Set to `null` to disable auto-close.
*   `pauseOnHover`: Whether to pause the auto-close timer when the user hovers over the notification.
*   `showProgressBar`: Whether to show a progress bar that indicates the remaining time before the notification closes.
*   `showCloseButtonOnHover`: Whether to show the close button only when the user hovers over the notification.

```dart
toastification.showDesktopNotification(
  title: 'Behavior Customization',
  description: 'This notification has custom behavior.',
  autoCloseDuration: const Duration(seconds: 10),
  pauseOnHover: true,
  showProgressBar: true,
  showCloseButtonOnHover: true,
);
```

### Lifecycle Callbacks

You can use the `ToastificationCallbacks` to listen for events in the notification's lifecycle:

```dart
toastification.showDesktopNotification(
  title: 'Lifecycle Callbacks',
  description: 'This notification has lifecycle callbacks.',
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