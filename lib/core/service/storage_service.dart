/// Abstract interface for a generic storage service.
/// This allows us to switch implementations (e.g., Hive, SharedPreferences, etc.)
/// without changing the consuming code.
abstract class StorageService {
  /// Initialize the storage service
  Future<void> init();

  /// Save a value to storage
  /// [key] - unique identifier for the value
  /// [value] - the data to be stored
  /// [boxName] - optional box/collection name (default used if generic)
  Future<void> put<T>({
    required String key,
    required T value,
    String? boxName,
  });

  /// Retrieve a value from storage
  /// [key] - unique identifier for the value
  /// [defaultValue] - value to return if key doesn't exist
  /// [boxName] - optional box/collection name
  Future<T?> get<T>({
    required String key,
    T? defaultValue,
    String? boxName,
  });

  /// Delete a value from storage
  /// [key] - unique identifier for the value
  /// [boxName] - optional box/collection name
  Future<void> delete({
    required String key,
    String? boxName,
  });

  /// Delete all values from a specific box/collection
  /// [boxName] - name of the box/collection to clear
  Future<void> clearBox({required String boxName});

  /// Delete everything from all boxes
  Future<void> clearAll();

  /// Check if a key exists
  Future<bool> has({required String key, String? boxName});
}
