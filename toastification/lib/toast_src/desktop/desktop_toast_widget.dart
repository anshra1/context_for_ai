import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class DesktopToastWidget extends StatefulWidget {
  const DesktopToastWidget({
    super.key,
    required this.title,
    required this.description,
    this.style,
    this.icon,
    this.backgroundColor,
    this.borderRadius,
    this.borderColor,
    this.borderWidth,
    this.boxShadow,
    this.titleTextStyle,
    this.descriptionTextStyle,
    this.onClose,
    this.showProgressBar,
    this.item,
    this.pauseOnHover,
    this.showCloseButtonOnHover,
  });

  final String title;
  final String description;
  final DesktopToastStyle? style;
  final Widget? icon;
  final Color? backgroundColor;
  final BorderRadiusGeometry? borderRadius;
  final Color? borderColor;
  final double? borderWidth;
  final List<BoxShadow>? boxShadow;
  final TextStyle? titleTextStyle;
  final TextStyle? descriptionTextStyle;
  final VoidCallback? onClose;
  final bool? showProgressBar;
  final ToastificationItem? item;
  final bool? pauseOnHover;
  final bool? showCloseButtonOnHover;

  @override
  State<DesktopToastWidget> createState() => _DesktopToastWidgetState();
}

class _DesktopToastWidgetState extends State<DesktopToastWidget> {
  final _closeButtonVisible = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    if (widget.showCloseButtonOnHover == false) {
      _closeButtonVisible.value = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = _getStyle(context);

    final showProgressBar = widget.showProgressBar ?? false;
    final pauseOnHover = widget.pauseOnHover ?? false;
    final showCloseButtonOnHover = widget.showCloseButtonOnHover ?? false;

    return MouseRegion(
      onEnter: (event) {
        if (pauseOnHover) {
          widget.item?.pause();
        }
        if (showCloseButtonOnHover) {
          _closeButtonVisible.value = true;
        }
      },
      onExit: (event) {
        if (pauseOnHover) {
          widget.item?.start();
        }
        if (showCloseButtonOnHover) {
          _closeButtonVisible.value = false;
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 350,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? effectiveStyle.backgroundColor,
              borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
              border: Border.all(
                color: widget.borderColor ?? effectiveStyle.borderColor!,
                width: widget.borderWidth ?? 1,
              ),
              boxShadow: widget.boxShadow ??
                  [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
            ),
            child: Row(
              children: [
                if (widget.icon != null || effectiveStyle.icon != null) ...[
                  widget.icon ?? effectiveStyle.icon!,
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: widget.titleTextStyle ??
                            const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.description,
                        style: widget.descriptionTextStyle ??
                            const TextStyle(
                              fontSize: 14,
                            ),
                      ),
                    ],
                  ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: _closeButtonVisible,
                  builder: (context, value, child) {
                    return value
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: widget.onClose,
                          )
                        : const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          if (showProgressBar)
            ToastTimerAnimationBuilder(
              item: widget.item!,
              builder: (context, value, child) {
                return LinearProgressIndicator(value: value);
              },
            ),
        ],
      ),
    );
  }

  _DesktopToastStyle _getStyle(BuildContext context) {
    final desktopConfig = ToastificationConfigProvider.maybeOf(context)?.config.desktopConfig;

    switch (widget.style) {
      case DesktopToastStyle.info:
        return _DesktopToastStyle(
          icon: const Icon(Icons.info, color: Colors.blue),
          backgroundColor: desktopConfig?.infoColor ?? Colors.blue.shade100,
          borderColor: (desktopConfig?.infoColor ?? Colors.blue).withAlpha(128),
        );
      case DesktopToastStyle.success:
        return _DesktopToastStyle(
          icon: const Icon(Icons.check_circle, color: Colors.green),
          backgroundColor: desktopConfig?.successColor ?? Colors.green.shade100,
          borderColor:
              (desktopConfig?.successColor ?? Colors.green).withAlpha(128),
        );
      case DesktopToastStyle.warning:
        return _DesktopToastStyle(
          icon: const Icon(Icons.warning, color: Colors.orange),
          backgroundColor: desktopConfig?.warningColor ?? Colors.orange.shade100,
          borderColor:
              (desktopConfig?.warningColor ?? Colors.orange).withAlpha(128),
        );
      case DesktopToastStyle.error:
        return _DesktopToastStyle(
          icon: const Icon(Icons.error, color: Colors.red),
          backgroundColor: desktopConfig?.errorColor ?? Colors.red.shade100,
          borderColor: (desktopConfig?.errorColor ?? Colors.red).withAlpha(128),
        );
      default:
        return _DesktopToastStyle(
          icon: widget.icon,
          backgroundColor: widget.backgroundColor ?? Colors.white,
          borderColor: widget.borderColor ?? Colors.transparent,
        );
    }
  }
}

class _DesktopToastStyle {
  _DesktopToastStyle({
    this.icon,
    this.backgroundColor,
    this.borderColor,
  });

  final Widget? icon;
  final Color? backgroundColor;
  final Color? borderColor;
}
