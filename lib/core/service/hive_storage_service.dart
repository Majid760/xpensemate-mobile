import 'package:hive_flutter/hive_flutter.dart';
import 'package:xpensemate/core/service/storage_service.dart';
import 'package:xpensemate/core/utils/app_logger.dart';

/// A robust implementation of [StorageService] using Hive.
///
/// Features:
/// - Generic type support
/// - Automatic box management
/// - Error handling and logging
/// - Singleton-ready structure
class HiveStorageService implements StorageService {
  // Private constructor
  HiveStorageService._();

  // Singleton instance
  static final HiveStorageService instance = HiveStorageService._();

  // Cache for open boxes to avoid repeated opening
  final Map<String, Box<dynamic>> _openBoxes = {};

  // Default box name if none specified
  static const String _defaultBoxName = 'app_preferences';

  @override
  Future<void> init() async {
    try {
      await Hive.initFlutter();
      // Open default box immediately
      await _getBox(_defaultBoxName);
      AppLogger.i('HiveStorageService initialized successfully');
    } on Exception catch (e, stackTrace) {
      AppLogger.e('Failed to initialize HiveStorageService', stackTrace);
      // Re-throw or handle gracefully depending on app requirements
      rethrow;
    }
  }

  /// Helper to get or open a box safely
  Future<Box<dynamic>> _getBox(String? boxName) async {
    final name = boxName ?? _defaultBoxName;

    if (_openBoxes.containsKey(name) && _openBoxes[name]!.isOpen) {
      return _openBoxes[name]!;
    }

    try {
      final box = await Hive.openBox<dynamic>(name);
      _openBoxes[name] = box;
      return box;
    } catch (e, stackTrace) {
      AppLogger.e('Failed to open Hive box: $name', stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> put<T>({
    required String key,
    required T value,
    String? boxName,
  }) async {
    try {
      AppLogger.breadcrumb(
          'Hive Storage: put key $key in box ${boxName ?? _defaultBoxName}');
      final box = await _getBox(boxName);
      await box.put(key, value);
    } on Exception catch (e, stackTrace) {
      AppLogger.e('Hive put error [key: $key, box: $boxName]', stackTrace);
      throw Exception('Failed to save data to storage');
    }
  }

  @override
  Future<T?> get<T>({
    required String key,
    T? defaultValue,
    String? boxName,
  }) async {
    try {
      final box = await _getBox(boxName);
      return box.get(key, defaultValue: defaultValue) as T?;
    } on Exception catch (e, stackTrace) {
      AppLogger.e('Hive get error [key: $key, box: $boxName]', stackTrace);
      return defaultValue;
    }
  }

  @override
  Future<void> delete({
    required String key,
    String? boxName,
  }) async {
    try {
      final box = await _getBox(boxName);
      await box.delete(key);
    } on Exception catch (e, stackTrace) {
      AppLogger.e('Hive delete error [key: $key, box: $boxName]', stackTrace);
    }
  }

  @override
  Future<void> clearBox({required String boxName}) async {
    try {
      final box = await _getBox(boxName);
      await box.clear();
    } on Exception catch (e, stackTrace) {
      AppLogger.e('Hive clearBox error [box: $boxName]', stackTrace);
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      AppLogger.breadcrumb('Hive Storage: clearing all boxes');
      for (final boxName in _openBoxes.keys) {
        final box = _openBoxes[boxName];
        if (box != null && box.isOpen) {
          await box.clear();
        }
      }
    } on Exception catch (e, stackTrace) {
      AppLogger.e('Hive clearAll error', stackTrace);
    }
  }

  @override
  Future<bool> has({required String key, String? boxName}) async {
    try {
      final box = await _getBox(boxName);
      return box.containsKey(key);
    } on Exception catch (e, stackTrace) {
      AppLogger.e('Hive has key check error [key: $key]', stackTrace);
      return false;
    }
  }
}
