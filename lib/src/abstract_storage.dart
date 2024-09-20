import 'dart:async';

/// AbstractStorage: storage interface
abstract class AbstractStorage<StorageValueType> {
  /// Default domain name
  static const String defaultDomain = 'default';

  /// Default storage file name
  static const storageFileName = 'storage.db';

  /// Reset the entire storage.
  ///
  /// This method clears all data from the storage, effectively resetting it
  /// to its initial state.
  ///
  /// Example:
  /// ```dart
  /// await storage.reset();
  /// ```
  ///
  /// Returns:
  /// - A [Future] that completes when the storage is reset.
  Future<void> reset();

  /// Clear all records from the storage.
  ///
  /// This method removes all key-value pairs from the storage.
  ///
  /// Example:
  /// ```dart
  /// await storage.clearAll();
  /// ```
  ///
  /// Returns:
  /// - A [Future] that completes when all records are cleared.
  Future<void> clearAll();

  /// Clear all records from a specific domain.
  ///
  /// This method removes all key-value pairs from the specified [domain].
  ///
  /// Example:
  /// ```dart
  /// await storage.clearDomain('myDomain');
  /// ```
  ///
  /// Parameters:
  /// - `domain`: The domain to clear. Defaults to [defaultDomain].
  ///
  /// Returns:
  /// - A [Future] that completes when the domain is cleared.
  Future<void> clearDomain([String domain = defaultDomain]);

  /// Write a key-value pair to the storage.
  ///
  /// This method writes the [value] for the given [key] in the specified
  /// [domain]. If the pair already exists, it will be overwritten if
  /// [overwrite] is true (default).
  ///
  /// Example:
  /// ```dart
  /// await storage.set('myKey', 'myValue', domain: 'myDomain', overwrite: true);
  /// ```
  ///
  /// Parameters:
  /// - `key`: The key to associate with the value.
  /// - `value`: The value to store.
  /// - `domain`: The domain to store the key-value pair in. Defaults to
  ///   [defaultDomain].
  /// - `overwrite`: Whether to overwrite the value if the key already exists.
  ///   Defaults to `true`.
  ///
  /// Returns:
  /// - A [Future] that completes when the value is set.
  Future<void> set(
    String key,
    StorageValueType value, {
    String domain = defaultDomain,
    bool overwrite = true,
  });

  /// Write a map of key-value pairs to the storage.
  ///
  /// This method writes the [pairs] in the specified [domain]. If a pair
  /// already exists, it will be overwritten if [overwrite] is true (default).
  /// Unspecified pairs in the database will not be altered or deleted.
  ///
  /// Example:
  /// ```dart
  /// await storage.setDomain({'key1': 'value1', 'key2': 'value2'}, domain: 'myDomain', overwrite: true);
  /// ```
  ///
  /// Parameters:
  /// - `pairs`: A map of key-value pairs to store.
  /// - `domain`: The domain to store the key-value pairs in. Defaults to
  ///   [defaultDomain].
  /// - `overwrite`: Whether to overwrite the values if the keys already exist.
  ///   Defaults to `true`.
  ///
  /// Returns:
  /// - A [Future] that completes when the key-value pairs are set.
  Future<void> setDomain(
    Map<String, StorageValueType> pairs, {
    String domain = defaultDomain,
    bool overwrite = true,
  });

  /// Delete the value associated with the given [key] from the specified
  /// [domain].
  ///
  /// Example:
  /// ```dart
  /// await storage.delete('myKey', domain: 'myDomain');
  /// ```
  ///
  /// Parameters:
  /// - `key`: The key to delete.
  /// - `domain`: The domain to delete the key from. Defaults to
  ///   [defaultDomain].
  ///
  /// Returns:
  /// - A [Future] that completes when the key is deleted.
  Future<void> delete(
    String key, {
    String domain = defaultDomain,
  });

  /// Delete values associated with the given [keys] from the specified
  /// [domain].
  ///
  /// Example:
  /// ```dart
  /// await storage.deleteDomain(['key1', 'key2'], domain: 'myDomain');
  /// ```
  ///
  /// Parameters:
  /// - `keys`: A list of keys to delete.
  /// - `domain`: The domain from which to delete the keys. Defaults to
  ///   [defaultDomain].
  ///
  /// Returns:
  /// - A [Future] that completes when the keys are deleted.
  Future<void> deleteDomain(
    List<String> keys, {
    String domain = defaultDomain,
  });

  /// Get the value associated with the given [key] from the specified [domain].
  /// If the key is not found, it will return [defaultValue].
  ///
  /// Example:
  /// ```dart
  /// final value = await storage.get('myKey', defaultValue: 'default');
  /// ```
  ///
  /// Parameters:
  /// - `key`: The key to retrieve the value for.
  /// - `defaultValue`: The value to return if the key is not found. Defaults to
  ///   `null`.
  /// - `domain`: The domain to retrieve the value from. Defaults to
  ///   [defaultDomain].
  ///
  /// Returns:
  /// - A [Future] that completes with the value associated with the key, or
  ///   [defaultValue] if the key is not found.
  Future<StorageValueType?> get(
    String key, {
    StorageValueType? defaultValue,
    String domain = defaultDomain,
  });

  /// Get a map of key-value pairs from the specified [domain].
  ///
  /// Example:
  /// ```dart
  /// final map = await storage.getDomain(domain: 'myDomain');
  /// ```
  ///
  /// Parameters:
  /// - `domain`: The domain to retrieve the key-value pairs from. Defaults to
  ///   [defaultDomain].
  ///
  /// Returns:
  /// - A [Future] that completes with a map of key-value pairs from the domain.
  Future<Map<String, StorageValueType>> getDomain({
    String domain = defaultDomain,
  });

  /// Get a list of keys from the specified [domain].
  ///
  /// Example:
  /// ```dart
  /// final keys = await storage.getDomainKeys(domain: 'myDomain');
  /// ```
  ///
  /// Parameters:
  /// - `domain`: The domain to retrieve the keys from. Defaults to
  ///   [defaultDomain].
  ///
  /// Returns:
  /// - A [Future] that completes with a list of keys from the domain.
  Future<List<String>> getDomainKeys({
    String domain = defaultDomain,
  });
}
