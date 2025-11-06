import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Storage keys constants
abstract class StorageKeys {
  // Authentication
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String tokenExpiration = 'token_expiration';
  static const String authTokens = 'auth_tokens';

  // User
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String userData = 'user_data';

  // App Settings
  static const String locale = 'selected_locale';
  static const String themeMode = 'theme_mode';

  // Legacy (for backwards compatibility)
  @Deprecated('Use accessToken instead')
  static const String userToken = 'user_token';
}

/// Interface for storage operations
abstract class IStorageService {
  /// Save a value to secure storage
  Future<void> write(String key, String value);

  /// Retrieve a value from secure storage
  Future<String?> read(String key);

  /// Remove a specific key from storage
  Future<void> delete(String key);

  /// Clear all data from storage
  Future<void> deleteAll();

  /// Check if valid access token exists
  Future<bool> hasValidToken();

  /// Check if a key exists in storage
  Future<bool> containsKey(String key);

  /// Get all keys from storage
  Future<List<String>> getAllKeys();
}

/// Secure storage service implementation using FlutterSecureStorage
/// Must be initialized once at app startup before use
class SecureStorageService implements IStorageService {
  /// Factory constructor returns singleton
  factory SecureStorageService() => instance;
  // Private constructor
  SecureStorageService._();

  /// Singleton instance
  static final SecureStorageService instance = SecureStorageService._();

  // Storage instance (late initialization)
  late final FlutterSecureStorage _storage;

  // Initialization state
  bool _isInitialized = false;
  Completer<void>? _initCompleter;

