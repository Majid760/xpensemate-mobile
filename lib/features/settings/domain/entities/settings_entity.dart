import 'package:equatable/equatable.dart';

class SettingsEntity extends Equatable {
  const SettingsEntity({
    this.notificationsEnabled = true,
    this.transactionReminders = true,
    this.budgetAlerts = true,
    this.biometricAuth = false,
    this.selectedCurrency = 'USD',
  });

  final bool notificationsEnabled;
  final bool transactionReminders;
  final bool budgetAlerts;
  final bool biometricAuth;
  final String selectedCurrency;

  SettingsEntity copyWith({
    bool? notificationsEnabled,
    bool? transactionReminders,
    bool? budgetAlerts,
    bool? biometricAuth,
    String? selectedCurrency,
  }) => SettingsEntity(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      transactionReminders: transactionReminders ?? this.transactionReminders,
      budgetAlerts: budgetAlerts ?? this.budgetAlerts,
      biometricAuth: biometricAuth ?? this.biometricAuth,
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
    );

  @override
  List<Object?> get props => [
        notificationsEnabled,
        transactionReminders,
        budgetAlerts,
        biometricAuth,
        selectedCurrency,
      ];
}
