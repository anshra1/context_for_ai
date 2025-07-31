import 'package:context_for_ai/core/di/di.dart';
import 'package:context_for_ai/core/routes/routes.dart';
import 'package:context_for_ai/core/theme/cubit/theme_cubit.dart';
import 'package:context_for_ai/core/theme/cubit/theme_state.dart';
import 'package:context_for_ai/core/theme/flutter_theme_data/flutter_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:theme_ui_widgets/theme_ui_widgets.dart'; // Import for BlocProvider and BlocBuilder
// Replace with the actual path to your ThemeState

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeCubit>(
      create: (context) {
        final cubit = sl<ThemeCubit>()..init();
  

        return cubit;
      },

      child: const AppContainer(),
    );
  }
}

class AppContainer extends StatelessWidget {
  const AppContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      buildWhen: (previous, current) => previous.themeMode != current.themeMode,
      builder: (context, state) {
        // Determine if dark mode based on theme mode and platform brightness
        final effectiveBrightness = switch (state.themeMode) {
          ThemeMode.dark => Brightness.dark,
          ThemeMode.light => Brightness.light,
          ThemeMode.system => state.platformBrightness,
        };
        final isDark = effectiveBrightness == Brightness.dark;

        return AnimatedAppTheme(
          data: isDark ? AppDefaultTheme().dark() : AppDefaultTheme().light(),
          child: MaterialApp.router(
            themeMode: state.themeMode,

            debugShowCheckedModeBanner: false,
            title: 'Context for AI',
            theme: AppFlutterThemeData.toFlutterTheme(
              tokens: isDark ? AppDefaultTheme().dark() : AppDefaultTheme().light(),
              brightness: isDark ? Brightness.dark : Brightness.light,
              fontFamily: state.fontFamily,
            ),
            routerConfig: AppRouter.router,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  platformBrightness: isDark ? Brightness.dark : Brightness.light,
                  textScaler: TextScaler.noScaling,
                ),
                child: ErrorBoundary(child: child ?? const SizedBox.shrink()),
              );
            },
          ),
        );
      },
    );
  }
}

class ErrorBoundary extends StatelessWidget {
  const ErrorBoundary({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SizedBox.expand(child: child),
    );
  }
}
