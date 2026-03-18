import 'package:xpensemate/features/settings/domain/entities/settings_entity.dart';

class SettingsModel extends SettingsEntity {
  const SettingsModel({
    super.notificationsEnabled,
    super.transactionReminders,
    super.budgetAlerts,
    super.biometricAuth,
    super.selectedCurrency,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) => SettingsModel(
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      transactionReminders: json['transactionReminders'] as bool? ?? true,
      budgetAlerts: json['budgetAlerts'] as bool? ?? true,
      biometricAuth: json['biometricAuth'] as bool? ?? false,
      selectedCurrency: json['selectedCurrency'] as String? ?? 'USD',
    );

  factory SettingsModel.fromEntity(SettingsEntity entity) => SettingsModel(
      notificationsEnabled: entity.notificationsEnabled,
      transactionReminders: entity.transactionReminders,
      budgetAlerts: entity.budgetAlerts,
      biometricAuth: entity.biometricAuth,
      selectedCurrency: entity.selectedCurrency,
    );

  Map<String, dynamic> toJson() => {
      'notificationsEnabled': notificationsEnabled,
      'transactionReminders': transactionReminders,
      'budgetAlerts': budgetAlerts,
      'biometricAuth': biometricAuth,
      'selectedCurrency': selectedCurrency,
    };
}
