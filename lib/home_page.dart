import 'package:context_for_ai/core/theme/cubit/theme_cubit.dart';
import 'package:context_for_ai/core/theme/cubit/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:theme_ui_widgets/theme_ui_widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      buildWhen: (previous, current) => previous.themeMode != current.themeMode,
      builder: (context, state) {
        return ThemeModeSelectionWidget(
          onThemeModeChanged: (ThemeMode mode) {
            context.read<ThemeCubit>().setThemeMode(mode);
          },
          selectedThemeMode: state.themeMode,
        );
      },
    );
  }
}

/// Appearance Section - Single Responsibility: Theme mode selection
class ThemeModeSelectionWidget extends StatelessWidget {
  const ThemeModeSelectionWidget({
    required this.onThemeModeChanged,
    required this.selectedThemeMode,
    super.key,
  });

  final void Function(ThemeMode) onThemeModeChanged;
  final ThemeMode selectedThemeMode;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Appearance'),
        SizedBox(height: theme.spacing.l),
        Row(
          children: ThemeMode.values.map((mode) {
            final isSelected = mode == selectedThemeMode;
            return Padding(
              padding: EdgeInsets.only(right: theme.spacing.l),
              child: ThemeModeCard(
                mode: mode,
                isSelected: isSelected,
                onTap: () => onThemeModeChanged(mode),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Theme Mode Card - Single Responsibility: Individual theme mode preview
class ThemeModeCard extends StatelessWidget {
  const ThemeModeCard({
    required this.mode,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final ThemeMode mode;
  final bool isSelected;
  final VoidCallback onTap;

  static const double cardWidth = 128;
  static const double cardHeight = 100;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: cardWidth,
            height: cardHeight,
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? theme.borderColorScheme.themeThick
                    : theme.borderColorScheme.primary,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(theme.borderRadius.m),
              color: _getPreviewColor(mode, theme),
            ),
            child: isSelected
                ? Stack(
                    children: [
                      Positioned(
                        top: theme.spacing.xs,
                        left: theme.spacing.xs,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: theme.fillColorScheme.themeThick,
                            borderRadius: BorderRadius.circular(theme.borderRadius.s),
                          ),
                          child: Icon(
                            Icons.check,
                            size: 10,
                            color: theme.textColorScheme.onFill,
                          ),
                        ),
                      ),
                    ],
                  )
                : null,
          ),
          SizedBox(height: theme.spacing.xs),
          Text(
            _getModeLabel(mode),
            style: theme.textStyle.bodySmall.standard(
              context: context,
              color: isSelected
                  ? theme.textColorScheme.primary
                  : theme.textColorScheme.secondary,
              weight: isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPreviewColor(ThemeMode mode, AppThemeData theme) {
    switch (mode) {
      case ThemeMode.light:
        return theme.surfaceColorScheme.primary;
      case ThemeMode.dark:
        return theme.surfaceColorScheme.inverse;
      case ThemeMode.system:
        return theme.surfaceColorScheme.layer01;
    }
  }

  String _getModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'Auto';
    }
  }
}
