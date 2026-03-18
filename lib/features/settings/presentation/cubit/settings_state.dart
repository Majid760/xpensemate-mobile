import 'package:equatable/equatable.dart';
import 'package:xpensemate/features/settings/domain/entities/settings_entity.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

class SettingsLoaded extends SettingsState {
  const SettingsLoaded({
    required this.settings,
    this.message,
    this.isSaving = false,
  });

  final SettingsEntity settings;
  final String? message;
  final bool isSaving;

  SettingsLoaded copyWith({
    SettingsEntity? settings,
    String? message,
    bool? isSaving,
  }) => SettingsLoaded(
      settings: settings ?? this.settings,
      message: message, // Allow clearing message by passing null or handling it via a clear flag if needed
      isSaving: isSaving ?? false,
    );

  @override
  List<Object?> get props => [settings, message, isSaving];
}

class SettingsError extends SettingsState {
  const SettingsError(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}
