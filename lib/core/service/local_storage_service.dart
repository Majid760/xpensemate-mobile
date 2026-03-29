import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';


enum StorageDomain {
  settings('settings_box'),
  dashboard('dashboard_box'),
  expense('expense_box'),
  budget('budget_box'),
  payment('payment_box');

  const StorageDomain(this.boxName);
  final String boxName;
}


class LocalStorageService {
  LocalStorageService._internal();
  static final LocalStorageService instance = LocalStorageService._internal();

  /// Initialize Hive and open all essential boxes.
  /// Must be called in `main()` before `runApp()`.
  Future<void> init() async {
    await Hive.initFlutter();
    
    // Open all boxes concurrently for faster startup
    await Future.wait(
      StorageDomain.values.map((domain) => Hive.openBox<dynamic>(domain.boxName)),
    );
  }

  /// Get the Hive box for a specific domain.
  Box<dynamic> _getBox(StorageDomain domain) {
    if (!Hive.isBoxOpen(domain.boxName)) {
      throw StateError('Box ${domain.boxName} is not open. Call init() first.');
    }
    return Hive.box<dynamic>(domain.boxName);
  }

  /// Save data to local storage.
  Future<void> saveData({
    required StorageDomain domain,
    required String key,
    required dynamic value,
  }) async {
    final box = _getBox(domain);

    dynamic storageValue;
    if (value is Map || value is List) {
      // Encode complex types to JSON strings for robust storage
      storageValue = jsonEncode(value);
    } else {
      // Primitive types (int, String, bool, double) are stored natively
      storageValue = value;
    }
    await box.put(key, storageValue);
  }

  /// Retrieve data from local storage.
  /// Automatically attempts to JSON decode the result if it was stored as a JSON string.
  dynamic getData({
    required StorageDomain domain,
    required String key,
    dynamic defaultValue,
  }) {
    final box = _getBox(domain);
    final data = box.get(key, defaultValue: defaultValue);
    
    if (data == null) return defaultValue;

    if (data is String) {
      try {
        // Only attempt to decode if it looks like a JSON Map or List
        if (data.startsWith('{') || data.startsWith('[')) {
          return jsonDecode(data);
        }
      } on Exception catch (e) {
        debugPrint('LocalStorageService jsonDecode error for key $key: $e');
      }
    }
    
    return data;
  }

  /// Retrieve data from local storage and parse it using a generic builder.
  T? getDataAs<T>({
    required StorageDomain domain,
    required String key,
    required T Function(dynamic json) fromJson,
  }) {
    final data = getData(domain: domain, key: key);
    if (data != null) {
      try {
        return fromJson(data);
      }on Exception catch (e) {
        debugPrint('LocalStorageService parsing error for key $key: $e');
      }
    }
    return null;
  }

  /// Retrieve a list of data models from local storage.
  List<T> getListAs<T>({
    required StorageDomain domain,
    required String key,
    required T Function(dynamic json) fromJson,
  }) {
    final data = getData(domain: domain, key: key);
    if (data is List) {
      try {
        return data.map((e) => fromJson(e)).toList();
      } on Exception catch (e) {
        debugPrint('LocalStorageService list parsing error for key $key: $e');
      }
    }
    return [];
  }

  /// Check if a key exists in a specified domain.
  bool containsKey({
    required StorageDomain domain,
    required String key,
  }) => _getBox(domain).containsKey(key);

  /// Delete specific data by key.
  Future<void> deleteData({
    required StorageDomain domain,
    required String key,
  }) async {
    await _getBox(domain).delete(key);
  }

  /// Clear all data in a specific domain.
  Future<void> clearDomain(StorageDomain domain) async {
    await _getBox(domain).clear();
  }
  
  /// Clear all local storage (Useful for Logout or Reset).
  Future<void> clearAll() async {
    await Future.wait(
      StorageDomain.values.map((domain) {
        if (Hive.isBoxOpen(domain.boxName)) {
          return Hive.box<dynamic>(domain.boxName).clear();
        }
        return Future.value();
      }),
    );
  }
}
