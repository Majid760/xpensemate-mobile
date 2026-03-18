import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:xpensemate/core/utils/app_logger.dart';
import 'package:xpensemate/features/settings/data/models/settings_model.dart';

abstract class SettingsLocalDataSource {
  Future<SettingsModel> getSettings();
  Future<void> saveSettings(SettingsModel settings);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  SettingsLocalDataSourceImpl(this.sharedPreferences);

  final SharedPreferences sharedPreferences;
  static const _settingsKey = 'CACHED_SETTINGS';

  @override
  Future<SettingsModel> getSettings() async {
    try {
      final jsonString = sharedPreferences.getString(_settingsKey);
      if (jsonString != null) {
        return SettingsModel.fromJson(
          json.decode(jsonString) as Map<String, dynamic>,
        );
      } else {
        return const SettingsModel(); // Return defaults
      }
    } on Exception catch (e) {
      logE('Error getting settings from storage: $e');
      return const SettingsModel();
    }
  }

  @override
  Future<void> saveSettings(SettingsModel settings) async {
    try {
      final jsonString = json.encode(settings.toJson());
      await sharedPreferences.setString(_settingsKey, jsonString);
    } catch (e) {
      logE('Error saving settings to storage: $e');
      rethrow;
    }
  }
}
