import 'package:context_for_ai/features/code_combiner/data/models/settings_model.dart';
import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  const SettingsState({
    required this.settings,
  });

  factory SettingsState.initial() {
    return SettingsState(settings: SettingsModel.defaults());
  }

  final SettingsModel settings;

  SettingsState copyWith({
    SettingsModel? settings,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
    );
  }

  @override
  List<Object> get props => [settings];
}
