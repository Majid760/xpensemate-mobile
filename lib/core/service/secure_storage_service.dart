import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Interface for storage operations
sealed class IStorageService {
  Future<void> save(String key, String value);
  Future<String?> get(String key);
  Future<void> remove(String key);
  Future<void> clear();
  Future<bool> hasValidToken();
  Future<void> debugListAllKeys();
}

// Storage keys
class StorageKeys {
  static const userToken = 'user_token';
  static const userId = 'user_id';
  static const userEmail = 'user_email';
  static const localeKey = 'selected_locale';
  static const themeKey = 'theme_mode';
  static const accessTokenKey = 'access_token';
  static const refreshTokenKey = 'refresh_token';
  static const userData = 'user_data';
}

// Main storage service - Singleton with static methods
class SecureStorageService implements IStorageService {
  SecureStorageService._internal();

  // Singleton instance
  static final SecureStorageService _instance =
      SecureStorageService._internal();
  static SecureStorageService get instance => _instance;

  FlutterSecureStorage? _storage;
  bool _isInitialized = false;

  // Initialize the storage service
  Future<void> initialize() async {
    try {
      if (!_isInitialized) {
        _storage = const FlutterSecureStorage();
        _isInitialized = true;
      }
    } on Exception catch (e) {
      debugPrint('Error initializing secure storage: $e');
      // If initialization fails, create a fallback
      _storage = const FlutterSecureStorage();
      _isInitialized = true;
    }
  }

  @override
  Future<void> save(String key, String value) async {
    await _ensureInitialized();
    try {
      debugPrint('🔐 Saving key: $key, value: ${value.substring(0, 10)}...');
      await _storage!.write(key: key, value: value);
      debugPrint('✅ Successfully saved key: $key');
    } catch (e) {
      debugPrint('❌ Failed to save $key: $e');
      throw Exception('Failed to save $key: $e');
    }
  }

  @override
  Future<String?> get(String key) async {
    await _ensureInitialized();
    try {
      debugPrint('🔍 Getting key: $key');
      final value = await _storage!.read(key: key);
      if (value != null) {
        debugPrint(
          '✅ Retrieved key: $key, value: ${value.substring(0, 10)}...',
        );
      } else {
        debugPrint('❌ Key not found: $key');
      }
      return value;
    } catch (e) {
      debugPrint('❌ Failed to get $key: $e');
      throw Exception('Failed to get $key: $e');
    }
  }

  @override
  Future<void> remove(String key) async {
    await _ensureInitialized();
    try {
      await _storage!.delete(key: key);
    } catch (e) {
      debugPrint('❌ error removing key =>>> $key');
      throw Exception('Failed to remove $key: $e');
    }
  }

  @override
  Future<void> clear() async {
    await _ensureInitialized();
    try {
      await _storage!.deleteAll();
    } catch (e) {
      debugPrint('❌ error deleting all keys');
      throw Exception('Failed to clear storage: $e');
    }
  }

  @override
  Future<bool> hasValidToken() async {
    await _ensureInitialized();
    final accessToken = await get(StorageKeys.accessTokenKey);
    return accessToken != null && accessToken.isNotEmpty;
  }

  // Debug method to list all stored keys
  @override
  Future<void> debugListAllKeys() async {
    await _ensureInitialized();
    try {
      debugPrint('🔍 Listing all stored keys...');
      final allKeys = await _storage!.readAll();
      debugPrint('📋 All stored keys: ${allKeys.keys.toList()}');
      for (final entry in allKeys.entries) {
        final value = entry.value;
        if (value.isNotEmpty) {
          debugPrint('  ${entry.key}: ${value.substring(0, 10)}...');
        } else {
          debugPrint('  ${entry.key}: null/empty');
        }
      }
    } on Exception catch (e) {
      debugPrint('❌ Failed to list keys: $e');
    }
  }

  // Ensure storage is initialized before use
  Future<void> _ensureInitialized() async {
    if (!_isInitialized || _storage == null) {
      await initialize();
    }
  }
}
