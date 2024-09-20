import 'dart:async';

/// AbstractStorage: storage interface
abstract class AbstractStorage<StorageValueType> {
  /// Default domain name
  static const String defaultDomain = 'default';

  /// Default storage file name
  static const storageFileName = 'storage.db';

  /// Reset storage
  Future<void> reset();

  /// Clear storage: all records
  Future<void> clearAll();

  /// Clear storage: all records in one domain
  Future<void> clearDomain([String domain = defaultDomain]);

  /// Write the key-value pair.
  ///
  /// [value] will be written for the [key] in [domain].
  /// If the pair was already existed it will be overwritten if [overwrite]
  /// is true (by default)
  Future<void> set(
    String key,
    StorageValueType value, {
    String domain = defaultDomain,
    bool overwrite = true,
  });

  /// Write the key-value pair map.
  ///
  /// [pairs] will be written in [domain].
  /// If the pair was already existed it will be overwritten if [overwrite]
  /// is true (by default). Unspecified in [pairs] in db will not be altered
  /// or deleted.
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
