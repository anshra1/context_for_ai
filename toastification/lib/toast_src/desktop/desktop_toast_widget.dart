import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

/// A Flutter widget that displays a notification card with a modern UI,
/// inspired by the provided HTML/CSS design.
class DesktopToastWidget extends StatefulWidget {
  const DesktopToastWidget({
    super.key,
    required this.title,
    required this.description,
    required this.type,
    this.time,
    this.onClose,
    this.item,
    this.pauseOnHover = true,
    this.showProgressBar = false,
    this.showCloseButtonOnHover = false,
  });

  final String title;
  final String description;
  final String? time;
  final ToastificationType type;
  final VoidCallback? onClose;
  final ToastificationItem? item;
  final bool pauseOnHover;
  final bool showProgressBar;
  final bool showCloseButtonOnHover;

  @override
  State<DesktopToastWidget> createState() => _DesktopToastWidgetState();
}

class _DesktopToastWidgetState extends State<DesktopToastWidget> {
  final _closeButtonVisible = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    // If the close button shouldn't be hidden on hover, make it always visible.
    if (!widget.showCloseButtonOnHover) {
      _closeButtonVisible.value = true;
    }
  }

  @override
  void dispose() {
    _closeButtonVisible.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveStyle = _getStyle(context);

    return MouseRegion(
      onEnter: (event) {
        if (widget.pauseOnHover) {
          widget.item?.pause();
        }
        if (widget.showCloseButtonOnHover) {
          _closeButtonVisible.value = true;
        }
      },
      onExit: (event) {
        if (widget.pauseOnHover) {
          widget.item?.start();
        }
        if (widget.showCloseButtonOnHover) {
          _closeButtonVisible.value = false;
        }
      },
      child: Container(
     
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          // This creates the colored left border.
          border: Border(
            left: BorderSide(
              color: effectiveStyle.borderColor,
              width: 4,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Icon(
                    effectiveStyle.icon,
                    color: effectiveStyle.borderColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  // Content (Title, Description, Time)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.description,
                          style: theme.textTheme.bodyMedium,
                        ),
                        if (widget.time != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            widget.time!,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Close Button
                  ValueListenableBuilder<bool>(
                    valueListenable: _closeButtonVisible,
                    builder: (context, value, child) {
                      return value
                          ? InkWell(
                              onTap: widget.onClose,
                              borderRadius: BorderRadius.circular(20),
                              child: Icon(
                                Icons.close,
                                size: 20,
                                color: theme.iconTheme.color?.withOpacity(0.6),
                              ),
                            )
                          : const SizedBox(width: 20, height: 20);
                    },
                  ),
                ],
              ),
            ),
            if (widget.showProgressBar && widget.item != null)
              ToastTimerAnimationBuilder(
                item: widget.item!,
                builder: (context, value, child) {
                  return LinearProgressIndicator(
                    value: value,
                    backgroundColor: theme.colorScheme.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        effectiveStyle.borderColor),
                    minHeight: 3,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Determines the icon and color based on the notification style.
  _NotificationStyle _getStyle(BuildContext context) {
    return _NotificationStyle(
      icon: widget.type.icon,
      borderColor: widget.type.color,
    );
  }
}


/// A helper class to hold style properties for the notification card.
class _NotificationStyle {
  _NotificationStyle({
    required this.icon,
    required this.borderColor,
  });

  final IconData icon;
  final Color borderColor;
}
