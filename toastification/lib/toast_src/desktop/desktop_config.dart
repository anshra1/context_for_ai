import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class DesktopConfig {
  const DesktopConfig({
    // Theme
    this.infoColor,
    this.successColor,
    this.warningColor,
    this.errorColor,

    // Style
    this.titleTextStyle,
    this.descriptionTextStyle,
    this.backgroundColor,
    this.borderRadius,
    this.borderColor,
    this.borderWidth,
    this.boxShadow,

    // Behavior
    this.autoCloseDuration,
    this.pauseOnHover,
    this.showProgressBar,
    this.showCloseButtonOnHover,

    // Animation
    this.animationDuration,
    this.animationBuilder,
  });

  // Theme
  final Color? infoColor;
  final Color? successColor;
  final Color? warningColor;
  final Color? errorColor;

  // Style
  final TextStyle? titleTextStyle;
  final TextStyle? descriptionTextStyle;
  final Color? backgroundColor;
  final BorderRadiusGeometry? borderRadius;
  final Color? borderColor;
  final double? borderWidth;
  final List<BoxShadow>? boxShadow;

  // Behavior
  final Duration? autoCloseDuration;
  final bool? pauseOnHover;
  final bool? showProgressBar;
  final bool? showCloseButtonOnHover;

  // Animation
  final Duration? animationDuration;
  final ToastificationAnimationBuilder? animationBuilder;
}