  // Configuration options
  static const _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
    resetOnError: true,
  );

  static const _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );

  /// Initialize the storage service
  /// MUST be called once at app startup before using any storage operations
  /// Safe to call multiple times - subsequent calls wait for first initialization
  Future<void> initialize() async {
    // If already initialized, return immediately
    if (_isInitialized) {
      return;
    }
    // If currently initializing, wait for completion
    if (_initCompleter != null && !_initCompleter!.isCompleted) {
      return _initCompleter!.future;
    }
    // Start initialization
    _initCompleter = Completer<void>();
    try {
      _storage = const FlutterSecureStorage(
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );

      _isInitialized = true;
      _log('✅ Storage initialized successfully');
      _initCompleter!.complete();
    } catch (e, stackTrace) {
      _logError('Failed to initialize storage', e, stackTrace);
      _initCompleter!.completeError(e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> write(String key, String value) async {
    _assertInitialized();

    try {
      _log('📝 Writing key: $key');
      await _storage.write(key: key, value: value);
      _log('✅ Successfully wrote key: $key');
    } catch (e, stackTrace) {
      _logError('Failed to write key: $key', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<String?> read(String key) async {
    _assertInitialized();

    try {
      _log('🔍 Reading key: $key');
      final value = await _storage.read(key: key);

      if (value != null) {
        _log('✅ Found key: $key (${value.length} chars)');
      } else {
        _log('⚠️ Key not found: $key');
      }

      return value;
    } catch (e, stackTrace) {
      _logError('Failed to read key: $key', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> delete(String key) async {
    _assertInitialized();

    try {
      _log('🗑️ Deleting key: $key');
      await _storage.delete(key: key);
      _log('✅ Successfully deleted key: $key');
    } catch (e, stackTrace) {
      _logError('Failed to delete key: $key', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> deleteAll() async {
    _assertInitialized();

    try {
      _log('🗑️ Deleting all keys');
      await _storage.deleteAll();
      _log('✅ Successfully deleted all keys');
    } catch (e, stackTrace) {
      _logError('Failed to delete all keys', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<bool> hasValidToken() async {
    if (!_isInitialized) {
      _log('⚠️ Storage not initialized, returning false for hasValidToken');
      return false;
    }

    try {
      final accessToken = await read(StorageKeys.accessToken);
      final isValid = accessToken != null && accessToken.isNotEmpty;
      _log('🔐 Token validation: ${isValid ? "valid" : "invalid"}');
      return isValid;
    } catch (e) {
      _logError('Failed to validate token', e);
      return false;
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    _assertInitialized();

    try {
      final value = await _storage.read(key: key);
      return value != null;
    } catch (e, stackTrace) {
      _logError('Failed to check key existence: $key', e, stackTrace);
      return false;
    }
  }

  @override
  Future<List<String>> getAllKeys() async {
    _assertInitialized();

    try {
      final allData = await _storage.readAll();
      return allData.keys.toList();
    } on Exception catch (e, stackTrace) {
      _logError('Failed to get all keys', e, stackTrace);
      return [];
    }
  }

  /// Debug method to list all stored keys and their values (truncated)
  /// Only available in debug mode
  Future<void> debugListAll() async {
    if (!kDebugMode) {
      _log('⚠️ debugListAll() only works in debug mode');
      return;
    }
    _assertInitialized();
    try {
      _log('📋 Listing all stored data:');
      final allData = await _storage.readAll();
      if (allData.isEmpty) {
        _log('no data found local storage   (empty)');
        return;
      }
      for (final entry in allData.entries) {
        final truncatedValue = entry.value.length > 20 ? '${entry.value.substring(0, 20)}...' : entry.value;
        _log('  ${entry.key}: $truncatedValue');
      }
    } on Exception catch (e, stackTrace) {
      _logError('Failed to list all data', e, stackTrace);
    }
  }

  /// Batch write multiple key-value pairs
  Future<void> writeAll(Map<String, String> data) async {
    _assertInitialized();
    if (data.isEmpty) {
      _log('⚠️ Attempted to batch write empty data');
      return;
    }
    try {
      _log('📝 Batch writing ${data.length} keys');

      // Write all in parallel for better performance
      await Future.wait(
        data.entries.map(
          (entry) => _storage.write(key: entry.key, value: entry.value),
        ),
      );

      _log('✅ Successfully batch wrote ${data.length} keys');
    } on Exception catch (e, stackTrace) {
      _logError('Failed to batch write', e, stackTrace);
      rethrow;
    }
  }

  /// Batch delete multiple keys
  Future<void> deleteKeys(List<String> keys) async {
    _assertInitialized();

    if (keys.isEmpty) {
      _log('⚠️ Attempted to batch delete empty keys');
      return;
    }

    try {
      _log('🗑️ Batch deleting ${keys.length} keys');

      // Delete all in parallel for better performance
      await Future.wait(
        keys.map((key) => _storage.delete(key: key)),
      );

      _log('✅ Successfully batch deleted ${keys.length} keys');
    } on Exception catch (e, stackTrace) {
      _logError('Failed to batch delete', e, stackTrace);
      rethrow;
    }
  }

  /// Clear authentication related data
  Future<void> clearAuthData() async {
    await deleteKeys([
      StorageKeys.accessToken,
      StorageKeys.refreshToken,
      StorageKeys.tokenExpiration,
      StorageKeys.authTokens,
      StorageKeys.userId,
      StorageKeys.userEmail,
      StorageKeys.userData,
    ]);
    _log('✅ Cleared authentication data');
  }

  /// Assert that storage is initialized, throw error if not
  /// This is a development-time check to catch initialization issues early
  void _assertInitialized() {
    assert(
      _isInitialized,
      'SecureStorageService must be initialized before use. '
      'Call await SecureStorageService.instance.initialize() at app startup.',
    );

    if (!_isInitialized) {
      throw StateError(
        'SecureStorageService is not initialized. '
        'Call await SecureStorageService.instance.initialize() at app startup.',
      );
    }
  }

  /// Log message (only in debug mode)
  void _log(String message) {
    if (kDebugMode) {
      debugPrint('[SecureStorage] $message');
    }
  }

  /// Log error with stack trace (only in debug mode)
  void _logError(String message, Object error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[SecureStorage] ❌ $message: $error');
      if (stackTrace != null) {
        debugPrint('[SecureStorage] Stack trace: $stackTrace');
      }
    }
  }

  /// Check if storage is initialized (useful for conditional logic)
  bool get isInitialized => _isInitialized;
}

/// Extension methods for common storage operations
extension SecureStorageExtensions on SecureStorageService {
  /// Save user token
  Future<void> saveToken(String token) async {
    await write(StorageKeys.accessToken, token);
  }

  /// Get user token
  Future<String?> getToken() async => read(StorageKeys.accessToken);

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    await write(StorageKeys.refreshToken, token);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async => read(StorageKeys.refreshToken);

  /// Save user ID
  Future<void> saveUserId(String userId) async {
    await write(StorageKeys.userId, userId);
  }

  /// Get user ID
  Future<String?> getUserId() async => read(StorageKeys.userId);

  /// Save theme mode
  Future<void> saveThemeMode(String themeMode) async {
    await write(StorageKeys.themeMode, themeMode);
  }

  /// Get theme mode
  Future<String?> getThemeMode() async => read(StorageKeys.themeMode);

  /// Save locale
  Future<void> saveLocale(String locale) async {
    await write(StorageKeys.locale, locale);
  }

  /// Get locale
  Future<String?> getLocale() async => read(StorageKeys.locale);
}
