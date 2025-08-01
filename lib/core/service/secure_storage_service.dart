import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Interface for storage operations
sealed class IStorageService {
  Future<void> save(String key, String value);
  Future<String?> get(String key);
  Future<void> remove(String key);
  Future<void> clear();
}

// Storage keys
class StorageKeys {
  static const userToken = 'user_token';
  static const userId = 'user_id';
  static const userEmail = 'user_email';
  static const localeKey = 'selected_locale';
  static const themeKey = 'theme_mode';
}

// Main storage service - Singleton with static methods
class SecureStorageService implements IStorageService {
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();
  static final SecureStorageService _instance = SecureStorageService._internal();

  static late FlutterSecureStorage _storage;

 

  @override
  Future<void> save(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      throw Exception('Failed to save $key: $e');
    }
  }

  @override
  Future<String?> get(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      throw Exception('Failed to get $key: $e');
    }
  }

  @override
  Future<void> remove(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      throw Exception('Failed to remove $key: $e');
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw Exception('Failed to clear storage: $e');
    }
  }


}

