import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpensemate/core/usecase/usecase.dart';
import 'package:xpensemate/core/utils/app_logger.dart';
import 'package:xpensemate/features/settings/domain/usecases/save_settings_usecase.dart';
import 'package:xpensemate/features/settings/domain/usecases/settings_use_cases_holder.dart';
import 'package:xpensemate/features/settings/presentation/cubit/settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._useCasesHolder) : super(const SettingsInitial()) {
    AppLogger.breadcrumb('Initializing SettingsCubit...');
    _loadSettings();
  }

  /// Supported currencies – code and symbol only.
  /// Localized names are resolved in the UI layer via [AppLocalizations].
  static const List<Map<String, String>> currencies = [
    {'code': 'USD', 'symbol': r'$'},
    {'code': 'EUR', 'symbol': '€'},
    {'code': 'GBP', 'symbol': '£'},
    {'code': 'JPY', 'symbol': '¥'},
    {'code': 'AUD', 'symbol': r'A$'},
    {'code': 'CAD', 'symbol': r'C$'},
    {'code': 'CHF', 'symbol': 'Fr'},
    {'code': 'CNY', 'symbol': '¥'},
    {'code': 'PKR', 'symbol': '₨'},
    {'code': 'INR', 'symbol': '₹'},
  ];

  final SettingsUseCasesHolder _useCasesHolder;

  Future<void> _loadSettings() async {
    emit(const SettingsLoading());
    final result = await _useCasesHolder.getSettingsUseCase(const NoParams());
    result.fold(
      (failure) {
        logE('Failed to load settings: ${failure.message}');
        emit(SettingsError(failure.message));
      },
      (settings) {
        emit(SettingsLoaded(settings: settings));
      },
    );
  }

  Future<void> updateSettings({
    bool? notificationsEnabled,
    bool? transactionReminders,
    bool? budgetAlerts,
    bool? biometricAuth,
    String? selectedCurrency,
  }) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    final newSettings = currentState.settings.copyWith(
      notificationsEnabled: notificationsEnabled,
      transactionReminders: transactionReminders,
      budgetAlerts: budgetAlerts,
      biometricAuth: biometricAuth,
      selectedCurrency: selectedCurrency,
    );

    emit(currentState.copyWith(isSaving: true));

    final result = await _useCasesHolder.saveSettingsUseCase(
      SaveSettingsParams(newSettings),
    );

    result.fold(
      (failure) {
        logE('Settings update failed: ${failure.message}');
        emit(currentState.copyWith(isSaving: false, message: failure.message));
      },
      (_) {
        // Success
        emit(
          SettingsLoaded(
            settings: newSettings,
            message: 'Settings updated successfully',
          ),
        );
      },
    );
  }
}

extension SettingsCubitExtension on BuildContext {
  SettingsCubit get settingsCubit => read<SettingsCubit>();
}
